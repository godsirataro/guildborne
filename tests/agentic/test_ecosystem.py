"""Offline inventory/routing tests; no Roblox, Blender, model or acceptance claims."""
from __future__ import annotations

from contextlib import redirect_stderr, redirect_stdout
import copy
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/agentic"))
import ecosystem


class EcosystemTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        # Windows runners may expose TEMP through an 8.3 alias (RUNNER~1).
        # Use the same canonical parent as the router and symlink guard.
        fixture_root = Path(temporary.name).resolve()
        self.root = fixture_root / "repo"
        self.skills = fixture_root / "global-skills"
        self.manifest = {
            "schemaVersion": 1, "bootstrapSkill": "roblox-collaboration-mode",
            "skillRouting": {"guildborne-qa": ["roblox-luau-core"], "guildborne-tooling": []},
            "tools": [{"id": "validator", "decision": "reuse", "paths": ["tools/check.py"], "reason": "Existing check."}],
            "pipelines": {name: {"commands": [["python", "tools/check.py"]], "externalGates": ["human-review"]}
                          for name in ("code", "assets")}}
        self.plan = {"schemaVersion": 1, "tasks": [
            {"id": "audit", "skill": "guildborne-qa", "environment": "local", "dependsOn": [],
             "writeScopes": ["src/example.luau"], "checks": ["regression"], "title": "Audit", "brief": "Inspect."}]}
        self.studio = {"roles": [{"id": "qa-engineer", "title": "QA Engineer", "skills": ["guildborne-qa"]}],
                       "taskRoles": {"audit": "qa-engineer"}}
        for name in self.manifest["skillRouting"]:
            self.write(f".agents/skills/{name}/SKILL.md", f"---\nname: {name}\n---\nFixture instructions.\n")
        self.write("tools/check.py", "raise RuntimeError('must never execute')\n")
        self.save()

    def write(self, name, content):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        return path

    def save(self):
        for name, value in ((ecosystem.MANIFEST, self.manifest), ("production/plan.json", self.plan),
                            ("production/studio/studio.json", self.studio)):
            self.write(name, json.dumps(value))

    def add_global(self, name):
        path = self.skills / name / "SKILL.md"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("Fixture only, not reviewed.\n", encoding="utf-8")
        return path

    def validate(self):
        return ecosystem.validate(self.root, self.manifest, self.plan, self.studio)

    def test_missing_global_skills_use_existing_primary_without_dispatch(self):
        report = ecosystem.route(self.root, "audit", self.skills)
        self.assertEqual(report["role"], "qa-engineer")
        self.assertEqual(report["missingSkills"], ["roblox-collaboration-mode", "roblox-luau-core"])
        self.assertEqual(report["fallbackPrimarySkill"], report["primarySkill"]["path"])
        self.assertEqual(report["writeScopes"], ["src/example.luau"])
        self.assertEqual(report["primarySkill"]["status"], "PRESENT")
        self.assertTrue(report["planningOnly"])
        self.assertFalse(report["dispatchStarted"])
        self.assertFalse(report["acceptanceChanged"])

    def test_optional_present_files_have_hashes_not_review_status(self):
        for name in ("roblox-collaboration-mode", "roblox-luau-core"):
            self.add_global(name)
        report = ecosystem.route(self.root, "audit", self.skills)
        self.assertEqual(report["missingSkills"], [])
        self.assertIsNone(report["fallbackPrimarySkill"])
        for item in [report["bootstrapSkill"], *report["supportSkills"]]:
            self.assertEqual(len(item["sha256"]), 64)
            self.assertEqual(item["status"], "PRESENT")
            self.assertNotIn("reviewed", item)
        self.assertEqual(report["supportSkills"][0]["path"], str(self.skills / "roblox-luau-core/SKILL.md"))

    def test_skill_roots_explicit_then_codex_home_then_home(self):
        with patch.dict("os.environ", {"CODEX_HOME": str(self.skills.parent / "codex")}, clear=True):
            self.assertEqual(ecosystem.global_skills_root(self.skills), self.skills.resolve())
            self.assertEqual(ecosystem.global_skills_root(), (self.skills.parent / "codex/skills").resolve())
        with patch.dict("os.environ", {}, clear=True), patch.object(Path, "home", return_value=self.skills.parent):
            self.assertEqual(ecosystem.global_skills_root(), (self.skills.parent / ".codex/skills").resolve())

    def test_unknown_task_rejected(self):
        with self.assertRaisesRegex(ValueError, "Unknown task"):
            ecosystem.route(self.root, "not-real", self.skills)

    def test_primary_must_exist_and_all_local_skills_must_be_mapped(self):
        for mutate in (lambda: self.manifest["skillRouting"].pop("guildborne-tooling"),
                       lambda: self.manifest["skillRouting"].update({"guildborne-imaginary": []}),
                       lambda: (self.root / ".agents/skills/guildborne-qa/SKILL.md").unlink()):
            original = copy.deepcopy(self.manifest)
            mutate()
            with self.assertRaises(ValueError):
                self.validate()
            self.manifest = original

    def test_support_limit_slug_duplicates_and_bootstrap(self):
        invalid = [[f"roblox-test-{i}" for i in range(5)], ["roblox-luau-core"] * 2,
                   ["../roblox-test"], ["guildborne-qa"], "roblox-luau-core"]
        for value in invalid:
            with self.subTest(value=value):
                self.manifest["skillRouting"]["guildborne-qa"] = value
                with self.assertRaises(ValueError):
                    self.validate()
        self.manifest["skillRouting"]["guildborne-qa"] = []
        self.manifest["bootstrapSkill"] = "C:/host/skill.md"
        with self.assertRaises(ValueError):
            self.validate()

    def test_task_roles_must_exist_and_own_primary_skill(self):
        for value in ({}, {"audit": "imaginary"}, {"audit": "qa-engineer", "extra": "qa-engineer"}):
            self.studio["taskRoles"] = value
            with self.assertRaises(ValueError):
                self.validate()
        self.studio["taskRoles"] = {"audit": "qa-engineer"}
        self.studio["roles"][0]["skills"] = ["guildborne-tooling"]
        with self.assertRaises(ValueError):
            self.validate()

    def test_unsafe_repository_tool_scope_and_argv_paths_rejected(self):
        for path in ("../outside", "/tmp/outside", "C:/outside", "tools\\check.py", "tools/../check.py"):
            with self.subTest(path=path):
                self.manifest["tools"][0]["paths"] = [path]
                with self.assertRaises(ValueError):
                    self.validate()
                self.manifest["tools"][0]["paths"] = ["tools/check.py"]
                self.plan["tasks"][0]["writeScopes"] = [path]
                with self.assertRaises(ValueError):
                    self.validate()
                self.plan["tasks"][0]["writeScopes"] = ["src/example.luau"]
                self.manifest["pipelines"]["code"]["commands"] = [["python", path]]
                with self.assertRaises(ValueError):
                    self.validate()
                self.manifest["pipelines"]["code"]["commands"] = [["python", "tools/check.py"]]

    def test_malformed_manifest_shapes_fail(self):
        for field, value in (("schemaVersion", True), ("skillRouting", []), ("tools", {}), ("pipelines", [])):
            with self.subTest(field=field):
                old = self.manifest[field]
                self.manifest[field] = value
                with self.assertRaises(ValueError):
                    self.validate()
                self.manifest[field] = old
        for commands in ([], ["python tools/check.py"], [[]], [["python", ""]]):
            self.manifest["pipelines"]["code"]["commands"] = commands
            with self.assertRaises(ValueError):
                self.validate()

    def test_malformed_plan_entry_is_a_validation_error(self):
        self.plan["tasks"] = [None]
        with self.assertRaisesRegex(ValueError, "task objects"):
            self.validate()

    def test_duplicate_tools_and_directory_paths_rejected(self):
        self.manifest["tools"].append(copy.deepcopy(self.manifest["tools"][0]))
        with self.assertRaises(ValueError):
            self.validate()
        self.manifest["tools"].pop()
        self.manifest["tools"][0]["paths"] = ["tools"]
        with self.assertRaises(ValueError):
            self.validate()

    def test_doctor_reports_missing_optional_files_and_does_not_execute_recipes(self):
        self.manifest["tools"][0]["paths"].append("tools/missing.py")
        self.manifest["pipelines"]["code"]["commands"] = [["python", "-c", "raise SystemExit(88)"]]
        self.save()
        before = {p.relative_to(self.root): p.read_bytes() for p in self.root.rglob("*") if p.is_file()}
        with patch("subprocess.run", side_effect=AssertionError("No subprocess allowed")), patch.object(ecosystem.shutil, "which", return_value=None):
            report = ecosystem.doctor(self.root, self.skills, self.root / "missing-blender")
        after = {p.relative_to(self.root): p.read_bytes() for p in self.root.rglob("*") if p.is_file()}
        self.assertEqual(before, after)
        self.assertEqual([f["status"] for f in report["tools"][0]["files"]], ["PRESENT", "MISSING"])
        self.assertEqual(report["blender"]["status"], "MISSING")
        self.assertEqual(report["mcp"], {"status": "LIVE_PROBE_REQUIRED", "connectionVerified": False})
        self.assertFalse(report["acceptanceChanged"])
        self.assertFalse(report["tools"][0]["executed"])

    def test_explicit_blender_inventory_never_executes_or_falls_back(self):
        executable = self.write("fake-blender", "not an executable")
        with patch.object(ecosystem.shutil, "which", side_effect=AssertionError("Explicit path should not use PATH")):
            present = ecosystem.blender_inventory(executable)
            absent = ecosystem.blender_inventory(executable.parent / "absent")
        self.assertEqual(present["status"], "PRESENT")
        self.assertFalse(present["executed"])
        self.assertEqual(absent["status"], "MISSING")

    def test_blender_path_detection_is_presence_only(self):
        executable = self.write("path-blender", "fixture")
        with patch.object(ecosystem.shutil, "which", return_value=str(executable)):
            # A user's installed Windows Blender may precede PATH; both are inventories.
            result = ecosystem.blender_inventory()
        self.assertEqual(result["status"], "PRESENT")
        self.assertFalse(result["executed"])

    def test_repo_and_global_symlink_escapes_rejected_before_read(self):
        outside = self.skills.parent / "outside"
        outside.mkdir()
        (outside / "SKILL.md").write_text("untrusted outside", encoding="utf-8")
        link = self.root / "escape"
        try:
            link.symlink_to(outside, target_is_directory=True)
        except OSError as error:
            self.skipTest(f"Host does not permit fixture symlinks: {error}")
        self.manifest["tools"][0]["paths"] = ["escape/SKILL.md"]
        with self.assertRaises(ValueError):
            self.validate()
        self.manifest["tools"][0]["paths"] = ["tools/check.py"]
        self.save()
        self.skills.mkdir()
        (self.skills / "roblox-luau-core").symlink_to(outside, target_is_directory=True)
        with self.assertRaises(ValueError):
            ecosystem.route(self.root, "audit", self.skills)

    def test_symlink_guard_runs_before_inventory_reads_on_all_hosts(self):
        target = self.root / "tools/check.py"
        with patch.object(Path, "is_symlink", lambda path: path == target):
            with self.assertRaisesRegex(ValueError, "Symlink"):
                self.validate()
        target = self.skills / "roblox-luau-core"
        with patch.object(Path, "is_symlink", lambda path: path == target):
            with self.assertRaisesRegex(ValueError, "Symlink"):
                ecosystem.optional_skill(self.skills, "roblox-luau-core")

    def test_cli_temp_root_json_and_error_exit(self):
        for args in (["--root", str(self.root), "validate"],
                     ["route", "--root", str(self.root), "--task", "audit", "--skills-root", str(self.skills)],
                     ["doctor", "--root", str(self.root), "--skills-root", str(self.skills), "--blender", str(self.root / "absent")]):
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(ecosystem.main(args), 0)
            self.assertTrue(json.loads(output.getvalue())["planningOnly"])
        error = io.StringIO()
        with redirect_stderr(error):
            self.assertEqual(ecosystem.main(["route", "--root", str(self.root), "--task", "missing"]), 1)
        self.assertEqual(json.loads(error.getvalue())["status"], "ERROR")

    def test_real_repository_contract_is_portable_without_global_skills(self):
        manifest, tasks, _, _ = ecosystem.load(ROOT)
        self.assertEqual(manifest["bootstrapSkill"], ecosystem.BOOTSTRAP)
        task = next(iter(tasks))
        report = ecosystem.route(ROOT, task, self.skills)
        self.assertTrue(report["planningOnly"])
        self.assertEqual(report["primarySkill"]["status"], "PRESENT")


if __name__ == "__main__":
    unittest.main()
