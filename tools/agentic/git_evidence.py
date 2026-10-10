"""Git identity checks for cooperative evidence. Not a signing/attestation service."""
from __future__ import annotations
import hashlib
from pathlib import Path
import re
import subprocess

SHA = re.compile(r"^[0-9a-f]{40}$")


def git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-c", "core.fsmonitor=false", "-C", str(root), *args],
        capture_output=True, text=True, encoding="utf-8", errors="strict", timeout=30,
        check=False,
    )
    if result.returncode:
        raise ValueError(f"Git check failed: {' '.join(args[:2])}")
    return result.stdout.rstrip("\n")


def head(root: Path) -> str:
    if Path(git(root, "rev-parse", "--show-toplevel")).resolve() != root.resolve():
        raise ValueError("Evidence root must be the Git working-tree root")
    return git(root, "rev-parse", "HEAD")


def validate_commit(root: Path, commit: str, *, require_head: bool = True) -> str:
    if not isinstance(commit, str) or not SHA.fullmatch(commit):
        raise ValueError("Expected a full lowercase Git SHA1")
    resolved = git(root, "rev-parse", "--verify", commit + "^{commit}")
    if resolved != commit:
        raise ValueError("Evidence SHA must identify a commit, not a tag or tree")
    if require_head and head(root) != commit:
        raise ValueError("Evidence commit differs from checked-out HEAD; revalidate this build")
    return git(root, "rev-parse", commit + "^{tree}")


def clean_source(root: Path) -> None:
    """Ignored build artifacts are fine. Uncommitted source is not an immutable build."""
    tracked = git(root, "status", "--porcelain=v1", "--untracked-files=no")
    if tracked:
        raise ValueError("Commit the tested source before submitting evidence")
    untracked = git(root, "ls-files", "--others", "--exclude-standard", "-z")
    for path in filter(None, untracked.split("\0")):
        if not path.startswith(("build/agentic/", "production/evidence/")):
            raise ValueError(f"Untracked source cannot be certified: {path}")


def plan_hash(plan: dict) -> str:
    import json
    return hashlib.sha256(json.dumps(plan, sort_keys=True, allow_nan=False).encode()).hexdigest()


def validate_identity(root: Path, packet: dict) -> None:
    tree = validate_commit(root, packet.get("buildCommit"))
    if packet.get("sourceTree") != tree:
        raise ValueError("Evidence sourceTree differs from committed tree")
    clean_source(root)
    invocation = packet.get("invocation")
    if not isinstance(invocation, dict) or type(invocation.get("exitCode")) is not int or invocation["exitCode"] != 0:
        raise ValueError("Evidence requires a successful, recorded tool invocation")
    if not isinstance(invocation.get("tool"), str) or not invocation["tool"].strip():
        raise ValueError("Missing invocation tool")
    if not SHA.fullmatch(invocation.get("buildCommit", "")) or invocation["buildCommit"] != packet["buildCommit"]:
        raise ValueError("Invocation is for a different build")
    if not isinstance(invocation.get("runId"), str) or not re.fullmatch(r"[A-Za-z0-9_-]{1,100}", invocation["runId"]):
        raise ValueError("Missing or invalid invocation run ID")
    logs = invocation.get("logs")
    artifacts = {a.get("path") for a in packet.get("artifacts", []) if isinstance(a, dict)}
    if not isinstance(logs, list) or not logs or any(p not in artifacts for p in logs):
        raise ValueError("Invocation logs must be included as hashed evidence artifacts")
