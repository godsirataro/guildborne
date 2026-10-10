"""Behavioral checks for offline Studio v3 routing; no platform/UAT acceptance."""
from __future__ import annotations

import copy
import hashlib
import json
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/agentic"))
import forge
import studio


def task(key, scope, dependencies=(), environment="local"):
    return {"id": key, "title": f"Implement {key}", "brief": "Inspect actual source, implement and review.",
            "skill": "guildborne-qa", "environment": environment, "dependsOn": list(dependencies),
            "writeScopes": [scope], "checks": ["regression", "independent-review"]}


def specification():
    roles = [
        {"id": "director", "title": "Fixture Director", "tier": "director", "parent": None,
         "department": "coordination", "skills": ["guildborne-director"], "instructions": "Coordinate actual workers."},
        {"id": "qa-lead", "title": "Quality Lead", "tier": "lead", "parent": "director",
         "department": "quality", "skills": ["guildborne-qa"], "instructions": "Delegate within existing claims."},
        {"id": "qa-specialist", "title": "Quality Specialist", "tier": "specialist", "parent": "qa-lead",
         "department": "quality", "skills": ["guildborne-qa"], "instructions": "Verify actual source and record limitations."},
    ]
    return {"schemaVersion": 1, "name": "Independent fixture",
            "upstream": {"url": "https://example.com/fixture", "ref": "synthetic", "adoption": "Independent test fixture"},
            "roles": roles,
            "taskRoles": {"alpha": "qa-specialist", "beta": "qa-specialist"},
            "workflows": [{"id": "small-slice", "title": "Small private slice", "lead": "qa-lead",
                           "steps": [{"id": "inspect", "role": "qa-specialist", "skill": "guildborne-qa", "dependsOn": []},
                                     {"id": "review", "role": "qa-specialist", "skill": "guildborne-qa", "dependsOn": ["inspect"]}],
                           "gates": ["local-check", "human-review"]}],
            "gates": [{"id": "local-check", "title": "Local source checks", "environment": "local", "evidence": "Real subprocess logs."},
                      {"id": "human-review", "title": "Human acceptance", "environment": "studio", "evidence": "Actual named human decision."}],
            "rules": [{"id": "runtime", "paths": ["src"], "instructions": "Server owns rewards."}]}


class StudioFixture(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.spec = specification()
        self.plan = {"schemaVersion": 1, "tasks": [task("alpha", "src/alpha"), task("beta", "src/beta", ["alpha"])]}
        (self.root / ".gitignore").write_text("build/\n", encoding="utf-8")
        (self.root / "AGENTS.md").write_text("# Fixture contract\nNo publishing. Evidence is REVIEW only.\n", encoding="utf-8")
        for name in ("guildborne-director", "guildborne-qa"):
            path = self.root / ".agents/skills" / name / "SKILL.md"
            path.parent.mkdir(parents=True)
            path.write_text(f"---\nname: {name}\ndescription: Fixture testing skill\n---\n\nInspect actual source.\n", encoding="utf-8")
        self.save_sources()
        subprocess.run(["git", "init", "-q", str(self.root)], check=True, capture_output=True)
        self.commit()
        self.database = self.root / "build/agentic/shared.sqlite3"

    def save_sources(self):
        forge.save_json(self.root / "production/studio/studio.json", self.spec)
        forge.save_json(self.root / "production/plan.json", self.plan)

    def commit(self):
        subprocess.run(["git", "-C", str(self.root), "add", "."], check=True, capture_output=True)
        subprocess.run(["git", "-C", str(self.root), "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                        "commit", "--allow-empty", "-qm", "Synthetic fixture, not platform evidence"], check=True, capture_output=True)

    def ledger(self):
        value = forge.Ledger(self.database, self.root, self.plan)
        self.addCleanup(value.close)
        return value

    def packet(self, key):
        selected = next(t for t in self.plan["tasks"] if t["id"] == key)
        path = self.root / f"build/agentic/{key}-fixture.txt"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("Synthetic source fixture. This is not Studio or device evidence.\n", encoding="utf-8")
        sha = forge.git_evidence.head(self.root)
        return {"taskId": key, "environment": selected["environment"], "buildCommit": sha,
                "sourceTree": forge.git_evidence.validate_commit(self.root, sha),
                "planSha256": forge.git_evidence.plan_hash(self.plan),
                "invocation": {"tool": "fixture", "runId": key, "exitCode": 0, "buildCommit": sha,
                               "logs": [path.relative_to(self.root).as_posix()]},
                "checks": {check: "PASS" for check in selected["checks"]},
                "artifacts": [{"path": path.relative_to(self.root).as_posix(), "sha256": forge.digest(path)}]}

    def prepared(self):
        studio.generate(self.root, self.spec, self.plan)
        self.commit()

    def prompt(self, report):
        path = Path(report["promptPath"])
        return path if path.is_absolute() else self.root / path

    def cli(self, *arguments):
        return subprocess.run([sys.executable, str(ROOT / "tools/agentic/studio.py"), "--root", str(self.root), *arguments],
                              capture_output=True, text=True, encoding="utf-8", timeout=30)


class StudioValidationTests(StudioFixture):
    def test_load_and_validate_real_files(self):
        spec, plan = studio.load(self.root)
        self.assertEqual(spec, self.spec)
        self.assertEqual(plan, self.plan)
        self.assertEqual(studio.validate(self.root, spec, plan)["status"], "PASS")

    def test_role_hierarchy_requires_director_lead_specialist_edges(self):
        mutations = [(0, "parent", "qa-specialist"), (1, "parent", "qa-specialist"),
                     (2, "parent", "director"), (2, "parent", "missing"), (2, "tier", "wizard")]
        for index, field, value in mutations:
            spec = copy.deepcopy(self.spec)
            spec["roles"][index][field] = value
            with self.subTest(index=index, field=field), self.assertRaises(ValueError):
                studio.validate(self.root, spec, self.plan)

    def test_multiple_director_roots_keep_valid_tier_hierarchy(self):
        other = copy.deepcopy(self.spec["roles"][0])
        other["id"] = "technical-director"
        self.spec["roles"].append(other)
        self.spec["roles"][1]["parent"] = "technical-director"
        self.assertEqual(studio.validate(self.root, self.spec, self.plan)["status"], "PASS")

    def test_task_mapping_is_total_and_references_required_skill(self):
        for mutation in ("missing", "extra", "role", "skill"):
            spec = copy.deepcopy(self.spec)
            if mutation == "missing":
                del spec["taskRoles"]["alpha"]
            elif mutation == "extra":
                spec["taskRoles"]["unknown"] = "qa-specialist"
            elif mutation == "role":
                spec["taskRoles"]["alpha"] = "unknown"
            else:
                spec["roles"][2]["skills"] = ["guildborne-director"]
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                studio.validate(self.root, spec, self.plan)

    def test_uninstalled_skill_and_duplicate_role_are_rejected(self):
        for mutation in ("skill", "duplicate"):
            spec = copy.deepcopy(self.spec)
            if mutation == "skill":
                spec["roles"][0]["skills"] = ["missing-skill"]
            else:
                spec["roles"].append(copy.deepcopy(spec["roles"][2]))
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                studio.validate(self.root, spec, self.plan)

    def test_workflow_references_and_dependency_graph_are_validated(self):
        for mutation in ("lead", "role", "skill", "gate", "missing-dependency", "cycle", "duplicate-step"):
            spec = copy.deepcopy(self.spec)
            value = spec["workflows"][0]
            if mutation == "lead":
                value["lead"] = "qa-specialist"
            elif mutation == "role":
                value["steps"][0]["role"] = "missing"
            elif mutation == "skill":
                value["steps"][0]["skill"] = "guildborne-director"
            elif mutation == "gate":
                value["gates"] = ["missing"]
            elif mutation == "missing-dependency":
                value["steps"][0]["dependsOn"] = ["missing"]
            elif mutation == "cycle":
                value["steps"][0]["dependsOn"] = ["review"]
            else:
                value["steps"].append(copy.deepcopy(value["steps"][0]))
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                studio.validate(self.root, spec, self.plan)

    def test_workflow_stages_preserve_partial_order(self):
        value = self.spec["workflows"][0]
        value["steps"].append({"id": "parallel", "role": "qa-specialist", "skill": "guildborne-qa", "dependsOn": []})
        value["steps"][1]["dependsOn"].append("parallel")
        report = studio.workflow(self.root, self.spec, "small-slice")
        self.assertEqual([{step["id"] for step in stage} for stage in report["stages"]],
                         [{"inspect", "parallel"}, {"review"}])
        self.assertEqual({gate["id"] for gate in report["gates"]}, {"local-check", "human-review"})
        with self.assertRaises(ValueError):
            studio.workflow(self.root, self.spec, "missing")


class StudioGenerationTests(StudioFixture):
    def test_rendered_codex_toml_has_supported_keys_and_inherits_host_settings(self):
        files = studio.generated_files(self.root, self.spec, self.plan)
        role_files = {path: text for path, text in files.items() if path.startswith(".codex/agents/") and path.endswith(".toml")}
        self.assertEqual(len(role_files), len(self.spec["roles"]))
        for path, text in role_files.items():
            with self.subTest(path=path):
                config = tomllib.loads(text)
                self.assertEqual(set(config), {"name", "description", "developer_instructions"})
                self.assertTrue(all(isinstance(value, str) and value for value in config.values()))
                self.assertIn("guildborne-", config["developer_instructions"])

    def test_codex_text_roundtrips_unicode_quotes_newlines_and_delete_character(self):
        original = 'ตรวจสอบ "quoted" \\path\nSecond line\twith tab and DEL=' + chr(127)
        self.spec["roles"][2]["instructions"] = original
        files = studio.generated_files(self.root, self.spec, self.plan)
        config = tomllib.loads(files[".codex/agents/qa-specialist.toml"])
        self.assertIn(original, config["developer_instructions"])

    def test_parent_configuration_is_preserved(self):
        path = self.root / ".codex/config.toml"
        path.parent.mkdir(parents=True)
        original = b'model = "user-choice"\nsandbox_mode = "read-only"\napproval_policy = "never"\n'
        path.write_bytes(original)
        studio.generate(self.root, self.spec, self.plan)
        self.assertEqual(path.read_bytes(), original)

    def test_generation_is_deterministic_and_manifest_hashes_match(self):
        self.assertEqual(studio.generated_files(self.root, self.spec, self.plan),
                         studio.generated_files(self.root, copy.deepcopy(self.spec), copy.deepcopy(self.plan)))
        studio.generate(self.root, self.spec, self.plan)
        manifest_path = self.root / "production/studio/generated-manifest.json"
        first = manifest_path.read_bytes()
        manifest = forge.read_json(manifest_path)
        expected = studio.generated_files(self.root, self.spec, self.plan)
        self.assertEqual(set(manifest["outputs"]), set(expected))
        for path, sha in manifest["outputs"].items():
            self.assertEqual(hashlib.sha256((self.root / path).read_bytes()).hexdigest(), sha)
        for path, sha in manifest["sources"]["files"].items():
            self.assertEqual(forge.digest(self.root / path), sha)
        studio.generate(self.root, self.spec, self.plan)
        self.assertEqual(manifest_path.read_bytes(), first)
        self.assertEqual(studio.generate(self.root, self.spec, self.plan, check=True)["status"], "PASS")

    def test_check_mode_never_creates_missing_outputs(self):
        with self.assertRaises(ValueError):
            studio.generate(self.root, self.spec, self.plan, check=True)
        self.assertFalse((self.root / ".codex/agents").exists())

    def test_foreign_existing_output_is_not_overwritten_without_manifest(self):
        output = next(path for path in studio.generated_files(self.root, self.spec, self.plan) if path.endswith(".toml"))
        path = self.root / output
        path.parent.mkdir(parents=True)
        path.write_text("# User-authored\n", encoding="utf-8")
        with self.assertRaises(ValueError):
            studio.generate(self.root, self.spec, self.plan)
        self.assertEqual(path.read_text(encoding="utf-8"), "# User-authored\n")

    def test_changed_managed_output_is_not_clobbered_or_reapproved(self):
        studio.generate(self.root, self.spec, self.plan)
        output = next(path for path in studio.generated_files(self.root, self.spec, self.plan) if path.endswith(".toml"))
        path = self.root / output
        path.write_text("# User change after generation\n", encoding="utf-8")
        before = (self.root / "production/studio/generated-manifest.json").read_bytes()
        for check in (True, False):
            with self.subTest(check=check), self.assertRaises(ValueError):
                studio.generate(self.root, self.spec, self.plan, check=check)
        self.assertEqual(path.read_text(encoding="utf-8"), "# User change after generation\n")
        self.assertEqual((self.root / "production/studio/generated-manifest.json").read_bytes(), before)

    def test_changed_sources_require_regeneration(self):
        studio.generate(self.root, self.spec, self.plan)
        self.spec["roles"][2]["instructions"] += " Review a new requirement."
        self.save_sources()
        with self.assertRaises(ValueError):
            studio.generate(self.root, self.spec, self.plan, check=True)
        studio.generate(self.root, self.spec, self.plan)
        self.assertEqual(studio.generate(self.root, self.spec, self.plan, check=True)["status"], "PASS")

    def test_changed_canonical_skill_is_detected_even_with_unchanged_spec(self):
        studio.generate(self.root, self.spec, self.plan)
        path = self.root / ".agents/skills/guildborne-qa/SKILL.md"
        path.write_text(path.read_text(encoding="utf-8") + "\nNew independent review requirement.\n", encoding="utf-8")
        with self.assertRaises(ValueError):
            studio.verify(self.root, self.spec, self.plan)
        studio.generate(self.root, self.spec, self.plan)
        self.assertEqual(studio.verify(self.root, self.spec, self.plan)["status"], "PASS")

    def test_path_preflight_rejects_late_collision_before_any_outputs_are_written(self):
        catalog = self.root / "production/studio/catalog.json"
        catalog.write_text("User authored catalog, retain unchanged.\n", encoding="utf-8")
        with self.assertRaises(ValueError):
            studio.generate(self.root, self.spec, self.plan)
        self.assertFalse((self.root / ".codex/agents").exists())
        self.assertEqual(catalog.read_text(encoding="utf-8"), "User authored catalog, retain unchanged.\n")

    def test_stale_role_file_is_detected_without_deleting_it(self):
        studio.generate(self.root, self.spec, self.plan)
        extra = self.root / ".codex/agents/obsolete.toml"
        extra.write_text("# Legacy role retained for explicit reconciliation\n", encoding="utf-8")
        with self.assertRaises(ValueError):
            studio.generate(self.root, self.spec, self.plan, check=True)
        self.assertTrue(extra.exists())

    def test_symlink_output_parent_cannot_write_outside_repo(self):
        with tempfile.TemporaryDirectory() as temporary:
            outside = Path(temporary)
            (self.root / ".codex").mkdir()
            try:
                (self.root / ".codex/agents").symlink_to(outside, target_is_directory=True)
            except OSError:
                self.skipTest("Symlink creation unavailable on this host")
            with self.assertRaises(ValueError):
                studio.generate(self.root, self.spec, self.plan)
            self.assertEqual(list(outside.iterdir()), [])

    def test_manifest_cannot_authorize_outside_or_git_paths(self):
        studio.generate(self.root, self.spec, self.plan)
        manifest_path = self.root / "production/studio/generated-manifest.json"
        original = forge.read_json(manifest_path)
        for path in ("../external.txt", ".git/config", "C:/outside.txt"):
            manifest = copy.deepcopy(original)
            manifest["outputs"][path] = "0" * 64
            forge.save_json(manifest_path, manifest)
            with self.subTest(path=path), self.assertRaises(ValueError):
                studio.generate(self.root, self.spec, self.plan)


class StudioRoutingTests(StudioFixture):
    def test_route_requires_preexisting_coordinator_without_creating_one(self):
        with self.assertRaises(ValueError):
            studio.route(self.root, self.spec, self.plan, "alpha", self.database)
        self.assertFalse(self.database.exists())

    def test_unrelated_sqlite_database_is_not_adopted_or_modified(self):
        self.database.parent.mkdir(parents=True)
        connection = sqlite3.connect(self.database)
        connection.execute("CREATE TABLE foreign_data (item TEXT)")
        connection.execute("INSERT INTO foreign_data VALUES ('preserve')")
        connection.commit()
        connection.close()
        before = self.database.read_bytes()
        with self.assertRaises(ValueError):
            studio.route(self.root, self.spec, self.plan, "alpha", self.database)
        self.assertEqual(self.database.read_bytes(), before)

    def test_shared_ledger_symlink_is_rejected_without_following_it(self):
        self.ledger()
        alias = self.database.parent / "alias.sqlite3"
        try:
            alias.symlink_to(self.database)
        except OSError:
            self.skipTest("Symlink creation unavailable on this host")
        with self.assertRaises(ValueError):
            studio.route(self.root, self.spec, self.plan, "alpha", alias)

    def test_dependency_only_becomes_ready_after_independent_acceptance(self):
        ledger = self.ledger()
        self.assertEqual(studio.route(self.root, self.spec, self.plan, "alpha", self.database)["status"], "READY")
        self.assertFalse(studio.route(self.root, self.spec, self.plan, "beta", self.database)["ready"])
        token = ledger.claim("alpha", "writer")
        self.assertEqual(studio.route(self.root, self.spec, self.plan, "alpha", self.database)["status"], "ACTIVE")
        ledger.submit("alpha", token, self.packet("alpha"))
        self.assertEqual(studio.route(self.root, self.spec, self.plan, "alpha", self.database)["status"], "REVIEW")
        self.assertFalse(studio.route(self.root, self.spec, self.plan, "beta", self.database)["ready"])
        ledger.accept("alpha", "independent-reviewer")
        self.assertEqual(studio.route(self.root, self.spec, self.plan, "beta", self.database)["status"], "READY")
        self.assertEqual(studio.route(self.root, self.spec, self.plan, "alpha", self.database)["status"], "ACCEPTED")

    def test_expired_owner_still_blocks_overlapping_and_exclusive_work(self):
        for environment, scope in (("local", "src/alpha/child"), ("studio", "src/disjoint"), ("blender", "src/disjoint")):
            with self.subTest(environment=environment):
                self.plan["tasks"][0]["environment"] = environment
                self.plan["tasks"][1] = task("beta", scope, environment=environment)
                database = self.root / f"build/agentic/{environment}.sqlite3"
                ledger = forge.Ledger(database, self.root, self.plan)
                self.addCleanup(ledger.close)
                token = ledger.claim("alpha", "stopped-but-not-released", now=0)
                report = studio.route(self.root, self.spec, self.plan, "beta", database)
                self.assertFalse(report["ready"])
                self.assertTrue(report["blockers"])
                ledger.release("alpha", token)
                self.assertTrue(studio.route(self.root, self.spec, self.plan, "beta", database)["ready"])

    def test_route_preserves_task_scopes_and_skill_without_tokens(self):
        ledger = self.ledger()
        token = ledger.claim("alpha", "writer")
        report = studio.route(self.root, self.spec, self.plan, "alpha", self.database)
        self.assertEqual(report["writeScopes"], ["src/alpha"])
        self.assertEqual(report["skill"], "guildborne-qa")
        self.assertNotIn(token, json.dumps(report))
        self.assertNotIn("token", report)

    def test_handoff_requires_current_lease_exact_owner_and_scoped_path(self):
        self.prepared()
        ledger = self.ledger()
        token = ledger.claim("alpha", "writer")
        arguments = [("writer", "wrong", None), ("other", token, None), ("writer", token, ["src/beta/outside.luau"]),
                     ("writer", token, ["src"]), ("writer", token, ["../outside.luau"])]
        for owner, supplied, paths in arguments:
            with self.subTest(owner=owner, paths=paths), self.assertRaises(ValueError):
                studio.handoff(self.root, self.spec, self.plan, "alpha", self.database, owner, supplied, paths=paths)
        report = studio.handoff(self.root, self.spec, self.plan, "alpha", self.database, "writer", token,
                                paths=["src/alpha/owned.luau"])
        self.assertTrue(self.prompt(report).is_file())
        ledger.release("alpha", token)
        with self.assertRaises(ValueError):
            studio.handoff(self.root, self.spec, self.plan, "alpha", self.database, "writer", token)

    def test_director_role_does_not_inherit_child_or_parent_file_ownership(self):
        self.spec["roles"][0]["skills"].append("guildborne-qa")
        self.spec["taskRoles"]["alpha"] = "director"
        self.save_sources()
        self.prepared()
        token = self.ledger().claim("alpha", "director-worker")
        for path in ("src", "src/beta/child.luau", "production/plan.json"):
            with self.subTest(path=path), self.assertRaises(ValueError):
                studio.handoff(self.root, self.spec, self.plan, "alpha", self.database, "director-worker", token, paths=[path])

    def test_delegation_prompt_contains_contract_but_never_lease_secret(self):
        self.prepared()
        token = self.ledger().claim("alpha", "writer")
        report = studio.handoff(self.root, self.spec, self.plan, "alpha", self.database, "writer", token)
        prompt = self.prompt(report).read_text(encoding="utf-8")
        for expected in ("alpha", "guildborne-qa", "src/alpha", "regression", "independent-review", "AGENTS.md", "Server owns rewards."):
            self.assertIn(expected, prompt)
        self.assertNotIn(token, prompt)
        self.assertNotIn(token, json.dumps(report))
        self.assertEqual(forge.digest(self.prompt(report)), report["promptSha256"])
        self.assertEqual(report["buildCommit"], forge.git_evidence.head(self.root))
        self.assertEqual(report["planSha256"], forge.git_evidence.plan_hash(self.plan))
        row = self.ledger().rows()[0]
        self.assertEqual(row["state"], "ACTIVE")

    def test_missing_or_expired_handoff_cannot_steal_ownership(self):
        self.prepared()
        ledger = self.ledger()
        with self.assertRaises(ValueError):
            studio.handoff(self.root, self.spec, self.plan, "alpha", self.database, "writer", "missing")
        token = ledger.claim("alpha", "expired", now=0)
        with self.assertRaises(ValueError):
            studio.handoff(self.root, self.spec, self.plan, "alpha", self.database, "expired", token)
        self.assertEqual(ledger.rows()[0]["owner"], "expired")

    def test_changed_plan_cannot_route_against_original_shared_ledger(self):
        self.ledger().claim("alpha", "writer")
        self.plan["tasks"][0]["brief"] += " Changed while worker active."
        with self.assertRaises(ValueError):
            studio.route(self.root, self.spec, self.plan, "alpha", self.database)


class StudioCliTests(StudioFixture):
    def test_cli_validate_generate_verify_workflow_and_route(self):
        self.ledger()
        for command in (("validate",), ("generate",), ("verify",), ("workflow", "--workflow", "small-slice"),
                        ("route", "--task", "alpha", "--ledger", str(self.database))):
            result = self.cli(*command)
            with self.subTest(command=command):
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIsInstance(json.loads(result.stdout), dict)

    def test_cli_handoff_claims_remain_active_and_prompt_is_not_acceptance(self):
        self.prepared()
        ledger = self.ledger()
        token = ledger.claim("alpha", "cli-writer")
        result = self.cli("handoff", "--task", "alpha", "--ledger", str(self.database), "--owner", "cli-writer",
                          "--token", token, "--path", "src/alpha/owned.luau")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        report = json.loads(result.stdout)
        self.assertNotIn(token, result.stdout + result.stderr)
        self.assertTrue(self.prompt(report).is_file())
        self.assertEqual(ledger.rows()[0]["state"], "ACTIVE")
        self.assertEqual(report["status"], "HANDOFF_ONLY_NOT_ACCEPTED")

    def test_cli_failure_is_nonzero_and_leaves_no_artifact(self):
        result = self.cli("verify")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / ".codex/agents").exists())
        result = self.cli("route", "--task", "missing", "--ledger", str(self.database))
        self.assertNotEqual(result.returncode, 0)


class StudioRepositoryTests(unittest.TestCase):
    def test_every_real_task_routes_to_role_owning_its_skill(self):
        spec, plan = studio.load(ROOT)
        studio.validate(ROOT, spec, plan)
        roles = {role["id"]: role for role in spec["roles"]}
        with tempfile.TemporaryDirectory() as temporary:
            database = Path(temporary) / "repository.sqlite3"
            ledger = forge.Ledger(database, ROOT, plan)
            try:
                for task_spec in plan["tasks"]:
                    with self.subTest(task=task_spec["id"]):
                        route = studio.route(ROOT, spec, plan, task_spec["id"], database)
                        role_id = spec["taskRoles"][task_spec["id"]]
                        self.assertIn(task_spec["skill"], roles[role_id]["skills"])
                        self.assertEqual(route["writeScopes"], task_spec["writeScopes"])
                        self.assertEqual(route["ready"], not task_spec["dependsOn"])
            finally:
                ledger.close()


if __name__ == "__main__":
    unittest.main()
