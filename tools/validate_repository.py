"""Validate repository artifacts using only the Python standard library.

Checks structure, JSON/TOML, local Markdown links and fenced JSON fixtures.
Does not claim to validate Roblox runtime behavior or distributed protocols.
"""

from pathlib import Path
import argparse
import json
import re
import sys
import tomllib
import xml.etree.ElementTree as ET
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
REQUIRED_DOCS = (
    "GAME_DESIGN", "ARCHITECTURE", "ECONOMY", "MARKETPLACE", "GUILD_WAR",
    "SECURITY", "ECONOMY_HEALTH", "DATA_MODEL", "ROADMAP",
    "PLATFORM_RESEARCH", "VALIDATION", "PHASE1_IMPLEMENTATION", "PHASE1_STUDIO_TEST",
    "ART_DIRECTION", "BLENDER_ASSET_BACKLOG", "PHASE1_5_IMPLEMENTATION", "PHASE1_6_IMPLEMENTATION",
    "COMBAT", "PHASE2_1_IMPLEMENTATION", "PHASE2_1_STUDIO_TEST",
    "EXPANSION_PLAN", "PROJECT_STATUS", "PHASE2_2_IMPLEMENTATION", "PHASE2_2_STUDIO_TEST",
    "INVENTORY", "PHASE2_3_IMPLEMENTATION", "PHASE2_3_STUDIO_TEST",
    "CITY_GUILD_DISPATCH", "PHASE3_CITY_STUDIO_TEST", "VFX",
    "BASE_BUILDING", "CLASS_SKILLS", "TOWER", "PHASE2_4_7_IMPLEMENTATION", "PHASE2_4_7_STUDIO_TEST",
    "PHASE4_5_IMPLEMENTATION", "PHASE4_5_STUDIO_TEST", "MARKET_EPOCHS", "MARKET_ARCHIVAL",
    "MARKET_RECOVERY", "MARKET_OPERATIONS_RUNBOOK", "PHASE4_5_LOAD_TEST", "PHASE4_5_MOBILE_DEVICE_ACCEPTANCE",
)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--place", type=Path)
    parser.add_argument("--sourcemap", type=Path)
    args = parser.parse_args()
    errors: list[str] = []
    checked_links = 0
    checked_fixtures = 0
    for name in REQUIRED_DOCS:
        path = ROOT / "docs" / f"{name}.md"
        if not path.is_file() or not path.read_text(encoding="utf-8").strip():
            errors.append(f"Missing or empty document: {path.relative_to(ROOT)}")

    project = json.loads((ROOT / "default.project.json").read_text(encoding="utf-8"))
    if project.get("tree", {}).get("$className") != "DataModel":
        errors.append("Rojo root must be a DataModel")

    def inspect_paths(node: object) -> None:
        if not isinstance(node, dict):
            return
        for key, value in node.items():
            if key == "$path":
                target = (ROOT / value).resolve()
                if not target.is_relative_to(ROOT) or not target.exists():
                    errors.append(f"Invalid Rojo source path: {value}")
            elif isinstance(value, dict):
                inspect_paths(value)

    inspect_paths(project["tree"])
    with (ROOT / "rokit.toml").open("rb") as stream:
        manifest = tomllib.load(stream)
    if not manifest.get("tools", {}).get("rojo"):
        errors.append("Missing pinned Rojo tool")

    markdown_files = [ROOT / "README.md", *sorted((ROOT / "docs").glob("*.md")), ROOT / "tests" / "README.md"]
    for path in markdown_files:
        body = path.read_text(encoding="utf-8")
        if len(re.findall(r"^```", body, flags=re.MULTILINE)) % 2:
            errors.append(f"Unbalanced code fences: {path.relative_to(ROOT)}")
        for fixture in re.findall(r"^```json\s*\n(.*?)^```", body, flags=re.MULTILINE | re.DOTALL):
            try:
                json.loads(fixture)
                checked_fixtures += 1
            except json.JSONDecodeError as exc:
                errors.append(f"Invalid JSON fixture in {path.name}: {exc}")
        for link in re.findall(r"\[[^\]]*\]\(([^)]+)\)", body):
            target = link.strip().strip("<>")
            parts = urlsplit(target)
            if parts.scheme or target.startswith("#"):
                continue
            resolved = (path.parent / unquote(parts.path)).resolve()
            checked_links += 1
            if not resolved.is_relative_to(ROOT) or not resolved.exists():
                errors.append(f"Broken local link in {path.name}: {target}")

    sources = sorted((ROOT / "src").rglob("*.luau"))
    for path in sources:
        if not path.read_text(encoding="utf-8").startswith("--!strict\n"):
            errors.append(f"Missing strict directive: {path.relative_to(ROOT)}")

    # Also check untracked files, which git diff --check alone cannot inspect.
    text_files = [ROOT / ".gitignore", ROOT / ".gitattributes", ROOT / "default.project.json", ROOT / "rokit.toml", *markdown_files, *sources]
    text_files.extend((ROOT / "tests").rglob("*.luau"))
    text_files.extend((ROOT / "tools").glob("*.py"))
    text_files.extend((ROOT / "tools").glob("*.ps1"))
    for path in text_files:
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.rstrip() != line:
                errors.append(f"Trailing whitespace: {path.relative_to(ROOT)}:{line_number}")

    if args.place:
        tree = ET.parse(args.place).getroot()
        scripts = []
        def inspect_item(item: ET.Element, prefix: str = "") -> None:
            name_node = item.find("Properties/string[@name='Name']")
            name = name_node.text if name_node is not None else item.attrib.get("class", "?")
            instance_path = f"{prefix}/{name}"
            kind = item.attrib.get("class")
            if kind in {"Script", "LocalScript", "ModuleScript"}:
                scripts.append((kind, instance_path))
                if kind == "ModuleScript" and "Server/" in instance_path and not instance_path.startswith("/ServerScriptService/"):
                    errors.append(f"Server module exposed: {instance_path}")
            for child in item.findall("Item"):
                inspect_item(child, instance_path)
        for item in tree.findall("Item"):
            inspect_item(item)
        expected = {("Script", "/ServerScriptService/Server/ServerBootstrap"), ("LocalScript", "/StarterPlayer/StarterPlayerScripts/Client/ClientBootstrap")}
        if {entry for entry in scripts if entry[0] != "ModuleScript"} != expected:
            errors.append("Built executable script boundaries differ from bootstrap contract")
        if len(scripts) != len(sources):
            errors.append("Built script/module count differs from source file count")

    if args.sourcemap:
        mapped = set()
        def inspect_map(node: dict) -> None:
            for value in node.get("filePaths", []):
                path = (ROOT / value).resolve()
                if path.suffix == ".luau":
                    mapped.add(path)
                    if not path.is_relative_to(ROOT / "src"):
                        errors.append(f"Non-runtime source shipped: {value}")
            for child in node.get("children", []):
                inspect_map(child)
        inspect_map(json.loads(args.sourcemap.read_text(encoding="utf-8")))
        if mapped != {path.resolve() for path in sources}:
            errors.append("Rojo sourcemap does not exactly cover runtime source files")

    if errors:
        print("Validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"PASS: {len(REQUIRED_DOCS)} design/evidence documents, JSON/TOML, Rojo paths,")
    print(f"      {checked_links} local links, {checked_fixtures} JSON fixture(s), {len(sources)} strict Luau files.")
    if args.place and args.sourcemap:
        print("PASS: built-place boundaries and exact runtime sourcemap coverage.")
    print("Roblox runtime behavior and external link availability are not checked here.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, TypeError, KeyError, ET.ParseError) as exc:
        print(f"Validation failed: {exc}", file=sys.stderr)
        sys.exit(1)
