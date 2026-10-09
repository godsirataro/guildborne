#!/usr/bin/env python3
"""Offline Guildborne production planning and evidence ledger. Never runs a model/API."""
from __future__ import annotations
import argparse
import hashlib
import json
import math
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import sqlite3
import tempfile
import time
import uuid
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import git_evidence

SLUG = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
ROOT = Path(__file__).resolve().parents[2]
KINDS = {"local", "studio", "blender", "image", "audio", "device", "cross_server"}


def reject_constant(value):
    raise ValueError(f"Non-finite JSON value: {value}")


def unique_pairs(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"Duplicate JSON key: {key}")
        result[key] = value
    return result


def read_json(path: Path):
    if path.stat().st_size > 16 * 1024 * 1024:
        raise ValueError(f"JSON exceeds 16 MiB: {path}")
    return json.loads(path.read_text(encoding="utf-8-sig"), parse_constant=reject_constant,
                      object_pairs_hook=unique_pairs)


def relative_path(value: str) -> PurePosixPath:
    if not isinstance(value, str) or not value or "\\" in value or ":" in value or "\x00" in value:
        raise ValueError(f"Invalid project path: {value!r}")
    p = PurePosixPath(value)
    if p.is_absolute() or ".." in p.parts or ".git" in p.parts or value.startswith("~"):
        raise ValueError(f"Unsafe project path: {value}")
    if p.as_posix() == ".":
        raise ValueError("Repository-root write scope is not allowed")
    return p


def inside(root: Path, value: str) -> Path:
    p = root / relative_path(value)
    if not p.resolve().is_relative_to(root.resolve()):
        raise ValueError(f"Path escapes repository: {value}")
    return p


def digest(path: Path) -> str:
    with path.open("rb") as f:
        return hashlib.file_digest(f, "sha256").hexdigest()


def save_json(path: Path, value):
    data = json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n"
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(dir=path.parent, prefix=".forge-")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as f:
            f.write(data)
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def overlap(a: str, b: str) -> bool:
    pa, pb = relative_path(a.casefold()), relative_path(b.casefold())
    return pa == pb or pa in pb.parents or pb in pa.parents


def validate_plan(plan):
    if plan.get("schemaVersion") != 1 or not isinstance(plan.get("tasks"), list) or not plan["tasks"]:
        raise ValueError("Expected a nonempty schemaVersion=1 task plan")
    ids = set()
    for task in plan["tasks"]:
        key = task.get("id", "")
        if not SLUG.fullmatch(key) or key in ids:
            raise ValueError(f"Invalid or duplicate task ID: {key}")
        ids.add(key)
        if task.get("environment") not in KINDS:
            raise ValueError(f"Unknown environment in {key}")
        if not SLUG.fullmatch(task.get("skill", "")):
            raise ValueError(f"Invalid skill in {key}")
        for field in ("dependsOn", "writeScopes", "checks"):
            if not isinstance(task.get(field), list):
                raise ValueError(f"{key}.{field} must be an array")
        if not task["writeScopes"] or not task["checks"]:
            raise ValueError(f"{key}: write scopes and acceptance checks are required")
        if len(set(task["checks"])) != len(task["checks"]):
            raise ValueError(f"{key}: duplicate check IDs")
        for scope in task["writeScopes"]:
            relative_path(scope)
        if any(not isinstance(c, str) or not SLUG.fullmatch(c) for c in task["checks"]):
            raise ValueError(f"{key}: invalid check ID")
    visited, visiting = set(), set()
    by_id = {t["id"]: t for t in plan["tasks"]}
    def visit(key):
        if key not in ids:
            raise ValueError(f"Missing dependency: {key}")
        if key in visiting:
            raise ValueError(f"Dependency cycle: {key}")
        if key in visited:
            return
        visiting.add(key)
        for dep in by_id[key]["dependsOn"]:
            visit(dep)
        visiting.remove(key)
        visited.add(key)
    for key in sorted(ids):
        visit(key)
    return by_id


def validate_skills(root: Path, plan):
    names = set()
    for path in sorted((root / ".agents/skills").glob("*/SKILL.md")):
        text = path.read_text(encoding="utf-8")
        if not text.startswith("---\n") or "\n---\n" not in text[4:]:
            raise ValueError(f"Missing skill frontmatter: {path}")
        front = text.split("---", 2)[1]
        name = re.search(r"^name: ([a-z0-9-]+)$", front, re.M)
        desc = re.search(r"^description: (.+)$", front, re.M)
        if not name or not SLUG.fullmatch(name[1]) or name[1] != path.parent.name:
            raise ValueError(f"Skill folder/name mismatch: {path}")
        if len(name[1]) > 64 or not desc or not 1 <= len(desc[1]) <= 1024:
            raise ValueError(f"Invalid skill metadata: {path}")
        if name[1] in names:
            raise ValueError(f"Duplicate skill: {name[1]}")
        names.add(name[1])
    missing = {t["skill"] for t in plan["tasks"]} - names
    if missing:
        raise ValueError(f"Missing executable skill instructions: {sorted(missing)}")
    return len(names)


def evidence_packet(root: Path, task, packet):
    """Validate commit/tree identity and recorded evidence; independent review remains required."""
    if packet.get("taskId") != task["id"] or packet.get("environment") != task["environment"]:
        raise ValueError("Evidence task/environment mismatch")
    if not re.fullmatch(r"[0-9a-f]{40}", packet.get("buildCommit", "")) or packet.get("buildCommit") == "0" * 40:
        raise ValueError("Evidence requires a real 40-character build commit")
    if not isinstance(packet.get("checks"), dict) or set(packet["checks"]) != set(task["checks"]):
        raise ValueError("Every required check must be explicitly reported")
    if any(value != "PASS" for value in packet["checks"].values()):
        raise ValueError("Non-passing checks cannot be submitted as complete")
    git_evidence.validate_identity(root, packet)
    artifacts = packet.get("artifacts")
    if not isinstance(artifacts, list) or not artifacts:
        raise ValueError("Evidence artifacts are required")
    seen = set()
    for artifact in artifacts:
        rel = artifact.get("path", "")
        p = inside(root, rel)
        if rel in seen or not p.is_file() or p.stat().st_size == 0:
            raise ValueError(f"Missing, empty or duplicate evidence: {rel}")
        seen.add(rel)
        if artifact.get("sha256") != digest(p):
            raise ValueError(f"Evidence hash mismatch: {rel}")
    if task["environment"] == "cross_server":
        jobs = packet.get("serverJobIds", [])
        if not isinstance(jobs, list) or any(not isinstance(j, str) or not j.strip() for j in jobs) or len(set(jobs)) < 2:
            raise ValueError("Cross-server evidence needs distinct nonempty JobIds")
    if task["environment"] == "device" and not packet.get("deviceModel"):
        raise ValueError("Physical-device evidence needs deviceModel")
    return packet


class Ledger:
    """Cooperative local coordinator; not a sandbox or distributed game datastore."""
    def __init__(self, database: Path, root: Path, plan):
        self.root = root
        self.tasks = validate_plan(plan)
        self.plan_hash = git_evidence.plan_hash(plan)
        database.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(database, timeout=10, isolation_level=None)
        self.db.row_factory = sqlite3.Row
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)")
        self.db.execute("CREATE TABLE IF NOT EXISTS jobs (id TEXT PRIMARY KEY, state TEXT NOT NULL, owner TEXT, token TEXT, expires REAL, evidence TEXT, reviewer TEXT)")
        fingerprint = hashlib.sha256(json.dumps(plan, sort_keys=True, allow_nan=False).encode()).hexdigest()
        self.db.execute("BEGIN IMMEDIATE")
        try:
            old = self.db.execute("SELECT value FROM meta WHERE key='plan'").fetchone()
            if old and old["value"] != fingerprint:
                raise ValueError("Plan changed: use a new ledger; do not reset active work")
            self.db.execute("INSERT OR IGNORE INTO meta VALUES ('plan', ?)", (fingerprint,))
            for key in self.tasks:
                self.db.execute("INSERT OR IGNORE INTO jobs(id,state) VALUES (?, 'PLANNED')", (key,))
            self.db.execute("COMMIT")
        except Exception:
            self.db.execute("ROLLBACK")
            self.db.close()
            raise

    def close(self):
        self.db.close()

    def rows(self):
        return [dict(r) for r in self.db.execute("SELECT * FROM jobs ORDER BY id")]

    def ready(self):
        states = {r["id"]: r["state"] for r in self.rows()}
        return [k for k, t in self.tasks.items() if states[k] == "PLANNED"
                and all(states[d] == "ACCEPTED" for d in t["dependsOn"])]

    def claim(self, key: str, owner: str, ttl=1800, now=None):
        if not owner.strip() or not math.isfinite(ttl) or not 30 <= ttl <= 7200:
            raise ValueError("Owner and lease TTL (30..7200 seconds) required")
        now = time.time() if now is None else now
        self.db.execute("BEGIN IMMEDIATE")
        try:
            if key not in self.ready():
                raise ValueError("Task not ready (expired leases require explicit release)")
            task = self.tasks[key]
            for row in self.rows():
                # Expired writers still block: never steal a live Studio/Blender session.
                if row["state"] not in ("ACTIVE", "REVIEW"):
                    continue
                other = self.tasks[row["id"]]
                if any(overlap(a, b) for a in task["writeScopes"] for b in other["writeScopes"]):
                    raise ValueError(f"Write ownership conflict: {row['id']}")
                if task["environment"] in ("studio", "blender") and other["environment"] == task["environment"]:
                    raise ValueError(f"Exclusive {task['environment']} session busy")
            token = uuid.uuid4().hex
            self.db.execute("UPDATE jobs SET state='ACTIVE',owner=?,token=?,expires=?,evidence=NULL,reviewer=NULL WHERE id=?",
                            (owner, token, now + ttl, key))
            self.db.execute("COMMIT")
            return token
        except Exception:
            self.db.execute("ROLLBACK")
            raise

    def assert_lease(self, key, token, now=None):
        now = time.time() if now is None else now
        row = self.db.execute("SELECT * FROM jobs WHERE id=?", (key,)).fetchone()
        if not row or row["state"] != "ACTIVE" or row["token"] != token or row["expires"] <= now:
            raise ValueError("Missing, expired or stale lease")
        return row

    def heartbeat(self, key, token, ttl=1800):
        if not math.isfinite(ttl) or not 30 <= ttl <= 7200:
            raise ValueError("Invalid TTL")
        self.db.execute("BEGIN IMMEDIATE")
        try:
            self.assert_lease(key, token)
            self.db.execute("UPDATE jobs SET expires=? WHERE id=?", (time.time() + ttl, key))
            self.db.execute("COMMIT")
        except Exception:
            self.db.execute("ROLLBACK")
            raise

    def submit(self, key, token, packet):
        if packet.get("planSha256") != self.plan_hash:
            raise ValueError("Evidence plan fingerprint mismatch")
        evidence_packet(self.root, self.tasks[key], packet)
        self.db.execute("BEGIN IMMEDIATE")
        try:
            self.assert_lease(key, token)
            self.db.execute("UPDATE jobs SET state='REVIEW',evidence=? WHERE id=?", (json.dumps(packet), key))
            self.db.execute("COMMIT")
        except Exception:
            self.db.execute("ROLLBACK")
            raise

    def accept(self, key, reviewer):
        self.db.execute("BEGIN IMMEDIATE")
        try:
            row = self.db.execute("SELECT * FROM jobs WHERE id=?", (key,)).fetchone()
            if not row or row["state"] != "REVIEW" or not reviewer.strip() or reviewer == row["owner"]:
                raise ValueError("A different named reviewer must review a submitted task")
            evidence_packet(self.root, self.tasks[key], json.loads(row["evidence"]))
            self.db.execute("UPDATE jobs SET state='ACCEPTED',reviewer=?,token=NULL WHERE id=?", (reviewer, key))
            self.db.execute("COMMIT")
        except Exception:
            self.db.execute("ROLLBACK")
            raise

    def release(self, key, token):
        # The human/operator first confirms old worker and tool session have stopped.
        cursor = self.db.execute("UPDATE jobs SET state='PLANNED',owner=NULL,token=NULL,expires=NULL,evidence=NULL WHERE id=? AND token=? AND state IN ('ACTIVE','REVIEW')", (key, token))
        if cursor.rowcount != 1:
            raise ValueError("Cannot release another owner's task")


def inventory(root: Path, *, hash_files: bool = False):
    entries = []
    suffixes = {".luau", ".py", ".ps1", ".md", ".json", ".toml", ".blend", ".fbx", ".glb", ".png", ".wav", ".ogg", ".svg", ".gltf", ".bin", ".csv", ".xlsx", ".webp", ".jpg", ".jpeg", ".flac", ".mp3", ".rbxm", ".rbxmx", ".lua", ".yml", ".yaml"}
    for folder in ("src", "tests", "tools", "assets", "docs/uat01", "review"):
        for path in sorted((root / folder).rglob("*")):
            if path.is_symlink() or not path.is_file() or path.suffix.lower() not in suffixes:
                continue
            if any(part in ("__pycache__", ".git", "node_modules", ".venv") for part in path.parts):
                continue
            inside(root, path.relative_to(root).as_posix())
            entry = {"path": path.relative_to(root).as_posix(), "bytes": path.stat().st_size}
            if hash_files:
                entry["sha256"] = digest(path)
            entries.append(entry)
    return {"schemaVersion": 1, "inspection": "filesystem-hashes-not-runtime-verification" if hash_files else "filesystem-metadata-not-runtime-verification", "files": entries}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("validate", "plan", "doctor", "status", "claim", "heartbeat", "check-lease", "submit", "accept", "release"))
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--ledger", type=Path, help="Use the SAME coordinator ledger for all worktrees")
    parser.add_argument("--task")
    parser.add_argument("--owner")
    parser.add_argument("--token")
    parser.add_argument("--evidence", help="Repository-relative JSON evidence packet")
    args = parser.parse_args(argv)
    root = args.root.resolve()
    try:
        plan = read_json(root / "production/plan.json")
        validate_plan(plan)
        if args.command == "validate":
            print(json.dumps({"tasks": len(plan["tasks"]), "skills": validate_skills(root, plan), "status": "PASS", "scope": "plan-and-skill-contract-only"}))
            return 0
        if args.command == "doctor":
            print(json.dumps({"python": os.sys.version.split()[0], "git": bool(shutil.which("git")), "blenderBinary": bool(shutil.which("blender")), "codexBinary": bool(shutil.which("codex")), "studioMCP": "MUST_PROBE_IN_AGENT_SESSION", "imageGeneration": "MUST_PROBE_IN_AGENT_SESSION", "probeCommand": "python tools/agentic/mcp_probe.py --help", "localWorkerCommand": "python tools/agentic/run_worker.py --help", "publicRelease": "NOT_AUTHORIZED"}, indent=2))
            return 0
        if args.command == "plan":
            out = root / "build/agentic"
            save_json(out / "inventory.json", inventory(root, hash_files=True))
            for task in plan["tasks"]:
                text = "# " + task["title"] + "\n\nRead AGENTS.md and .agents/skills/" + task["skill"] + "/SKILL.md.\n\n" + task["brief"] + "\n\n" + json.dumps(task, ensure_ascii=False, indent=2) + "\n\nClaim a lease before writing. Missing tools block this task, not unrelated work. Never mark a requested artifact as already generated.\n"
                target = inside(root, "build/agentic/prompts/" + task["id"] + ".md")
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(text, encoding="utf-8")
            print(f"Planned {len(plan['tasks'])} tasks; no model, Studio, cloud or paid API was called")
            return 0
        ledger = Ledger(args.ledger or root / "build/agentic/ledger.sqlite3", root, plan)
        try:
            if args.command == "status":
                print(json.dumps({"ready": ledger.ready(), "tasks": [{k:v for k,v in r.items() if k not in ('token','evidence')} for r in ledger.rows()]}, indent=2))
            else:
                if args.task not in ledger.tasks:
                    raise ValueError("Choose a valid --task")
                if args.command == "claim":
                    if not args.owner: raise ValueError("--owner required")
                    print(json.dumps({"task": args.task, "leaseToken": ledger.claim(args.task, args.owner)}))
                elif args.command == "heartbeat": ledger.heartbeat(args.task, args.token)
                elif args.command == "check-lease":
                    ledger.assert_lease(args.task, args.token)
                    print("LEASE_VALID")
                elif args.command == "submit":
                    if not args.evidence: raise ValueError("--evidence required")
                    ledger.submit(args.task, args.token, read_json(inside(root, args.evidence)))
                elif args.command == "accept":
                    if not args.owner: raise ValueError("--owner reviewer required")
                    ledger.accept(args.task, args.owner)
                elif args.command == "release": ledger.release(args.task, args.token)
        finally:
            ledger.close()
        return 0
    except (ValueError, OSError, KeyError, TypeError, sqlite3.Error) as error:
        print(f"FORGE_ERROR: {error}", file=os.sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
