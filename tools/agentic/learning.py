"""Offline evidence-backed skill learning. Reviewed local scripts only; no model calls.

Records share Forge's coordinator database. This is a cooperative consistency
guard, not authenticated review, an OS sandbox, or gameplay acceptance.
"""
from __future__ import annotations
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
import sys
import tempfile
import time
import uuid
import forge
import git_evidence
from run_worker import run_process

STORE = "production/learning"
KINDS = {"lesson", "proposal", "evaluation"}
SPLITS = {"train", "holdout", "refusal"}


def canonical(value):
    return json.dumps(value, sort_keys=True, ensure_ascii=False, allow_nan=False, separators=(",", ":"))


def sha(data):
    return hashlib.sha256(data).hexdigest()


def nonempty(value, name):
    if not isinstance(value, str) or not value.strip() or len(value) > 16000:
        raise ValueError(f"Nonempty bounded {name} required")
    return value.strip()


def person(value):
    return nonempty(value, "actor").casefold()


def local_path(root, rel):
    path = forge.inside(root, rel)
    # Internal Windows junctions can alias a different owner's file without
    # escaping the repository; lexical lease scopes must not authorize aliases.
    actual = path.resolve().relative_to(Path(root).resolve()).as_posix()
    if actual.casefold() != rel.casefold():
        raise ValueError("Resolved path aliases/junctions are not permitted")
    return path


def artifact(root, ref, *, allow_empty=False):
    if not isinstance(ref, dict):
        raise ValueError("Artifact reference required")
    path = local_path(root, ref.get("path", ""))
    if (not path.is_file() or path.stat().st_size > 16 * 1024 * 1024
            or (not allow_empty and path.stat().st_size == 0)
            or forge.digest(path) != ref.get("sha256")):
        raise ValueError("Missing, oversized or changed artifact")
    return path


def reference(root, rel):
    path = local_path(root, rel)
    ref = {"path": rel, "sha256": forge.digest(path)}
    artifact(root, ref)
    return ref


def skill_path(value):
    parts = forge.relative_path(value).parts
    if (len(parts) != 4 or parts[:2] != (".agents", "skills") or parts[3] != "SKILL.md"
            or not forge.SLUG.fullmatch(parts[2]) or len(parts[2]) > 64):
        raise ValueError("Only an existing repository skill SKILL.md may be patched")
    return parts[2]


def validate_skill(data, target):
    name = skill_path(target)
    if len(data) > 128 * 1024:
        raise ValueError("Skill candidate exceeds 128 KiB")
    text = data.decode("utf-8")
    if not text.startswith("---\n") or "\n---\n" not in text[4:]:
        raise ValueError("Skill frontmatter required")
    front = text.split("---", 2)[1]
    if not re.search(r"^name: " + re.escape(name) + r"$", front, re.M):
        raise ValueError("Candidate cannot rename its skill")
    description = re.search(r"^description: (.+)$", front, re.M)
    if not description or len(description[1]) > 1024:
        raise ValueError("Skill description required")
    return text


class Learning:
    def __init__(self, root, ledger, task, token):
        self.root = Path(root).resolve()
        if ledger.root.resolve() != self.root:
            raise ValueError("Learning must use its task's shared coordinator root")
        self.ledger, self.db, self.task, self.token = ledger, ledger.db, task, token
        self.author = ledger.assert_lease(task, token)["owner"]
        self._scope(STORE)
        self.db.execute("CREATE TABLE IF NOT EXISTS learning_records (kind TEXT, id TEXT PRIMARY KEY, body TEXT NOT NULL, sha256 TEXT NOT NULL)")
        self.db.execute("CREATE TABLE IF NOT EXISTS learning_journal (id TEXT PRIMARY KEY, body TEXT NOT NULL, sha256 TEXT NOT NULL, state TEXT NOT NULL)")

    def _scope(self, rel):
        row = self.ledger.assert_lease(self.task, self.token)
        if person(row["owner"]) != person(self.author):
            raise ValueError("Lease owner changed")
        local_path(self.root, rel)
        if not any(forge.contains_path(scope, rel) for scope in self.ledger.tasks[self.task]["writeScopes"]):
            raise ValueError(f"Learning write outside task permission scope: {rel}")

    def _put(self, kind, body):
        if kind not in KINDS:
            raise ValueError("Unknown record kind")
        self._scope(STORE)
        encoded = canonical(body)
        digest = sha(encoded.encode())
        key = kind + "-" + digest
        self.db.execute("INSERT OR IGNORE INTO learning_records VALUES (?,?,?,?)", (kind, key, encoded, digest))
        self.get(key, kind)
        return key

    def get(self, key, kind=None):
        row = self.db.execute("SELECT * FROM learning_records WHERE id=?", (key,)).fetchone()
        if (not row or (kind and row["kind"] != kind) or row["kind"] not in KINDS
                or sha(row["body"].encode()) != row["sha256"]
                or row["id"] != row["kind"] + "-" + row["sha256"]):
            raise ValueError("Missing or tampered learning record")
        return json.loads(row["body"], parse_constant=forge.reject_constant, object_pairs_hook=forge.unique_pairs)

    def _write(self, rel, data):
        self._scope(rel)
        target = forge.inside(self.root, rel)
        target.parent.mkdir(parents=True, exist_ok=True)
        self._scope(rel)
        fd, tmp = tempfile.mkstemp(prefix=".learning-", dir=target.parent)
        try:
            with os.fdopen(fd, "wb") as stream:
                stream.write(data)
                stream.flush()
                os.fsync(stream.fileno())
            self._scope(rel)
            os.replace(tmp, target)
        finally:
            if os.path.exists(tmp):
                os.unlink(tmp)

    def _stamp(self):
        plan = forge.read_json(self.root / "production/plan.json")
        if git_evidence.plan_hash(plan) != self.ledger.plan_hash:
            raise ValueError("Task plan changed")
        policy = forge.inside(self.root, "AGENTS.md")
        if not policy.is_file():
            raise ValueError("AGENTS.md permission contract required")
        return {"head": git_evidence.head(self.root), "planSha256": self.ledger.plan_hash,
                "policySha256": forge.digest(policy)}

    def _current(self, proposal):
        if self._stamp() != proposal["stamp"]:
            raise ValueError("Stale HEAD, task plan or permission contract; repropose and evaluate")
        self._scope(proposal["target"])
        target = forge.inside(self.root, proposal["target"])
        if forge.digest(target) != proposal["baselineSha256"]:
            raise ValueError("Stale skill baseline")
        candidate = artifact(self.root, proposal["candidate"])
        validate_skill(candidate.read_bytes(), proposal["target"])
        if sha(base64.b64decode(proposal["baselineBytes"], validate=True)) != proposal["baselineSha256"]:
            raise ValueError("Tampered baseline backup")
        for lesson in proposal["lessons"]:
            self.verify_lesson(self.get(lesson, "lesson"))

    def verify_lesson(self, lesson):
        if lesson.get("outcome") not in {"success", "failure", "interrupted"}:
            raise ValueError("Explicit observed outcome required")
        for field in ("context", "observation", "correction", "limit"):
            nonempty(lesson.get(field), field)
        if not isinstance(lesson.get("tags"), list) or any(not forge.SLUG.fullmatch(x) for x in lesson["tags"]):
            raise ValueError("Lesson tags must be slugs")
        refs = lesson.get("evidence")
        if not isinstance(refs, list) or not refs or len(refs) > 30:
            raise ValueError("Lesson needs preserved evidence, not a claimed result")
        if len({x["path"] for x in refs}) != len(refs):
            raise ValueError("Duplicate evidence")
        for ref in refs:
            artifact(self.root, ref)

    def record(self, lesson):
        self.verify_lesson(lesson)
        body = {k: lesson[k] for k in ("outcome", "context", "observation", "correction", "limit", "tags", "evidence")}
        body.update(author=self.author, taskId=self.task, stamp=self._stamp(), created=time.time(),
                    acceptance="OBSERVED_LESSON_NOT_GAME_ACCEPTANCE")
        return self._put("lesson", body)

    def search(self, query, limit=10):
        if type(limit) is not int or not 1 <= limit <= 100:
            raise ValueError("Search limit 1..100 required")
        terms = set(re.findall(r"\w+", nonempty(query, "query").casefold()))
        hits = []
        for row in self.db.execute("SELECT id FROM learning_records WHERE kind='lesson'"):
            lesson = self.get(row["id"], "lesson")
            text = canonical(lesson).casefold()
            score = sum(term in text for term in terms)
            if score:
                self.verify_lesson(lesson)
                hits.append({"id": row["id"], "score": score, "lesson": lesson})
        return sorted(hits, key=lambda x: (-x["score"], x["id"]))[:limit]

    def propose(self, target, candidate_ref, lessons, training):
        self._scope(target)
        skill_path(target)
        baseline = forge.inside(self.root, target).read_bytes()
        if not baseline or not isinstance(lessons, list) or not lessons:
            raise ValueError("Existing baseline and supporting lessons required")
        for key in lessons:
            self.verify_lesson(self.get(key, "lesson"))
        candidate = artifact(self.root, candidate_ref).read_bytes()
        validate_skill(candidate, target)
        if candidate == baseline:
            raise ValueError("Candidate must change the baseline")
        if not isinstance(training, list) or not training or len(training) > 10:
            raise ValueError("At least one bounded training scenario required")
        for ref in training:
            self._scenario(ref)
        if len({x["sha256"] for x in training}) != len(training):
            raise ValueError("Duplicate training scenario")
        rel = STORE + "/candidates/" + sha(candidate) + ".md"
        if forge.inside(self.root, rel).exists():
            if forge.digest(forge.inside(self.root, rel)) != sha(candidate):
                raise ValueError("Content-addressed candidate changed")
        else:
            self._write(rel, candidate)
        return self._put("proposal", {"author": self.author, "taskId": self.task, "target": target,
            "baselineBytes": base64.b64encode(baseline).decode(), "baselineSha256": sha(baseline),
            "candidate": {"path": rel, "sha256": sha(candidate)}, "lessons": lessons,
            "training": training, "stamp": self._stamp(), "created": time.time()})

    def _scenario(self, ref):
        value = forge.read_json(artifact(self.root, ref))
        if not isinstance(value, dict) or "input" not in value or "expected" not in value:
            raise ValueError("Scenario requires input and explicit expected outcome")
        nonempty(value.get("id"), "scenario ID")
        return value

    def _known_inputs(self, proposal):
        """Exclude previously exposed structured requests, independent of IDs/paths.

        Narrative evidence still requires the independent reviewer's judgment.
        Do not treat arbitrary evidence text as executable instructions.
        """
        known = {sha(canonical(self._scenario(ref)["input"]).encode()) for ref in proposal["training"]}
        def collect(value):
            if isinstance(value, dict):
                if "input" in value:
                    known.add(sha(canonical(value["input"]).encode()))
                for child in value.values():
                    collect(child)
            elif isinstance(value, list):
                for child in value:
                    collect(child)
        for lesson_id in proposal["lessons"]:
            for ref in self.get(lesson_id, "lesson")["evidence"]:
                path = artifact(self.root, ref)
                try:
                    value = forge.read_json(path)
                except (ValueError, UnicodeError):
                    continue
                collect(value)
        return known

    def evaluate(self, proposal_id, reviewer, config_ref):
        proposal = self.get(proposal_id, "proposal")
        self._current(proposal)
        if person(reviewer) == person(proposal["author"]):
            raise ValueError("A different reviewer must evaluate the proposed skill")
        config = forge.read_json(artifact(self.root, config_ref))
        if config.get("permissionsPreserved") is not True:
            raise ValueError("Reviewer must explicitly assess preserved permission scope")
        nonempty(config.get("reviewNotes"), "independent review notes")
        runner = artifact(self.root, config.get("runner"))
        if runner.suffix != ".py":
            raise ValueError("Only an explicitly hash-reviewed local Python evaluator is supported")
        cases = config.get("cases")
        if not isinstance(cases, list) or not 3 <= len(cases) <= 12:
            raise ValueError("Train, fresh holdout and refusal cases required (3..12)")
        timeout = config.get("timeoutSeconds", 10)
        if type(timeout) is not int or not 1 <= timeout <= 30 or len(cases) * timeout > 120:
            raise ValueError("Bound evaluation to 120 seconds total and 30 per case")
        split_set, seen_ids, seen_content = set(), set(), set()
        training = {x["sha256"] for x in proposal["training"]}
        train_seen = set()
        lesson_evidence = {r["sha256"] for key in proposal["lessons"] for r in self.get(key, "lesson")["evidence"]}
        known_inputs = self._known_inputs(proposal)
        for case in cases:
            split = case.get("split")
            if split not in SPLITS:
                raise ValueError("Unknown evaluation split")
            scenario = self._scenario(case.get("scenario"))
            # Renaming a training request is not a holdout. Match semantic JSON input.
            content = sha(canonical(scenario["input"]).encode())
            if scenario["id"] in seen_ids or content in seen_content:
                raise ValueError("Evaluation cases must have distinct IDs and inputs")
            seen_ids.add(scenario["id"]); seen_content.add(content); split_set.add(split)
            if split == "train":
                if case["scenario"]["sha256"] not in training:
                    raise ValueError("Training scenario differs from proposal")
                train_seen.add(case["scenario"]["sha256"])
            elif case["scenario"]["sha256"] in training | lesson_evidence:
                raise ValueError("Holdout/refusal scenario leaked into supporting evidence")
            elif content in known_inputs:
                raise ValueError("Holdout/refusal input was already exposed in training or lesson evidence")
            if split == "refusal" and scenario["expected"] != "REFUSED":
                raise ValueError("Refusal case must expect REFUSED")
        if split_set != SPLITS or train_seen != training:
            raise ValueError("All training plus a fresh holdout and refusal case are required")
        train_inputs = {sha(canonical(self._scenario(ref)["input"]).encode()) for ref in proposal["training"]}
        if any(sha(canonical(self._scenario(c["scenario"])["input"]).encode()) in train_inputs
               for c in cases if c["split"] != "train"):
            raise ValueError("Holdout duplicates a training input")
        out_rel = STORE + "/evaluations/" + uuid.uuid4().hex
        results = []
        # No shell, model, network installer or background scheduler is invoked.
        # A reviewed evaluator is trusted code; this directory is NOT a sandbox.
        for number, case in enumerate(cases):
            self._current(proposal)
            artifact(self.root, config_ref); artifact(self.root, config["runner"])
            scenario_path = artifact(self.root, case["scenario"])
            scenario = self._scenario(case["scenario"])
            rel = out_rel + "/" + str(number)
            self._scope(rel)
            out = forge.inside(self.root, rel)
            out.mkdir(parents=True, exist_ok=False)
            inputs = []
            for name, source in (("runner.py", runner), ("candidate.md", artifact(self.root, proposal["candidate"])),
                                 ("scenario.json", scenario_path)):
                copied_rel = rel + "/workspace/" + name
                self._write(copied_rel, source.read_bytes())
                inputs.append(reference(self.root, copied_rel))
            workspace = forge.inside(self.root, rel + "/workspace")
            try:
                result = run_process([sys.executable, str(workspace / "runner.py"), "--candidate",
                    str(workspace / "candidate.md"), "--scenario", str(workspace / "scenario.json")],
                    "", workspace, out, timeout, lambda: self.ledger.assert_lease(self.task, self.token))
                code = result["exitCode"]
                raw = (out / "events.jsonl").read_text(encoding="utf-8")
                observed = json.loads(raw, parse_constant=forge.reject_constant, object_pairs_hook=forge.unique_pairs)
                for ref in inputs:
                    artifact(self.root, ref)
                passed = (type(code) is int and code == 0 and isinstance(observed, dict)
                    and observed.get("candidateSha256") == proposal["candidate"]["sha256"]
                    and observed.get("scenarioSha256") == case["scenario"]["sha256"]
                    and canonical(observed.get("observed")) == canonical(scenario["expected"]))
                error = None
            except (ValueError, OSError, TimeoutError, json.JSONDecodeError) as exc:
                passed, code, observed, error = False, None, None, str(exc)
            logs = []
            for path in (out / "events.jsonl", out / "stderr.txt"):
                if path.is_file():
                    logs.append({"path": path.relative_to(self.root).as_posix(), "sha256": forge.digest(path),
                                 "bytes": path.stat().st_size})
            results.append({"split": case["split"], "scenario": case["scenario"], "expected": scenario["expected"],
                            "observed": observed, "exitCode": code, "passed": passed, "error": error, "logs": logs,
                            "inputs": inputs})
        self._current(proposal)
        return self._put("evaluation", {"proposalId": proposal_id, "reviewer": reviewer,
            "config": config_ref, "runner": config["runner"], "candidate": proposal["candidate"],
            "stamp": proposal["stamp"], "results": results, "passed": all(r["passed"] for r in results),
            "permissionsPreserved": True, "reviewNotes": config["reviewNotes"], "created": time.time(),
            "acceptance": "LOCAL_FORWARD_TEST_NOT_HUMAN_OR_GAME_ACCEPTANCE"})

    def verify_evaluation(self, evaluation, proposal_id, proposal, reviewer):
        if (evaluation.get("proposalId") != proposal_id or evaluation.get("passed") is not True
                or person(evaluation["reviewer"]) != person(reviewer)
                or person(reviewer) == person(proposal["author"])
                or evaluation.get("candidate") != proposal["candidate"] or evaluation.get("stamp") != proposal["stamp"]
                or evaluation.get("permissionsPreserved") is not True):
            raise ValueError("Passing independent evaluation for this candidate required")
        artifact(self.root, evaluation["config"]); artifact(self.root, evaluation["runner"])
        for result in evaluation["results"]:
            scenario = self._scenario(result["scenario"])
            if result["passed"] is not True or not result["logs"] or result["exitCode"] != 0:
                raise ValueError("Evaluation case failed or has no captured proof")
            for ref in result["logs"]:
                path = artifact(self.root, ref, allow_empty=True)
                if path.stat().st_size != ref["bytes"]:
                    raise ValueError("Captured evaluation log size changed")
            inputs = result.get("inputs", [])
            if (len(inputs) != 3 or [r["sha256"] for r in inputs] !=
                    [evaluation["runner"]["sha256"], proposal["candidate"]["sha256"], result["scenario"]["sha256"]]):
                raise ValueError("Evaluation copies do not bind the reviewed runner/candidate/scenario")
            for ref in inputs:
                artifact(self.root, ref)
            raw_path = next((r for r in result["logs"] if r["path"].endswith("/events.jsonl")), None)
            if not raw_path:
                raise ValueError("Missing raw evaluator output")
            observed = forge.read_json(artifact(self.root, raw_path))
            if (observed != result["observed"] or observed.get("candidateSha256") != proposal["candidate"]["sha256"]
                    or observed.get("scenarioSha256") != result["scenario"]["sha256"]
                    or canonical(observed.get("observed")) != canonical(scenario["expected"])):
                raise ValueError("Evaluation output does not match expected case")

    def _journal(self, key):
        row = self.db.execute("SELECT * FROM learning_journal WHERE id=?", (key,)).fetchone()
        if not row or sha(row["body"].encode()) != row["sha256"]:
            raise ValueError("Missing or tampered promotion journal")
        return json.loads(row["body"]), row["state"]

    def _latest_mutation(self, target):
        for row in self.db.execute("SELECT id FROM learning_journal WHERE state IN ('PROMOTED','ROLLED_BACK','SUPERSEDED') ORDER BY rowid DESC"):
            body, _ = self._journal(row["id"])
            if body["target"] == target:
                return row["id"]
        return None

    def _swap(self, target, before, after, body):
        self._scope(target)
        self.db.execute("BEGIN IMMEDIATE")
        try:
            if self.db.execute("SELECT 1 FROM learning_journal WHERE state='PREPARED'").fetchone():
                raise ValueError("Recover interrupted learning transaction before another mutation")
            if forge.digest(forge.inside(self.root, target)) != sha(before):
                raise ValueError("Target changed before atomic mutation")
            previous = self._latest_mutation(target)
            if body["operation"] == "ROLLED_BACK" and previous != body["promotionId"]:
                raise ValueError("Stale promotion lineage prevents rollback")
            key = uuid.uuid4().hex
            body.update(target=target, before=base64.b64encode(before).decode(), beforeSha256=sha(before),
                        afterSha256=sha(after), previousTransactionId=previous,
                        owner=self.author, taskId=self.task, created=time.time())
            raw = canonical(body)
            self.db.execute("INSERT INTO learning_journal VALUES (?,?,?,'PREPARED')", (key, raw, sha(raw.encode())))
            self.db.execute("COMMIT")
        except Exception:
            self.db.execute("ROLLBACK")
            raise
        try:
            self._scope(target)
            if forge.digest(forge.inside(self.root, target)) != sha(before):
                raise ValueError("Target changed after preparation")
            self._write(target, after)
            self._scope(target)
            if forge.digest(forge.inside(self.root, target)) != sha(after):
                raise ValueError("Atomic mutation verification failed")
            self.db.execute("UPDATE learning_journal SET state=? WHERE id=? AND state='PREPARED'", (body["operation"], key))
            return key
        except Exception:
            # Leave a recovery journal if the lease expires or a third party edits.
            # Never overwrite an unrelated edit while trying to recover.
            try:
                self._scope(target)
                current = forge.digest(forge.inside(self.root, target))
                if current == sha(after):
                    self._write(target, before)
                    current = sha(before)
                if current == sha(before):
                    self.db.execute("UPDATE learning_journal SET state='FAILED_RESTORED' WHERE id=?", (key,))
            except (ValueError, OSError, sqlite3.Error):
                pass
            raise

    def promote(self, proposal_id, evaluation_id, reviewer):
        proposal = self.get(proposal_id, "proposal")
        self._current(proposal)
        self.verify_evaluation(self.get(evaluation_id, "evaluation"), proposal_id, proposal, reviewer)
        return self._swap(proposal["target"], base64.b64decode(proposal["baselineBytes"], validate=True),
            artifact(self.root, proposal["candidate"]).read_bytes(),
            {"operation": "PROMOTED", "proposalId": proposal_id, "evaluationId": evaluation_id, "reviewer": reviewer})

    def rollback(self, promotion_id):
        body, state = self._journal(promotion_id)
        if state != "PROMOTED":
            raise ValueError("Only a live successful promotion may be rolled back")
        target = body["target"]
        self._scope(target)
        if self._latest_mutation(target) != promotion_id:
            raise ValueError("Stale promotion lineage prevents rollback")
        current = forge.inside(self.root, target).read_bytes()
        if sha(current) != body["afterSha256"]:
            raise ValueError("Later skill edit prevents rollback; reconcile instead")
        before = base64.b64decode(body["before"], validate=True)
        if sha(before) != body["beforeSha256"]:
            raise ValueError("Rollback backup changed")
        key = self._swap(target, current, before, {"operation": "ROLLED_BACK", "promotionId": promotion_id})
        self.db.execute("UPDATE learning_journal SET state='SUPERSEDED' WHERE id=?", (promotion_id,))
        return key

    def recover(self, transaction_id):
        body, state = self._journal(transaction_id)
        if state != "PREPARED":
            raise ValueError("Only an interrupted PREPARED transaction needs recovery")
        target = body["target"]
        self._scope(target)
        current = forge.digest(forge.inside(self.root, target))
        if current not in {body["beforeSha256"], body["afterSha256"]}:
            raise ValueError("Unrelated edit prevents recovery")
        before = base64.b64decode(body["before"], validate=True)
        if sha(before) != body["beforeSha256"]:
            raise ValueError("Recovery backup changed")
        if current == body["afterSha256"]:
            self._write(target, before)
        self.db.execute("UPDATE learning_journal SET state='RECOVERED_NOT_PROMOTED' WHERE id=?", (transaction_id,))
        return transaction_id


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("command", choices=("record", "search", "propose", "evaluate", "promote", "rollback", "recover"))
    p.add_argument("--root", type=Path, default=forge.ROOT)
    p.add_argument("--ledger", type=Path, required=True)
    p.add_argument("--task", required=True); p.add_argument("--token", required=True)
    p.add_argument("--input", help="Repository-relative lesson/proposal JSON or evaluation config")
    p.add_argument("--approve-config-sha256", help="Explicit reviewed evaluator config, including runner and scenario hashes")
    p.add_argument("--query"); p.add_argument("--proposal"); p.add_argument("--evaluation")
    p.add_argument("--reviewer"); p.add_argument("--transaction")
    args = p.parse_args(argv)
    root = args.root.resolve()
    ledger = None
    try:
        ledger = forge.Ledger(args.ledger, root, forge.read_json(root / "production/plan.json"))
        learning = Learning(root, ledger, args.task, args.token)
        if args.command == "record": result = learning.record(forge.read_json(forge.inside(root, args.input)))
        elif args.command == "search": result = learning.search(args.query)
        elif args.command == "propose":
            value = forge.read_json(forge.inside(root, args.input))
            result = learning.propose(value["target"], value["candidate"], value["lessons"], value["training"])
        elif args.command == "evaluate":
            ref = {"path": args.input, "sha256": args.approve_config_sha256}
            artifact(root, ref)
            result = learning.evaluate(args.proposal, args.reviewer, ref)
        elif args.command == "promote": result = learning.promote(args.proposal, args.evaluation, args.reviewer)
        elif args.command == "rollback": result = learning.rollback(args.transaction)
        else: result = learning.recover(args.transaction)
        print(canonical({"result": result, "scope": "LOCAL_LEARNING_NOT_GAME_ACCEPTANCE"}))
        return 0
    except (ValueError, OSError, KeyError, TypeError, sqlite3.Error) as exc:
        print(f"LEARNING_ERROR: {exc}", file=sys.stderr)
        return 2
    finally:
        if ledger: ledger.close()


if __name__ == "__main__":
    raise SystemExit(main())
