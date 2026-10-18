"""Build a disposable native collector/route probe; never runs game services."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--rojo", type=Path, help="Existing Rojo executable; no downloads or installs.")
args = parser.parse_args()
local = ROOT / ".tools/rojo/rojo.exe"
rojo = args.rojo or (local if local.is_file() else shutil.which("rojo"))
if not rojo or not Path(rojo).is_file():
    parser.error("Pass --rojo with an existing executable path.")
out = ROOT / "build/campaign-route-probe"
out.mkdir(parents=True, exist_ok=True)


def source(path):
    return {"$path": str(ROOT / path)}


project = {"name": "GuildborneCampaignRouteProbe", "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {"$className": "ReplicatedStorage", "Shared": {
        "Config": {name: source(f"src/shared/Config/{name}.luau") for name in ("City", "CivicCities")},
        "Data": {name: source(f"src/shared/Data/{name}.luau") for name in ("QuestRoute", "CityWaypoint")}}},
    "StarterPlayer": {"$className": "StarterPlayer", "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "Probe": source("tests/gui/campaign_route_probe.client.luau"),
        "Client": {"UI": {"Components": {
            "CampaignRouteContext": source("src/client/UI/Components/CampaignRouteContext.luau")}}}}},
    "Workspace": {"$className": "Workspace"}}}


def folders(node):
    if "$path" not in node:
        node.setdefault("$className", "Folder")
        for key, child in node.items():
            if not key.startswith("$") and isinstance(child, dict):
                folders(child)


folders(project["tree"])
path = out / "probe.project.json"
path.write_text(json.dumps(project, indent=2), encoding="utf-8")
place = out / "GuildborneCampaignRouteProbe.rbxlx"
subprocess.run([str(Path(rojo).resolve()), "build", str(path), "--output", str(place)], check=True)
items = ET.parse(place).getroot().findall(".//Item")
assert not any(item.get("class") in {"Script", "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent"} for item in items)
assert sum(item.get("class") == "LocalScript" for item in items) == 1
print(json.dumps({"place": str(place), "sha256": hashlib.sha256(place.read_bytes()).hexdigest(),
                  "status": "BUILT_NOT_STUDIO_TESTED"}))
