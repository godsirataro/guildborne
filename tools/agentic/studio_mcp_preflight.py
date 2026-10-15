"""Read-only local Codex/Roblox Studio MCP registration preflight.

This only inspects a local TOML configuration and checks a local executable's
existence; it does not execute Codex/Studio, open an MCP connection or edit files.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import sys
import tomllib
from typing import Mapping

MAX_CONFIG_BYTES = 1024 * 1024
CANONICAL_NAME = "Roblox_Studio"


def _studio_command(server: object) -> bool:
    if not isinstance(server, dict):
        return False
    command = server.get("command", "")
    args = server.get("args", [])
    if not isinstance(command, str) or not isinstance(args, list):
        return False
    parts = [command] + [part for part in args if isinstance(part, str)]
    return any("studiomcp" in part.lower() or "mcp.bat" in part.lower() for part in parts)


def _expected_launcher(server: dict, platform: str) -> bool:
    """Require the reviewed Roblox launcher shape, not merely a matching suffix."""
    command, args = server.get("command"), server.get("args", [])
    if not isinstance(command, str) or not isinstance(args, list):
        return False
    if platform == "win32":
        return (command.lower() in ("cmd.exe", "cmd")
                and len(args) == 2 and all(isinstance(a, str) for a in args)
                and args[0].lower() == "/c"
                and args[1].lower().replace("/", "\\") in (
                    r"cd \d %localappdata%\roblox && .\mcp.bat",
                    r"%localappdata%\roblox\mcp.bat",
                ))
    if platform == "darwin":
        return Path(command).name == "StudioMCP" and not args
    return True  # Host is separately rejected as unsupported.


def _default_config(env: Mapping[str, str]) -> Path:
    base = env.get("CODEX_HOME")
    if base:
        return Path(base).expanduser() / "config.toml"
    if env.get("USERPROFILE") and sys.platform == "win32":
        return Path(env["USERPROFILE"]) / ".codex" / "config.toml"
    return Path.home() / ".codex" / "config.toml"


def inspect_config(
    config_path: Path,
    *,
    platform: str | None = None,
    env: Mapping[str, str] | None = None,
) -> dict[str, object]:
    """Return sanitized static registration findings without executing commands.

    No configuration values, credentials or command arguments appear in output.
    Only named server IDs, checks and next-step labels are returned.
    """
    platform = platform or sys.platform
    env = env if env is not None else os.environ
    result: dict[str, object] = {
        "status": "NOT_CONFIGURED",
        "configured": False,
        "connected": False,
        "playtested": False,
        "studioEntries": [],
        "checks": [],
        "nextStep": "Follow official Roblox Studio MCP quick-connect instructions.",
    }
    checks: list[str] = result["checks"]  # type: ignore[assignment]

    try:
        if not config_path.is_file():
            checks.append("Codex config.toml not found; no registration verified")
            return result
        if config_path.stat().st_size > MAX_CONFIG_BYTES:
            result["status"] = "REVIEW_CONFIG_SIZE"
            checks.append("Codex config exceeds the read-only preflight size budget")
            return result
        config = tomllib.loads(config_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, tomllib.TOMLDecodeError):
        result["status"] = "REVIEW_CONFIG_PARSE"
        checks.append("Codex configuration could not be read as valid UTF-8 TOML")
        return result

    servers = config.get("mcp_servers", {})
    if not isinstance(servers, dict):
        result["status"] = "REVIEW_CONFIG_SHAPE"
        checks.append("mcp_servers is not a TOML table")
        return result

    studio_names = sorted(
        name for name, value in servers.items()
        if name == CANONICAL_NAME or _studio_command(value)
    )
    result["studioEntries"] = studio_names
    if len(studio_names) > 1:
        result["status"] = "REVIEW_DUPLICATE_STUDIO"
        checks.append("Multiple Roblox Studio MCP registrations; avoid duplicate sessions")
        result["nextStep"] = "Review the duplicate entries before removing or changing any configuration."
        return result
    if not studio_names or studio_names[0] != CANONICAL_NAME:
        checks.append("Canonical Roblox_Studio entry absent")
        return result

    server = servers[CANONICAL_NAME]
    if not _studio_command(server) or not _expected_launcher(server, platform):
        result["status"] = "REVIEW_UNKNOWN_COMMAND"
        checks.append("Roblox_Studio registration does not match the reviewed official launcher command")
        return result

    result["configured"] = True
    result["nextStep"] = (
        "Open the approved Guildborne staging place, enable Studio MCP, "
        "start a new Codex session, and discover Studio tools and place identity."
    )
    if platform == "win32":
        appdata = env.get("LOCALAPPDATA")
        if not appdata:
            result["status"] = "STUDIO_LAUNCHER_UNVERIFIED"
            checks.append("LOCALAPPDATA unavailable; cannot verify local Roblox mcp.bat")
            return result
        launcher = Path(appdata) / "Roblox" / "mcp.bat"
        if not launcher.is_file():
            result["status"] = "STUDIO_LAUNCHER_MISSING"
            checks.append("Local Roblox mcp.bat was not found")
            return result
        checks.append("Windows Roblox MCP launcher exists")
    elif platform == "darwin":
        command = server.get("command", "")
        launcher = Path(command).expanduser()
        if launcher.name != "StudioMCP" or not launcher.is_file():
            result["status"] = "STUDIO_LAUNCHER_UNVERIFIED"
            checks.append("macOS StudioMCP binary not verified from registered command")
            return result
        checks.append("macOS Roblox StudioMCP launcher exists")
    else:
        result["status"] = "UNSUPPORTED_LOCAL_HOST"
        checks.append("Studio's local MCP integration requires Windows or macOS")
        return result
    result["status"] = "CONFIGURED_NOT_CONNECTED"
    checks.append("Static configuration only; MCP connection and Studio session are untested")
    return result


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, help="Path to an already-reviewed Codex config.toml")
    parser.add_argument("--strict", action="store_true", help="Exit nonzero unless static setup is configured")
    args = parser.parse_args(argv)
    report = inspect_config(args.config or _default_config(os.environ))
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if args.strict and report["status"] != "CONFIGURED_NOT_CONNECTED":
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
