"""Exercise Studio/Forge handoff and recorded review in a disposable local repository.

No models or platform tools are called. This proves coordinator behavior, not
native-client loading, Blender art, Studio gameplay, or human acceptance.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from forge import ROOT, Ledger, inside, read_json, save_json
import compose_evidence
import record_check
import studio


def git(root: Path, *args: str) -> None:
    subprocess.run(["git", "-C", str(root), *args], check=True,
                   capture_output=True, timeout=30)


def smoke(source: Path) -> dict:
    source = source.resolve()
    spec, plan = studio.load(source)
    studio.validate(source, spec, plan)
    with tempfile.TemporaryDirectory(prefix="guildborne-studio-smoke-") as directory:
        root = Path(directory).resolve()
        for relative in ("tools/agentic", ".agents/skills"):
            shutil.copytree(inside(source, relative), root / relative,
                            ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
        for relative in ("production/studio/studio.json", "production/plan.json", "AGENTS.md"):
            target = root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(inside(source, relative), target)
        (root / ".gitignore").write_text("build/\n__pycache__/\n*.pyc\n", encoding="utf-8")
        studio.generate(root, spec, plan)
        studio.verify(root, spec, plan)
        git(root, "init", "--quiet")
        git(root, "config", "user.email", "studio-smoke@example.invalid")
        git(root, "config", "user.name", "Guildborne local fixture")
        git(root, "add", ".")
        git(root, "commit", "--quiet", "-m", "Disposable Studio coordinator fixture")

        database = root / "build/agentic/shared-smoke.sqlite3"
        ledger = Ledger(database, root, plan)
        task_id = "audit"
        owner = "smoke-implementer"
        try:
            before = studio.route(root, spec, plan, task_id, database)
            if task_id not in ledger.ready():
                raise ValueError("Audit must be ready before the first claim")
            token = ledger.claim(task_id, owner)
            packet = studio.handoff(root, spec, plan, task_id, database, owner, token)
            rendered = inside(root, packet["promptPath"]).read_text(encoding="utf-8")
            if token in json.dumps(packet) or token in rendered:
                raise ValueError("Handoff leaked the cooperative lease token")
            # Commands assert specific coordinator properties against real files.
            commands = {
                "inventory": "import forge; from pathlib import Path; assert forge.inventory(Path.cwd())['files']",
                "baseline": "import studio; from pathlib import Path; s,p=studio.load(Path.cwd()); studio.validate(Path.cwd(),s,p); studio.verify(Path.cwd(),s,p)",
                "conflicts": "import forge; from pathlib import Path; p=forge.read_json(Path('production/plan.json')); forge.validate_plan(p); assert not forge.contains_path('src/client/UI','src/client')",
            }
            checks = {}
            for check_id, code in commands.items():
                argv = [sys.executable, "-c", "import sys;sys.path.insert(0,'tools/agentic');" + code]
                result = record_check.record(root, argv, timeout=30, approved=True)
                record_check.verify(root, result)
                checks[check_id] = f"build/agentic/checks/{result['invocation']['runId']}/result.json"
            evidence = compose_evidence.compose(root, task_id, checks)
            ledger.submit(task_id, token, evidence)
            if next(row for row in ledger.rows() if row["id"] == task_id)["state"] != "REVIEW":
                raise ValueError("Submission must wait for an independent reviewer")
            try:
                ledger.accept(task_id, owner)
            except ValueError:
                pass
            else:
                raise ValueError("A worker accepted its own work")
            ledger.accept(task_id, "smoke-independent-reviewer")
            after = studio.route(root, spec, plan, "registry-reconciliation", database)
            if "registry-reconciliation" not in ledger.ready():
                raise ValueError("Accepted dependency did not unlock reconciliation")
            return {
                "schemaVersion": 1,
                "status": "LOCAL_COORDINATOR_SMOKE_PASS",
                "scenario": "disposable committed fixture: route -> claim -> handoff -> recorded checks -> REVIEW -> distinct reviewer -> dependent ready",
                "initialRole": before["role"],
                "unlockedRole": after["role"],
                "source": str(source),
                "modelInvoked": False,
                "nativeClientLoaded": False,
                "studioTested": False,
                "blenderTested": False,
                "humanApproved": False,
            }
        finally:
            ledger.close()


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    args = parser.parse_args(argv)
    result = smoke(args.root)
    save_json(inside(args.root, "build/agentic/studio-smoke.json"), result)
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        print(f"STUDIO_SMOKE_ERROR: {error}", file=sys.stderr)
        raise SystemExit(2)
