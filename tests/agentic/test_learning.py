"""Real offline subprocess fixtures, never model/Studio/behavior-quality proof."""
from pathlib import Path
import copy
import json
import os
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/agentic"))
import forge
import learning

SKILL = "---\nname: fixture-skill\ndescription: Local fixture only\n---\nHandle a benign request.\n"
RUNNER = '''import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--candidate');p.add_argument('--scenario');a=p.parse_args()
candidate=Path(a.candidate).read_bytes();scenario=Path(a.scenario).read_bytes()
s=json.loads(scenario)
# Deterministic procedural fixture. Tests verify transport/gates, not an LLM.
rule=json.loads(candidate.decode().split('<!--fixture-rules:')[1].split('-->')[0])
action=s['input']['action']
observed='REFUSED' if action in rule['denied'] else rule['actions'].get(action,'UNKNOWN')
print(json.dumps({'candidateSha256':hashlib.sha256(candidate).hexdigest(),
 'scenarioSha256':hashlib.sha256(scenario).hexdigest(),'observed':observed}))
'''


class LearningTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(); self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name).resolve()
        self.target = ".agents/skills/fixture-skill/SKILL.md"
        self.write(self.target, SKILL)
        self.write("AGENTS.md", "Fixture scope; no publishing or spending.")
        self.write(".gitignore", "build/\nproduction/learning/\n")
        self.task = {"id": "learn", "skill": "fixture-skill", "environment": "local", "dependsOn": [],
            "writeScopes": ["production/learning", self.target], "checks": ["local"], "title": "Fixture", "brief": "No model"}
        self.plan = {"schemaVersion": 1, "tasks": [self.task]}
        forge.save_json(self.root / "production/plan.json", self.plan)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        self.commit()
        self.ledger = forge.Ledger(self.root / "build/shared.sqlite3", self.root, self.plan)
        self.addCleanup(self.ledger.close)
        self.token = self.ledger.claim("learn", "writer")
        self.loop = learning.Learning(self.root, self.ledger, "learn", self.token)
        self.write("build/proof.txt", "Observed deterministic fixture correction; not game proof.")
        self.lesson = {"outcome": "failure", "context": "fixture-request", "observation": "Unknown action",
            "correction": "Handle explicit requests while refusing publishing", "limit": "Only a fixture",
            "tags": ["tooling", "fixture"], "evidence": [self.ref("build/proof.txt")]}
        self.lesson_id = self.loop.record(self.lesson)
        self.write("build/runner.py", RUNNER)
        self.scenarios = []
        for number, (action, expected, split) in enumerate((("inspect", "INSPECTED", "train"),
                ("preview", "PREVIEWED", "holdout"), ("publish", "REFUSED", "refusal"))):
            rel = f"build/scenario-{number}.json"
            forge.save_json(self.root / rel, {"id": f"case-{number}", "input": {"action": action}, "expected": expected})
            self.scenarios.append({"split": split, "scenario": self.ref(rel)})
        candidate = SKILL + '<!--fixture-rules:' + json.dumps({"actions": {"inspect": "INSPECTED", "preview": "PREVIEWED"},
            "denied": ["publish", "spend"]}) + '-->\n'
        self.write("build/candidate.md", candidate)

    def write(self, rel, data):
        path = self.root / rel; path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(data, encoding="utf-8", newline="\n")
        return path

    def ref(self, rel):
        return learning.reference(self.root, rel)

    def commit(self):
        subprocess.run(["git", "-C", str(self.root), "add", "."], check=True)
        subprocess.run(["git", "-C", str(self.root), "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                        "commit", "-qm", "offline fixture"], check=True)

    def propose(self):
        return self.loop.propose(self.target, self.ref("build/candidate.md"), [self.lesson_id], [self.scenarios[0]["scenario"]])

    def config(self, mutate=None):
        value = {"runner": self.ref("build/runner.py"), "permissionsPreserved": True,
                 "reviewNotes": "Fixture reviewer exercises procedural rules, no live actions.",
                 "timeoutSeconds": 5, "cases": copy.deepcopy(self.scenarios)}
        if mutate: mutate(value)
        forge.save_json(self.root / "build/config.json", value)
        return self.ref("build/config.json")

    def evaluated(self):
        proposal = self.propose()
        evaluation = self.loop.evaluate(proposal, "reviewer", self.config())
        self.assertTrue(self.loop.get(evaluation, "evaluation")["passed"])
        return proposal, evaluation

    def test_record_search_preserves_limits_and_refuses_changed_evidence(self):
        found = self.loop.search("publishing")
        self.assertEqual(found[0]["id"], self.lesson_id)
        self.assertEqual(found[0]["lesson"]["acceptance"], "OBSERVED_LESSON_NOT_GAME_ACCEPTANCE")
        self.write("build/proof.txt", "tampered")
        with self.assertRaisesRegex(ValueError, "changed artifact"): self.loop.search("publishing")

    def test_missing_or_empty_lesson_evidence_refused(self):
        for refs in ([], [{"path": "build/missing", "sha256": "0" * 64}]):
            value = copy.deepcopy(self.lesson); value["evidence"] = refs
            with self.assertRaises(ValueError): self.loop.record(value)

    def test_propose_leaves_skill_unchanged(self):
        self.propose()
        self.assertEqual((self.root / self.target).read_text(), SKILL)

    def test_real_evaluation_promotion_exact_rollback(self):
        proposal, evaluation = self.evaluated()
        old = (self.root / self.target).read_bytes()
        transaction = self.loop.promote(proposal, evaluation, "reviewer")
        self.assertEqual((self.root / self.target).read_bytes(), (self.root / "build/candidate.md").read_bytes())
        rollback = self.loop.rollback(transaction)
        self.assertEqual((self.root / self.target).read_bytes(), old)
        self.assertEqual(self.loop._journal(rollback)[1], "ROLLED_BACK")
        with self.assertRaises(ValueError): self.loop.rollback(transaction)

    def test_distinct_reviewer_and_explicit_permission_assessment(self):
        proposal = self.propose()
        for actor in ("writer", " WRITER "):
            with self.assertRaises(ValueError): self.loop.evaluate(proposal, actor, self.config())
        with self.assertRaises(ValueError):
            self.loop.evaluate(proposal, "reviewer", self.config(lambda c: c.update(permissionsPreserved=False)))

    def test_missing_holdout_or_refusal_prevents_evaluation(self):
        proposal = self.propose()
        with self.assertRaises(ValueError):
            self.loop.evaluate(proposal, "reviewer", self.config(lambda c: c["cases"].pop()))

    def test_renamed_training_input_is_not_holdout(self):
        proposal = self.propose()
        scenario = {"id": "renamed", "input": {"action": "inspect"}, "expected": "INSPECTED"}
        forge.save_json(self.root / "build/renamed.json", scenario)
        with self.assertRaisesRegex(ValueError, "distinct IDs and inputs"):
            self.loop.evaluate(proposal, "reviewer", self.config(lambda c: c["cases"][1].update(scenario=self.ref("build/renamed.json"))))

    def test_failed_refusal_blocks_promotion(self):
        self.write("build/candidate.md", SKILL + '<!--fixture-rules:{"actions":{"inspect":"INSPECTED","preview":"PREVIEWED","publish":"PUBLISHED"},"denied":[]}-->\n')
        proposal = self.propose()
        evaluation = self.loop.evaluate(proposal, "reviewer", self.config())
        self.assertFalse(self.loop.get(evaluation, "evaluation")["passed"])
        with self.assertRaises(ValueError): self.loop.promote(proposal, evaluation, "reviewer")
        self.assertEqual((self.root / self.target).read_text(), SKILL)

    def test_stale_baseline_and_policy_refused(self):
        proposal, evaluation = self.evaluated()
        self.write(self.target, SKILL + "Other worker's edit.\n")
        with self.assertRaisesRegex(ValueError, "baseline"): self.loop.promote(proposal, evaluation, "reviewer")
        self.write(self.target, SKILL)
        self.write("AGENTS.md", "Updated permissions")
        with self.assertRaisesRegex(ValueError, "permission contract"): self.loop.promote(proposal, evaluation, "reviewer")

    def test_changed_head_refused_even_with_same_target(self):
        proposal, evaluation = self.evaluated()
        self.write("other.md", "new commit"); self.commit()
        with self.assertRaisesRegex(ValueError, "Stale HEAD"): self.loop.promote(proposal, evaluation, "reviewer")

    def test_expired_lease_prevents_every_mutation(self):
        proposal, evaluation = self.evaluated()
        self.ledger.db.execute("UPDATE jobs SET expires=0 WHERE id='learn'")
        with self.assertRaises(ValueError): self.loop.promote(proposal, evaluation, "reviewer")
        with self.assertRaises(ValueError): self.loop.record(self.lesson)

    def test_record_and_raw_stream_tampering_prevents_promotion(self):
        proposal, evaluation = self.evaluated()
        result = self.loop.get(evaluation, "evaluation")["results"][0]
        self.write(result["logs"][0]["path"], '{"observed":"fake"}')
        with self.assertRaises(ValueError): self.loop.promote(proposal, evaluation, "reviewer")
        self.ledger.db.execute("UPDATE learning_records SET body='{}' WHERE id=?", (proposal,))
        with self.assertRaisesRegex(ValueError, "tampered"): self.loop.get(proposal)

    def test_candidate_and_runner_tampering_refused(self):
        proposal, evaluation = self.evaluated()
        self.write("build/runner.py", "print('changed')")
        with self.assertRaises(ValueError): self.loop.promote(proposal, evaluation, "reviewer")
        self.write("build/runner.py", RUNNER)
        rel = self.loop.get(proposal)["candidate"]["path"]
        self.write(rel, SKILL + "altered\n")
        with self.assertRaises(ValueError): self.loop.promote(proposal, evaluation, "reviewer")

    def test_scope_path_escapes_and_protected_files_refused(self):
        for rel in ("../SKILL.md", "C:/x", ".git/config", "src/game.luau", ".agents/skills/fixture-skill/references/x.md"):
            with self.subTest(path=rel), self.assertRaises(ValueError):
                self.loop.propose(rel, self.ref("build/candidate.md"), [self.lesson_id], [self.scenarios[0]["scenario"]])
        other = ".agents/skills/other-skill/SKILL.md"
        self.write(other, SKILL.replace("fixture-skill", "other-skill"))
        with self.assertRaisesRegex(ValueError, "permission scope"):
            self.loop.propose(other, self.ref("build/candidate.md"), [self.lesson_id], [self.scenarios[0]["scenario"]])

    def test_symlink_escape_refused(self):
        with tempfile.TemporaryDirectory() as outside:
            link = self.root / "build/link"
            try: link.symlink_to(outside, target_is_directory=True)
            except OSError: self.skipTest("Windows symlink privilege unavailable")
            with self.assertRaises(ValueError): self.ref("build/link/x.md")

    def test_permission_scope_requires_learning_store_authority(self):
        self.ledger.tasks["learn"]["writeScopes"] = [self.target]
        with self.assertRaisesRegex(ValueError, "permission scope"):
            learning.Learning(self.root, self.ledger, "learn", self.token)

    @unittest.skipUnless(os.name == "nt", "Windows junction fixture")
    def test_internal_junction_cannot_alias_another_skill_scope(self):
        destination = self.root / ".agents/skills/other-skill"
        destination.mkdir()
        (destination / "SKILL.md").write_text(SKILL)
        original_dir = self.root / ".agents/skills/fixture-skill"
        (original_dir / "SKILL.md").unlink(); original_dir.rmdir()
        result = subprocess.run(["cmd", "/c", "mklink", "/J", str(original_dir), str(destination)], capture_output=True)
        if result.returncode: self.skipTest("Junction creation unavailable")
        try:
            with self.assertRaisesRegex(ValueError, "aliases/junctions"):
                self.loop._write(self.target, b"unauthorized alias edit")
            self.assertEqual((destination / "SKILL.md").read_text(), SKILL)
        finally:
            # Remove the junction itself, never recurse into its target.
            os.rmdir(original_dir)

    def test_later_edit_blocks_rollback(self):
        proposal, evaluation = self.evaluated()
        transaction = self.loop.promote(proposal, evaluation, "reviewer")
        self.write(self.target, "Unrelated new work")
        with self.assertRaisesRegex(ValueError, "Later skill edit"): self.loop.rollback(transaction)
        self.assertEqual((self.root / self.target).read_text(), "Unrelated new work")

    def test_aba_bytes_match_does_not_authorize_older_rollback(self):
        proposal, evaluation = self.evaluated()
        first = self.loop.promote(proposal, evaluation, "reviewer")
        first_bytes = (self.root / self.target).read_bytes()
        self.write("build/candidate.md", first_bytes.decode() + "Later reviewed correction.\n")
        proposal, evaluation = self.evaluated()
        second = self.loop.promote(proposal, evaluation, "reviewer")
        self.write("build/candidate.md", first_bytes.decode())
        proposal, evaluation = self.evaluated()
        latest = self.loop.promote(proposal, evaluation, "reviewer")
        self.assertEqual((self.root / self.target).read_bytes(), first_bytes)
        with self.assertRaisesRegex(ValueError, "lineage"): self.loop.rollback(first)
        self.assertEqual(self.loop._journal(latest)[1], "PROMOTED")
        self.assertEqual(self.loop._journal(latest)[0]["previousTransactionId"], second)
        self.loop.rollback(latest)
        self.assertIn("Later reviewed correction.", (self.root / self.target).read_text())

    def test_renamed_supporting_lesson_input_is_not_fresh_holdout(self):
        forge.save_json(self.root / "build/already-known.json", {"id": "already-seen",
            "input": {"action": "preview"}, "expected": "PREVIEWED"})
        lesson = copy.deepcopy(self.lesson); lesson["evidence"] = [self.ref("build/already-known.json")]
        self.lesson_id = self.loop.record(lesson)
        proposal = self.propose()
        with self.assertRaisesRegex(ValueError, "already exposed"):
            self.loop.evaluate(proposal, "reviewer", self.config())

    def test_os_replace_failure_keeps_original_and_records_failure(self):
        proposal, evaluation = self.evaluated()
        with patch.object(learning.os, "replace", side_effect=OSError("fixture disk failure")):
            with self.assertRaises(OSError): self.loop.promote(proposal, evaluation, "reviewer")
        self.assertEqual((self.root / self.target).read_text(), SKILL)
        self.assertEqual(self.ledger.db.execute("SELECT state FROM learning_journal").fetchone()[0], "FAILED_RESTORED")

    def test_crash_journal_needs_explicit_recovery(self):
        proposal, evaluation = self.evaluated()
        original_write = self.loop._write
        def crash(rel, data):
            original_write(rel, data)
            raise KeyboardInterrupt("fixture crash after replace")
        with patch.object(self.loop, "_write", side_effect=crash):
            with self.assertRaises(KeyboardInterrupt): self.loop.promote(proposal, evaluation, "reviewer")
        row = self.ledger.db.execute("SELECT id,state FROM learning_journal").fetchone()
        self.assertEqual(row["state"], "PREPARED")
        self.loop.recover(row["id"])
        self.assertEqual((self.root / self.target).read_text(), SKILL)
        self.assertEqual(self.loop._journal(row["id"])[1], "RECOVERED_NOT_PROMOTED")

    def test_evaluator_exception_is_failed_not_acceptance(self):
        self.write("build/runner.py", "raise SystemExit(7)\n")
        proposal = self.propose()
        evaluation = self.loop.evaluate(proposal, "reviewer", self.config())
        self.assertFalse(self.loop.get(evaluation)["passed"])
        with self.assertRaises(ValueError): self.loop.promote(proposal, evaluation, "reviewer")

    def test_evaluator_input_mutation_fails_without_touching_original_candidate(self):
        self.write("build/runner.py", RUNNER + '\nPath(a.candidate).write_text("modified by evaluator")\n')
        original = (self.root / "build/candidate.md").read_bytes()
        proposal = self.propose()
        evaluation = self.loop.evaluate(proposal, "reviewer", self.config())
        self.assertFalse(self.loop.get(evaluation)["passed"])
        self.assertEqual((self.root / "build/candidate.md").read_bytes(), original)
        self.assertEqual((self.root / self.target).read_text(), SKILL)

    def test_recovery_refuses_unrelated_edit_and_journal_tampering(self):
        proposal, evaluation = self.evaluated()
        original_write = self.loop._write
        def crash(rel, data):
            original_write(rel, data)
            raise KeyboardInterrupt()
        with patch.object(self.loop, "_write", side_effect=crash):
            with self.assertRaises(KeyboardInterrupt): self.loop.promote(proposal, evaluation, "reviewer")
        transaction = self.ledger.db.execute("SELECT id FROM learning_journal").fetchone()[0]
        self.write(self.target, "Other worker changed the skill")
        with self.assertRaisesRegex(ValueError, "Unrelated edit"): self.loop.recover(transaction)
        self.assertEqual((self.root / self.target).read_text(), "Other worker changed the skill")
        self.ledger.db.execute("UPDATE learning_journal SET body='{}' WHERE id=?", (transaction,))
        with self.assertRaisesRegex(ValueError, "tampered"): self.loop.recover(transaction)

    def test_forge_release_appends_handoff_without_success(self):
        self.ledger.release("learn", self.token)
        event = self.ledger.learning_handoffs()[0]["handoff"]
        self.assertEqual(event["event"], "RELEASED")
        self.assertFalse(event["evidenceValidatedAtEvent"])
        self.assertEqual(self.ledger.rows()[0]["state"], "PLANNED")
        with self.assertRaises(ValueError): self.loop.record(self.lesson)

    def test_forge_accept_handoff_atomic_with_acceptance(self):
        proof = self.ref("build/proof.txt")
        commit = forge.git_evidence.head(self.root)
        packet = {"taskId": "learn", "environment": "local", "buildCommit": commit,
            "sourceTree": forge.git_evidence.validate_commit(self.root, commit), "planSha256": self.ledger.plan_hash,
            "checks": {"local": "PASS"}, "invocation": {"tool": "fixture", "runId": "fixture",
                "buildCommit": commit, "exitCode": 0, "logs": [proof["path"]]}, "artifacts": [proof]}
        self.ledger.submit("learn", self.token, packet)
        for reviewer in ("writer", " WRITER ", "Writer"):
            with self.assertRaises(ValueError): self.ledger.accept("learn", reviewer)
        self.assertEqual(self.ledger.learning_handoffs(), [])
        self.ledger.accept("learn", "reviewer")
        event = self.ledger.learning_handoffs()[0]["handoff"]
        self.assertTrue(event["evidenceValidatedAtEvent"])
        self.assertEqual(event["status"], "NEEDS_EVIDENCE_BACKED_LESSON")
        self.assertEqual(self.ledger.rows()[0]["state"], "ACCEPTED")


if __name__ == "__main__": unittest.main()
