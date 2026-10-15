#!/usr/bin/env python3
"""Read-only ecosystem routing and file inventory; never dispatch or execute tools."""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import sys

# Keep even dependency imports from creating __pycache__ during CLI inventory.
sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import forge

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = "production/studio/ecosystem.json"
BOOTSTRAP = "roblox-collaboration-mode"
SKILL_ID = re.compile(r"roblox-[a-z0-9]+(?:-[a-z0-9]+)*\Z")


def text(value, label):
    if (not isinstance(value, str) or not value.strip()
            or any(ord(c) < 32 or 0xD800 <= ord(c) <= 0xDFFF for c in value)):
        raise ValueError(f"{label} must be nonempty text without control characters")
    return value


def strings(value, label, *, nonempty=False):
    if not isinstance(value, list) or (nonempty and not value):
        raise ValueError(f"{label} must be an array" + (" with entries" if nonempty else ""))
    for item in value:
        text(item, label)
    if len(value) != len(set(value)):
        raise ValueError(f"Duplicate {label}")
    return value


def skill_id(value):
    if not isinstance(value, str) or not SKILL_ID.fullmatch(value) or len(value) > 64:
        raise ValueError(f"Invalid Roblox skill ID: {value!r}")
    return value


def validate(root, manifest, plan, studio):
    root = Path(root).resolve()
    if not isinstance(manifest, dict) or type(manifest.get("schemaVersion")) is not int or manifest["schemaVersion"] != 1:
        raise ValueError("Ecosystem requires schemaVersion=1")
    if manifest.get("bootstrapSkill") != BOOTSTRAP:
        raise ValueError(f"bootstrapSkill must be {BOOTSTRAP}")
    skills_dir = forge.inside(root, ".agents/skills")
    canonical = {}
    for entry in sorted(skills_dir.glob("guildborne-*/SKILL.md")):
        path = forge.inside(root, entry.relative_to(root).as_posix())
        if not forge.SLUG.fullmatch(entry.parent.name) or not path.is_file():
            raise ValueError(f"Invalid canonical skill: {entry.parent.name}")
        canonical[entry.parent.name] = path
    routing = manifest.get("skillRouting")
    if not canonical or not isinstance(routing, dict) or set(routing) != set(canonical):
        raise ValueError("skillRouting must cover every canonical Guildborne skill exactly")
    for primary, supports in routing.items():
        strings(supports, f"{primary} support skills")
        if len(supports) > 4:
            raise ValueError(f"At most four support skills per primary: {primary}")
        for support in supports:
            skill_id(support)
    if (not isinstance(plan, dict) or type(plan.get("schemaVersion")) is not int
            or not isinstance(plan.get("tasks"), list) or not all(isinstance(task, dict) for task in plan["tasks"])):
        raise ValueError("Plan requires schemaVersion and an array of task objects")
    tasks = forge.validate_plan(plan)
    if not isinstance(studio, dict) or not isinstance(studio.get("roles"), list):
        raise ValueError("Studio requires roles")
    roles = {}
    for role in studio["roles"]:
        if not isinstance(role, dict):
            raise ValueError("Role must be an object")
        key = text(role.get("id"), "role ID")
        if not forge.SLUG.fullmatch(key) or key in roles:
            raise ValueError(f"Invalid or duplicate role: {key}")
        strings(role.get("skills"), f"{key} skills", nonempty=True)
        roles[key] = role
    assignments = studio.get("taskRoles")
    if not isinstance(assignments, dict) or set(assignments) != set(tasks):
        raise ValueError("Studio taskRoles must cover every task exactly")
    for key, task in tasks.items():
        primary = task["skill"]
        if primary not in canonical:
            raise ValueError(f"Missing canonical primary skill: {primary}")
        role_id = assignments[key]
        if not isinstance(role_id, str) or role_id not in roles or primary not in roles[role_id]["skills"]:
            raise ValueError(f"Invalid role assignment for task: {key}")
        for scope in task["writeScopes"]:
            forge.inside(root, scope)
    tools = manifest.get("tools")
    if not isinstance(tools, list):
        raise ValueError("tools must be an array")
    ids = set()
    for tool in tools:
        if not isinstance(tool, dict):
            raise ValueError("Tool must be an object")
        key = text(tool.get("id"), "tool ID")
        if not forge.SLUG.fullmatch(key) or key in ids:
            raise ValueError(f"Invalid or duplicate tool: {key}")
        ids.add(key)
        text(tool.get("decision"), f"{key} decision")
        text(tool.get("reason"), f"{key} reason")
        for path in strings(tool.get("paths"), f"{key} paths"):
            target = forge.inside(root, path)
            if target.exists() and not target.is_file():
                raise ValueError(f"Tool path must identify a file: {path}")
    pipelines = manifest.get("pipelines")
    if not isinstance(pipelines, dict) or not {"code", "assets"} <= set(pipelines):
        raise ValueError("pipelines must include code and assets")
    for name, pipeline in pipelines.items():
        text(name, "pipeline name")
        if not isinstance(pipeline, dict):
            raise ValueError("Pipeline must be an object")
        commands = pipeline.get("commands")
        if not isinstance(commands, list) or not commands:
            raise ValueError(f"{name}.commands must contain argv arrays")
        for argv in commands:
            if not isinstance(argv, list) or not argv:
                raise ValueError(f"{name} command must be a nonempty argv array")
            for argument in argv:
                text(argument, "command argument")
                # These are inert recipes. Check path spelling without running them.
                candidate = argument.split("=", 1)[-1] if argument.startswith("--") else argument
                if "/" in candidate or "\\" in candidate or ":" in candidate or candidate in (".", ".."):
                    forge.inside(root, candidate)
        strings(pipeline.get("externalGates"), f"{name}.externalGates", nonempty=True)
    return tasks, roles


def load(root):
    root = Path(root).resolve()
    manifest, plan, studio = [forge.read_json(forge.inside(root, path)) for path in
                              (MANIFEST, "production/plan.json", "production/studio/studio.json")]
    tasks, roles = validate(root, manifest, plan, studio)
    return manifest, tasks, roles, studio["taskRoles"]


def global_skills_root(explicit=None):
    if explicit is not None:
        return Path(explicit).expanduser().resolve()
    codex_home = os.environ.get("CODEX_HOME")
    return (Path(codex_home).expanduser() / "skills" if codex_home else Path.home() / ".codex/skills").resolve()


def file_info(path):
    return {"path": str(path), "status": "PRESENT" if path.is_file() else "MISSING",
            "sha256": forge.digest(path) if path.is_file() else None}


def optional_skill(directory, name):
    skill_id(name)
    path = forge.inside(directory, f"{name}/SKILL.md")
    return {"id": name, **file_info(path)}


def route(root, task_id, skills_root=None):
    root = Path(root).resolve()
    manifest, tasks, roles, assignments = load(root)
    if task_id not in tasks:
        raise ValueError(f"Unknown task: {task_id}")
    task = tasks[task_id]
    directory = global_skills_root(skills_root)
    bootstrap = optional_skill(directory, manifest["bootstrapSkill"])
    supports = [optional_skill(directory, name) for name in manifest["skillRouting"][task["skill"]]]
    missing = [entry["id"] for entry in [bootstrap, *supports] if entry["status"] == "MISSING"]
    primary = {"id": task["skill"], **file_info(forge.inside(root, f".agents/skills/{task['skill']}/SKILL.md"))}
    return {"planningOnly": True, "dispatchStarted": False, "acceptanceChanged": False,
            "taskId": task_id, "role": assignments[task_id], "roleTitle": roles[assignments[task_id]].get("title"),
            "environment": task["environment"], "writeScopes": task["writeScopes"], "checks": task["checks"],
            "primarySkill": primary, "bootstrapSkill": bootstrap, "supportSkills": supports,
            "skillsRoot": str(directory), "missingSkills": missing,
            "fallbackPrimarySkill": primary["path"] if missing else None,
            "notice": "File presence and hashes do not prove review, connection, execution or acceptance."}


def blender_inventory(explicit=None):
    if explicit is not None:
        candidates = [("explicit", Path(explicit).expanduser())]
    else:
        candidates = []
        if os.name == "nt":
            candidates.append(("common-windows-5.2", Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Blender Foundation/Blender 5.2/blender.exe"))
        found = shutil.which("blender")
        if found:
            candidates.append(("PATH", Path(found)))
    for origin, path in candidates:
        if path.is_file():
            return {"path": str(path.resolve()), "status": "PRESENT", "source": origin, "executed": False}
    return {"path": str(candidates[0][1]) if candidates else None, "status": "MISSING", "executed": False}


def doctor(root, skills_root=None, blender=None):
    root = Path(root).resolve()
    manifest, tasks, roles, _ = load(root)
    directory = global_skills_root(skills_root)
    names = sorted({manifest["bootstrapSkill"], *(name for values in manifest["skillRouting"].values() for name in values)})
    return {"planningOnly": True, "dispatchStarted": False, "acceptanceChanged": False,
            "scope": "filesystem-inventory-only", "taskCount": len(tasks), "roleCount": len(roles),
            "tools": [{"id": item["id"], "decision": item["decision"], "reason": item["reason"],
                       "files": [file_info(forge.inside(root, path)) for path in item["paths"]], "executed": False}
                      for item in manifest["tools"]],
            "skillsRoot": str(directory), "optionalSkills": [optional_skill(directory, name) for name in names],
            "blender": blender_inventory(blender),
            "mcp": {"status": "LIVE_PROBE_REQUIRED", "connectionVerified": False},
            "notice": "Missing optional files do not block unrelated work. Nothing was installed, connected or executed."}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("validate", "route", "doctor"))
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--task")
    parser.add_argument("--skills-root", type=Path)
    parser.add_argument("--blender", type=Path)
    args = parser.parse_args(argv)
    try:
        if args.command == "route":
            if not args.task:
                parser.error("route requires --task")
            result = route(args.root, args.task, args.skills_root)
        elif args.command == "doctor":
            result = doctor(args.root, args.skills_root, args.blender)
        else:
            manifest, tasks, roles, _ = load(args.root)
            result = {"status": "PASS", "scope": "ecosystem-metadata-only", "planningOnly": True,
                      "acceptanceChanged": False, "taskCount": len(tasks), "roleCount": len(roles),
                      "mappedSkillCount": len(manifest["skillRouting"])}
        print(json.dumps(result, ensure_ascii=False, indent=2, allow_nan=False))
        return 0
    except (ValueError, OSError, KeyError, TypeError, RuntimeError) as error:
        print(json.dumps({"status": "ERROR", "planningOnly": True, "error": str(error)}), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
