#!/usr/bin/env python3
"""Offline role adapters and guarded handoffs for Guildborne's shared Forge ledger.

This module never starts models or interactive applications and never accepts
production evidence. A generated role is an instruction document, not a worker.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import sqlite3
import sys
import tempfile
import time
import tomllib

sys.path.insert(0, str(Path(__file__).resolve().parent))
import forge
import git_evidence

ROOT = Path(__file__).resolve().parents[2]
SPEC = "production/studio/studio.json"
PLAN = "production/plan.json"
MANIFEST = "production/studio/generated-manifest.json"
CATALOG = "production/studio/catalog.json"
TIERS = {"director": None, "lead": "director", "specialist": "lead"}
COMMON = (
    "Read AGENTS.md, README.md, production/README.md, production/LATEST_GOALS.md, "
    "production/EXECUTION_V2.md, production/MERGE_READINESS.md and the matching "
    "production/SPECIALIST_PLAYBOOK.md section before implementation. Inspect actual "
    "src/client, src/server and src/shared plus later docs/uat01 reports. "
    "Use the task's exact Forge writeScopes, not this role's department as permission. "
    "Claim before writing and recheck the active lease before writes and integration. "
    "All workers use one shared coordinator ledger; serialize Studio/Blender ownership. "
    "Expired leases require confirmation that the prior worker stopped and explicit release. "
    "Delegate only through actual available host capabilities; otherwise work sequentially. "
    "Never infer connected tools from installed executables. No automatic publishing, paid "
    "uploads, spending, production DataStore writes, commerce activation, force-push or merge. "
    "Keep PLANNED, generated, Blender-validated, Roblox-imported, Studio-tested, physical "
    "device, cross-server and human acceptance distinct; runtime IDs remain null until "
    "real import. Server authority and market conservation/fencing must be preserved. "
    "Report changes, actual checks, hashes, blockers and next owner for independent review."
)


def _json(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2, allow_nan=False) + "\n"


def _hash(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def _text(value, label):
    if (not isinstance(value, str) or not value.strip() or "\x00" in value
            or any(0xD800 <= ord(char) <= 0xDFFF for char in value)):
        raise ValueError(f"{label} must be nonempty text")


def _slug(value, label):
    if not isinstance(value, str) or not forge.SLUG.fullmatch(value) or len(value) > 64:
        raise ValueError(f"Invalid {label}: {value!r}")
    # Slugs also become directory names on Windows.
    forge.relative_path(value)


def _unique(values, label):
    if not isinstance(values, list) or any(not isinstance(v, str) for v in values):
        raise ValueError(f"{label} must be an array of strings")
    if len(values) != len(set(values)):
        raise ValueError(f"Duplicate {label}")


def _objects(items, label):
    if not isinstance(items, list):
        raise ValueError(f"{label} must be an array")
    result = {}
    for item in items:
        if not isinstance(item, dict):
            raise ValueError(f"{label} entries must be objects")
        key = item.get("id")
        _slug(key, f"{label} ID")
        if key in result:
            raise ValueError(f"Duplicate {label} ID: {key}")
        result[key] = item
    return result


def _stages(steps):
    pending = dict(steps)
    done, stages = set(), []
    while pending:
        stage = sorted(k for k, v in pending.items() if set(v["dependsOn"]) <= done)
        if not stage:
            raise ValueError("Workflow dependency cycle")
        stages.append([pending.pop(key) for key in stage])
        done.update(stage)
    return stages


def load(root: Path):
    root = Path(root).resolve()
    spec = forge.read_json(forge.inside(root, SPEC))
    plan = forge.read_json(forge.inside(root, PLAN))
    validate(root, spec, plan)
    return spec, plan


def validate(root: Path, spec: dict, plan: dict):
    root = Path(root).resolve()
    if not isinstance(spec, dict) or type(spec.get("schemaVersion")) is not int or spec["schemaVersion"] != 1:
        raise ValueError("Studio requires schemaVersion=1")
    _text(spec.get("name"), "Studio name")
    upstream = spec.get("upstream")
    if not isinstance(upstream, dict):
        raise ValueError("Missing upstream adoption record")
    for field in ("url", "ref", "adoption"):
        _text(upstream.get(field), f"upstream.{field}")
    if not upstream["url"].startswith("https://"):
        raise ValueError("Upstream URL must use HTTPS")
    tasks = forge.validate_plan(plan)
    forge.validate_skills(root, plan)
    roles = _objects(spec.get("roles"), "roles")
    if not roles:
        raise ValueError("Studio requires roles")
    directors = [r for r in roles.values() if r.get("tier") == "director"]
    if not directors:
        raise ValueError("Studio requires at least one director")
    for role in roles.values():
        for field in ("title", "department", "instructions"):
            _text(role.get(field), f"{role['id']}.{field}")
        tier = role.get("tier")
        if not isinstance(tier, str) or tier not in TIERS:
            raise ValueError(f"Unknown role tier: {tier}")
        parent = role.get("parent")
        if tier == "director":
            if parent is not None:
                raise ValueError("Director must not have a parent")
        elif not isinstance(parent, str) or parent not in roles or roles[parent].get("tier") != TIERS[tier]:
            raise ValueError(f"Invalid hierarchy parent for {role['id']}")
        _unique(role.get("skills"), f"{role['id']}.skills")
        if not role["skills"]:
            raise ValueError(f"Role needs skills: {role['id']}")
        for skill in role["skills"]:
            _slug(skill, "skill")
            path = forge.inside(root, f".agents/skills/{skill}/SKILL.md")
            if not path.is_file():
                raise ValueError(f"Missing canonical skill: {skill}")
        # Explicit traversal documents the cycle invariant, beyond tier checks.
        seen, current = set(), role
        while current is not None:
            if current["id"] in seen:
                raise ValueError("Role hierarchy cycle")
            seen.add(current["id"])
            current = roles.get(current.get("parent"))
    assignments = spec.get("taskRoles")
    if not isinstance(assignments, dict) or set(assignments) != set(tasks):
        raise ValueError("taskRoles must cover every Forge task exactly")
    for key, role_id in assignments.items():
        if not isinstance(role_id, str) or role_id not in roles:
            raise ValueError(f"Unknown task role: {key}")
        if tasks[key]["skill"] not in roles[role_id]["skills"]:
            raise ValueError(f"Task skill not mapped to owner role: {key}")
        for scope in tasks[key]["writeScopes"]:
            forge.inside(root, scope)
    gates = _objects(spec.get("gates"), "gates")
    for gate in gates.values():
        _text(gate.get("title"), "gate title")
        _text(gate.get("evidence"), "gate evidence")
        if gate.get("environment") not in forge.KINDS:
            raise ValueError(f"Unknown gate environment: {gate['id']}")
    workflows = _objects(spec.get("workflows"), "workflows")
    for flow in workflows.values():
        _text(flow.get("title"), "workflow title")
        if flow.get("lead") not in roles or roles[flow["lead"]]["tier"] not in ("director", "lead"):
            raise ValueError(f"Workflow needs a director or lead: {flow['id']}")
        _unique(flow.get("gates"), "workflow gates")
        if any(g not in gates for g in flow["gates"]):
            raise ValueError(f"Unknown workflow gate: {flow['id']}")
        steps = _objects(flow.get("steps"), "workflow steps")
        if not steps:
            raise ValueError("Workflow must contain steps")
        for step in steps.values():
            if step.get("role") not in roles or step.get("skill") not in roles[step["role"]]["skills"]:
                raise ValueError(f"Unknown step role/skill: {step['id']}")
            _unique(step.get("dependsOn"), "step dependencies")
            if any(dep not in steps for dep in step["dependsOn"]):
                raise ValueError(f"Missing workflow dependency: {step['id']}")
        _stages(steps)
    for rule in _objects(spec.get("rules"), "rules").values():
        _text(rule.get("instructions"), "path rule instructions")
        _unique(rule.get("paths"), "rule paths")
        if not rule["paths"]:
            raise ValueError("Path rules must specify paths")
        for path in rule["paths"]:
            if any(char in path for char in "*?[]"):
                raise ValueError("Path rules require relative prefixes, not glob patterns")
            forge.inside(root, path)
    return {"status": "PASS", "roleCount": len(roles), "taskCount": len(tasks), "workflowCount": len(workflows)}


def _rules(spec, scopes):
    return [rule for rule in spec["rules"] if any(forge.overlap(path, scope) for path in rule["paths"] for scope in scopes)]


def _prompt(root, spec, plan, role, task=None):
    tasks = [task] if task else [t for t in plan["tasks"] if spec["taskRoles"][t["id"]] == role["id"]]
    lines = [f"# {role['title']} ({role['id']})", COMMON, role["instructions"]]
    if role["parent"]:
        lines.append(f"Escalate dependencies, cross-scope changes and blocked gates to parent {role['parent']}. Parentage does not inherit write permission.")
    else:
        lines.append("Coordinate leads through the shared ledger and preserve external human acceptance gates.")
    lines.append("## Canonical skills")
    for skill in sorted(role["skills"]):
        path = f".agents/skills/{skill}/SKILL.md"
        lines.extend([f"### {skill} — {path}", forge.inside(root, path).read_text(encoding="utf-8-sig").strip()])
    lines.append("## Forge tasks (these scopes apply only after a valid task claim)")
    for assigned in sorted(tasks, key=lambda t: t["id"]):
        lines.extend([f"### {assigned['id']}: {assigned.get('title', assigned['id'])}", assigned.get("brief", ""),
                      f"Environment: {assigned['environment']}; skill: {assigned['skill']}",
                      "Write scopes: " + ", ".join(assigned["writeScopes"]),
                      "Required checks: " + ", ".join(assigned["checks"]),
                      "Dependencies: " + (", ".join(assigned["dependsOn"]) or "none")])
        for rule in _rules(spec, assigned["writeScopes"]):
            lines.append(f"Path rule {rule['id']}: {rule['instructions']}")
    if not tasks:
        lines.append("No directly assigned Forge task. Coordination and review do not authorize writing. Obtain an explicitly scoped task before implementation.")
    lines.append("## Evidence gates")
    for gate in sorted(spec["gates"], key=lambda g: g["id"]):
        lines.append(f"{gate['id']} ({gate['environment']}): {gate['evidence']}")
    return "\n\n".join(lines) + "\n"


def generated_files(root: Path, spec: dict, plan: dict):
    root = Path(root).resolve()
    validate(root, spec, plan)
    files = {}
    for role in sorted(spec["roles"], key=lambda r: r["id"]):
        prompt = _prompt(root, spec, plan, role)
        description = f"{role['title']}; {role['tier']} in {role['department']} for Guildborne."
        # JSON basic string escaping is compatible with TOML basic strings.
        # TOML forbids literal DEL even though JSON permits it. Escape it while
        # retaining ordinary non-ASCII text and JSON's other basic escapes.
        quote = lambda value: json.dumps(value, ensure_ascii=False).replace("\x7f", "\\u007f")
        files[f".codex/agents/{role['id']}.toml"] = (
            "# Generated by tools/agentic/studio.py; edit canonical sources.\n"
            f"name = {quote(role['id'])}\ndescription = {quote(description)}\n"
            f"developer_instructions = {quote(prompt)}\n"
        )
        tomllib.loads(files[f".codex/agents/{role['id']}.toml"])
        files[f".claude/agents/{role['id']}.md"] = (
            f"---\nname: {role['id']}\ndescription: {quote(description)}\n---\n\n{prompt}"
        )
    for skill in sorted({s for r in spec["roles"] for s in r["skills"]}):
        files[f".claude/skills/{skill}/SKILL.md"] = (
            f"---\nname: {skill}\ndescription: Use the canonical Guildborne {skill} instructions.\n---\n\n"
            f"Read and follow [canonical skill](../../../.agents/skills/{skill}/SKILL.md).\n"
            "Read AGENTS.md and claim exact Forge task scopes before writing. This adapter is generated; update the canonical skill.\n"
        )
    files[CATALOG] = _json({"schemaVersion": 1, "name": spec["name"], "upstream": spec["upstream"],
        "roles": [{**r, "codex": f".codex/agents/{r['id']}.toml", "claude": f".claude/agents/{r['id']}.md"}
                  for r in sorted(spec["roles"], key=lambda r: r["id"])],
        "taskRoles": spec["taskRoles"], "workflows": spec["workflows"], "gates": spec["gates"],
        "execution": "HOST_DELEGATION_REQUIRED_NO_AUTOMATIC_MODELS_OR_APPS"})
    if len(files) != len({path.casefold() for path in files}):
        raise ValueError("Generated path collision")
    return files


def _sources(root, spec, plan):
    paths = {SPEC, PLAN, "tools/agentic/studio.py", "AGENTS.md"}
    paths.update(f".agents/skills/{s}/SKILL.md" for role in spec["roles"] for s in role["skills"])
    result = {}
    for path in sorted(paths):
        source = forge.inside(root, path)
        if source.is_file():
            result[path] = forge.digest(source)
    # In-memory fixture/spec edits must also be visible to verification.
    return {"files": result, "specSha256": git_evidence.plan_hash(spec), "planSha256": git_evidence.plan_hash(plan)}


def _managed(path):
    forge.relative_path(path)
    return path == CATALOG or path.startswith((".codex/agents/", ".claude/agents/", ".claude/skills/"))


def _write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".studio-")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(text)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def generate(root: Path, spec: dict, plan: dict, check=False):
    root = Path(root).resolve()
    files = generated_files(root, spec, plan)
    manifest = {"schemaVersion": 1, "sources": _sources(root, spec, plan),
                "outputs": {path: _hash(text) for path, text in sorted(files.items())}}
    manifest_path = forge.inside(root, MANIFEST)
    old = forge.read_json(manifest_path) if manifest_path.exists() else None
    if old is not None:
        if not isinstance(old, dict) or old.get("schemaVersion") != 1 or not isinstance(old.get("outputs"), dict):
            raise ValueError("Malformed generated manifest")
        for path, digest in old["outputs"].items():
            if not isinstance(path, str) or not _managed(path) or not isinstance(digest, str) or len(digest) != 64:
                raise ValueError("Unsafe generated manifest ownership entry")
            target = forge.inside(root, path)
            if target.exists() and (not target.is_file() or forge.digest(target) != digest):
                raise ValueError(f"Changed managed output; preserve user edits: {path}")
        stale = set(old["outputs"]) - set(files)
        if stale:
            raise ValueError(f"Stale previously managed output requires explicit reconciliation: {sorted(stale)}")
    for path in files:
        target = forge.inside(root, path)
        if target.exists() and (old is None or path not in old["outputs"]):
            raise ValueError(f"Unmanaged output collision: {path}")
    # These role adapter directories are an explicit inventory, not a place to
    # silently retain deleted/renamed roles. Preserve extras for reconciliation.
    for directory in (".codex/agents", ".claude/agents", ".claude/skills"):
        folder = forge.inside(root, directory)
        if folder.exists():
            for candidate in folder.rglob("*"):
                relative = candidate.relative_to(root).as_posix()
                forge.inside(root, relative)
                if candidate.is_file() and relative not in files:
                    raise ValueError(f"Unexpected adapter output requires explicit reconciliation: {relative}")
    if check:
        if old != manifest:
            raise ValueError("Generated manifest or source metadata is stale")
        for path, digest in manifest["outputs"].items():
            target = forge.inside(root, path)
            if not target.is_file() or forge.digest(target) != digest:
                raise ValueError(f"Missing or stale generated output: {path}")
        return {"status": "PASS", "fileCount": len(files), "evidence": "GENERATED_FILES_ONLY_NOT_HOST_OR_GAME_ACCEPTANCE"}
    # Preflight every path before any mutation; no stale files are deleted.
    for path, content in files.items():
        _write(forge.inside(root, path), content)
    _write(manifest_path, _json(manifest))
    return {"status": "GENERATED", "fileCount": len(files), "manifest": MANIFEST,
            "evidence": "GENERATED_FILES_ONLY_NOT_HOST_OR_GAME_ACCEPTANCE"}


def verify(root: Path, spec: dict, plan: dict):
    return generate(root, spec, plan, check=True)


def _ledger(root, plan, ledger_path):
    original = Path(ledger_path).absolute()
    if any(path.is_symlink() for path in (original, *original.parents)):
        raise ValueError("Shared ledger symlink paths are not permitted")
    database = original.resolve()
    if not database.is_file():
        raise ValueError("An existing shared Forge ledger is required; initialize once through Forge")
    # Forge's constructor can initialize a database. Inspect read-only first so
    # a route cannot silently create a second ledger in an unrelated SQLite file.
    connection = None
    try:
        connection = sqlite3.connect(database.as_uri() + "?mode=ro", uri=True, timeout=10)
        fingerprint = connection.execute("SELECT value FROM meta WHERE key='plan'").fetchone()
        if not fingerprint or fingerprint[0] != git_evidence.plan_hash(plan):
            raise ValueError("Shared Forge ledger plan fingerprint mismatch")
        rows = connection.execute("SELECT id,state,owner,token,expires,evidence,reviewer FROM jobs").fetchall()
        if {row[0] for row in rows} != {task["id"] for task in plan["tasks"]}:
            raise ValueError("Shared Forge ledger task inventory mismatch")
    except sqlite3.Error as error:
        raise ValueError("Existing database is not a recognized shared Forge ledger") from error
    finally:
        if connection is not None:
            connection.close()
    return forge.Ledger(database, root, plan)


def route(root: Path, spec: dict, plan: dict, task_id: str, ledger_path: Path):
    root = Path(root).resolve()
    validate(root, spec, plan)
    tasks = forge.validate_plan(plan)
    if task_id not in tasks:
        raise ValueError(f"Unknown Forge task: {task_id}")
    task = tasks[task_id]
    roles = {r["id"]: r for r in spec["roles"]}
    role = roles[spec["taskRoles"][task_id]]
    ancestry, current = [], role
    while current:
        ancestry.append(current["id"])
        current = roles.get(current["parent"])
    ledger = _ledger(root, plan, ledger_path)
    try:
        rows = {row["id"]: row for row in ledger.rows()}
        row, blockers = rows[task_id], []
        if row["state"] != "PLANNED":
            blockers.append(f"Task state is {row['state']}; new claim is unavailable")
        if row["state"] == "ACTIVE" and row["expires"] <= time.time():
            blockers.append("Expired lease requires confirmed stopped worker and explicit release")
        for dep in task["dependsOn"]:
            if rows[dep]["state"] != "ACCEPTED":
                blockers.append(f"Dependency {dep} is {rows[dep]['state']}, not ACCEPTED")
        for other in rows.values():
            if other["id"] == task_id or other["state"] not in ("ACTIVE", "REVIEW"):
                continue
            other_task = tasks[other["id"]]
            if any(forge.overlap(a, b) for a in task["writeScopes"] for b in other_task["writeScopes"]):
                blockers.append(f"Write ownership conflict: {other['id']}")
            if task["environment"] in ("studio", "blender") and task["environment"] == other_task["environment"]:
                blockers.append(f"Exclusive {task['environment']} session busy: {other['id']}")
        status = "READY" if not blockers else (row["state"] if row["state"] != "PLANNED" else "BLOCKED")
        return {"taskId": task_id, "roleId": role["id"], "role": role["id"], "ancestry": ancestry,
                "skill": task["skill"], "skillPath": f".agents/skills/{task['skill']}/SKILL.md",
                "environment": task["environment"], "writeScopes": task["writeScopes"], "checks": task["checks"],
                "requiredChecks": task["checks"], "dependsOn": task["dependsOn"], "state": row["state"],
                "status": status, "ready": not blockers, "blockers": blockers,
                "owner": row["owner"], "leaseExpires": row["expires"], "ledger": str(Path(ledger_path).resolve()),
                "planSha256": ledger.plan_hash}
    finally:
        ledger.close()


def handoff(root: Path, spec: dict, plan: dict, task_id: str, ledger_path: Path,
            owner: str, token: str, paths=None):
    root = Path(root).resolve()
    routing = route(root, spec, plan, task_id, ledger_path)
    _text(owner, "owner")
    _text(token, "lease token")
    task = next(t for t in plan["tasks"] if t["id"] == task_id)
    if paths is not None:
        _unique(paths, "handoff paths")
        for path in paths:
            forge.inside(root, path)
            if not any(forge.contains_path(scope, path) for scope in task["writeScopes"]):
                raise ValueError(f"Handoff path outside task write scopes: {path}")
    ledger = _ledger(root, plan, ledger_path)
    try:
        lease = ledger.assert_lease(task_id, token)
        if lease["owner"] != owner:
            raise ValueError("Lease owner mismatch")
        # Dependencies may not be downgraded while an owner remains active.
        states = {r["id"]: r["state"] for r in ledger.rows()}
        if any(states[dep] != "ACCEPTED" for dep in task["dependsOn"]):
            raise ValueError("Task dependencies are not accepted")
        role = next(r for r in spec["roles"] if r["id"] == routing["roleId"])
        prompt = _prompt(root, spec, plan, role, task)
        commit = git_evidence.head(root)
        metadata = {"schemaVersion": 1, "status": "HANDOFF_ONLY_NOT_ACCEPTED", "taskId": task_id,
                    "roleId": role["id"], "owner": owner, "buildCommit": commit,
                    "planSha256": ledger.plan_hash, "specSha256": git_evidence.plan_hash(spec),
                    "skill": task["skill"], "writeScopes": task["writeScopes"], "checks": task["checks"],
                    "environment": task["environment"], "ledger": str(Path(ledger_path).resolve()),
                    "requestedPaths": paths or [], "sourceMetadata": _sources(root, spec, plan)}
        prompt = _json(metadata) + "\n" + prompt
        metadata["promptSha256"] = _hash(prompt)
        relative = f"build/agentic/studio/handoffs/{task_id}/{metadata['promptSha256']}.md"
        target = forge.inside(root, relative)
        # Do not export tracked source or overwrite a hand-edited local packet.
        if git_evidence.git(root, "check-ignore", "--", relative) != relative:
            raise ValueError("Handoff destination must be Git-ignored")
        if target.exists() and forge.digest(target) != metadata["promptSha256"]:
            raise ValueError("Existing handoff prompt differs from hash")
        ledger.assert_lease(task_id, token)
        _write(target, prompt)
        metadata["promptPath"] = relative
        return metadata
    finally:
        ledger.close()


def workflow(root: Path, spec: dict, workflow_id: str):
    # Validate references without requiring a task plan argument in this public API.
    plan = forge.read_json(forge.inside(Path(root), PLAN))
    validate(root, spec, plan)
    flows = {f["id"]: f for f in spec["workflows"]}
    if workflow_id not in flows:
        raise ValueError(f"Unknown workflow: {workflow_id}")
    flow = flows[workflow_id]
    gates = {g["id"]: g for g in spec["gates"]}
    return {"id": flow["id"], "title": flow["title"], "lead": flow["lead"],
            "stages": _stages({s["id"]: s for s in flow["steps"]}),
            "gates": [gates[g] for g in flow["gates"]], "execution": "HOST_DELEGATION_REQUIRED"}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("validate", "generate", "verify", "status", "route", "handoff", "workflow"))
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--ledger", type=Path, help="Existing shared Forge coordinator ledger, including across worktrees")
    parser.add_argument("--task")
    parser.add_argument("--owner")
    parser.add_argument("--token")
    parser.add_argument("--path", action="append", help="Optional repository-relative handoff write path")
    parser.add_argument("--workflow")
    args = parser.parse_args(argv)
    try:
        root = args.root.resolve()
        spec, plan = load(root)
        ledger = args.ledger or root / "build/agentic/ledger.sqlite3"
        if args.command == "validate":
            report = validate(root, spec, plan)
        elif args.command == "generate":
            report = generate(root, spec, plan)
        elif args.command == "verify":
            report = verify(root, spec, plan)
        elif args.command == "status":
            report = {"tasks": [route(root, spec, plan, task["id"], ledger) for task in plan["tasks"]]}
        elif args.command == "route":
            report = route(root, spec, plan, args.task, ledger)
        elif args.command == "handoff":
            report = handoff(root, spec, plan, args.task, ledger, args.owner, args.token, args.path)
        else:
            report = workflow(root, spec, args.workflow)
        print(_json(report), end="")
        return 0
    except (ValueError, OSError, TypeError, KeyError) as error:
        print(_json({"status": "ERROR", "error": str(error)}), end="", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
