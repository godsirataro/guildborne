"""No Studio required; verifies fail-closed static MCP preflight behavior."""
import importlib.util
from contextlib import redirect_stdout
import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[2] / "tools/agentic/studio_mcp_preflight.py"
spec = importlib.util.spec_from_file_location("guildborne_studio_preflight", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

CANONICAL = """[mcp_servers.Roblox_Studio]
command = 'cmd.exe'
args = ['/c', 'cd /d %LOCALAPPDATA%\\Roblox && .\\mcp.bat']
"""


class StudioMcpPreflightTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.config = self.root / "config.toml"
        self.env = {"LOCALAPPDATA": str(self.root / "appdata")}

    def inspect(self, platform="win32"):
        return module.inspect_config(self.config, platform=platform, env=self.env)

    def create_launcher(self):
        launcher = Path(self.env["LOCALAPPDATA"]) / "Roblox" / "mcp.bat"
        launcher.parent.mkdir(parents=True, exist_ok=True)
        launcher.write_text("echo mock-not-executed", encoding="utf-8")

    def test_missing_config_fails_closed(self):
        report = self.inspect()
        self.assertEqual(report["status"], "NOT_CONFIGURED")
        self.assertFalse(report["connected"])

    def test_valid_static_registration_requires_existing_launcher(self):
        self.config.write_text(CANONICAL, encoding="utf-8")
        self.assertEqual(self.inspect()["status"], "STUDIO_LAUNCHER_MISSING")
        self.create_launcher()
        report = self.inspect()
        self.assertEqual(report["status"], "CONFIGURED_NOT_CONNECTED")
        self.assertTrue(report["configured"])
        self.assertFalse(report["connected"])
        self.assertFalse(report["playtested"])

    def test_official_creator_hub_launcher_variant_is_supported(self):
        self.config.write_text("[mcp_servers.Roblox_Studio]\ncommand='cmd.exe'\n"
                               "args=['/c', '%LOCALAPPDATA%\\Roblox\\mcp.bat']\n", encoding="utf-8")
        self.create_launcher()
        self.assertEqual(self.inspect()["status"], "CONFIGURED_NOT_CONNECTED")

    def test_disabled_or_malformed_enabled_does_not_pass_strict_preflight(self):
        self.create_launcher()
        for value, status in [("false", "STUDIO_DISABLED"), ("'false'", "REVIEW_ENABLED_VALUE"),
                              ("1", "REVIEW_ENABLED_VALUE"), ("[]", "REVIEW_ENABLED_VALUE")]:
            with self.subTest(value=value):
                self.config.write_text(CANONICAL + "enabled = " + value + "\n", encoding="utf-8")
                report = self.inspect()
                self.assertEqual(report["status"], status)
                self.assertFalse(report["configured"])
                self.assertFalse(report["connected"])
                with patch.object(module, "inspect_config", return_value=report), redirect_stdout(io.StringIO()):
                    self.assertEqual(module.main(["--config", str(self.config), "--strict"]), 1)

    def test_explicitly_enabled_registration_remains_static_only(self):
        self.create_launcher()
        self.config.write_text(CANONICAL + "enabled = true\n", encoding="utf-8")
        report = self.inspect()
        self.assertEqual(report["status"], "CONFIGURED_NOT_CONNECTED")
        self.assertFalse(report["connected"])
        self.assertFalse(report["playtested"])

    def test_duplicate_registered_server_requires_review(self):
        self.config.write_text(CANONICAL + "\n[mcp_servers.old_roblox]\ncommand = 'StudioMCP'\n", encoding="utf-8")
        self.create_launcher()
        report = self.inspect()
        self.assertEqual(report["status"], "REVIEW_DUPLICATE_STUDIO")
        self.assertEqual(report["studioEntries"], ["Roblox_Studio", "old_roblox"])

    def test_noncanonical_entry_is_not_good_enough(self):
        self.config.write_text("[mcp_servers.old_roblox]\ncommand = 'StudioMCP'\n", encoding="utf-8")
        self.assertEqual(self.inspect()["status"], "NOT_CONFIGURED")

    def test_nonstandard_command_does_not_run(self):
        self.config.write_text("[mcp_servers.Roblox_Studio]\ncommand='potentially-malicious-executable'\n", encoding="utf-8")
        self.assertEqual(self.inspect()["status"], "REVIEW_UNKNOWN_COMMAND")

    def test_suspicious_shell_command_with_mcp_filename_is_rejected(self):
        self.config.write_text("[mcp_servers.Roblox_Studio]\ncommand='cmd.exe'\n"
                               "args=['/c', 'dangerous && .\\mcp.bat']\n", encoding="utf-8")
        self.create_launcher()
        self.assertEqual(self.inspect()["status"], "REVIEW_UNKNOWN_COMMAND")

    def test_non_string_argument_is_rejected_without_crashing(self):
        self.config.write_text("[mcp_servers.Roblox_Studio]\ncommand='cmd.exe'\n"
                               "args=[12, 'mcp.bat']\n", encoding="utf-8")
        self.create_launcher()
        self.assertEqual(self.inspect()["status"], "REVIEW_UNKNOWN_COMMAND")

    def test_malformed_config_and_oversized_config_are_sanitized(self):
        self.config.write_text("[mcp_servers\nSECRET_PASSWORD=do-not-echo", encoding="utf-8")
        self.assertEqual(self.inspect()["status"], "REVIEW_CONFIG_PARSE")
        self.assertNotIn("SECRET_PASSWORD", str(self.inspect()))
        self.config.write_bytes(b"x" * (module.MAX_CONFIG_BYTES + 1))
        self.assertEqual(self.inspect()["status"], "REVIEW_CONFIG_SIZE")

    def test_linux_does_not_claim_connection(self):
        self.config.write_text(CANONICAL, encoding="utf-8")
        self.create_launcher()
        report = self.inspect(platform="linux")
        self.assertEqual(report["status"], "UNSUPPORTED_LOCAL_HOST")
        self.assertFalse(report["connected"])

    def test_does_not_emit_environment_tokens(self):
        self.config.write_text(CANONICAL + "\n[mcp_servers.Roblox_Studio.env]\nSECRET='SHOULD_NEVER_LEAK'\n", encoding="utf-8")
        self.create_launcher()
        self.assertNotIn("SHOULD_NEVER_LEAK", str(self.inspect()))


if __name__ == "__main__":
    unittest.main()
