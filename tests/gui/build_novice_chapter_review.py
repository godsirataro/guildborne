"""Build the real novice presentation with synthetic state and no server bootstrap."""
from pathlib import Path
import hashlib
import json
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
out = ROOT / "build/novice-chapter-review"
out.mkdir(parents=True, exist_ok=True)
def source(path):
    return {"$path": str(ROOT / path)}
project = {"name": "GuildborneNoviceChapterReview", "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {"$className": "ReplicatedStorage",
        "PreviewNoviceConfig": source("src/server/Config/NoviceChapter.luau"),
        "Shared": {"Config": {name: source(f"src/shared/Config/{name}.luau") for name in ("Art", "Localization")},
                   "Data": {"NoviceJourneyViewState": source("src/shared/Data/NoviceJourneyViewState.luau")}}},
    "StarterPlayer": {"$className": "StarterPlayer", "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts", "Review": source("tests/gui/novice_chapter_review.client.luau"),
        "Client": {"UI": {"NoviceJourneyView": source("src/client/UI/NoviceJourneyView.luau"),
            "DesignSystem": {"Theme": source("src/client/UI/DesignSystem/Theme.luau")},
            "Components": {name: source(f"src/client/UI/Components/{name}.luau") for name in
                           ("NoviceChapterCard", "GuildborneButton", "RegalOrnament")}}}}},
    "Workspace": {"$className": "Workspace"}}}
def folders(node):
    if "$path" not in node:
        node.setdefault("$className", "Folder")
        for key, child in node.items():
            if not key.startswith("$") and isinstance(child, dict):
                folders(child)
folders(project["tree"])
path = out / "review.project.json"
path.write_text(json.dumps(project, indent=2), encoding="utf-8")
place = out / "GuildborneNoviceChapterReview.rbxlx"
subprocess.run([str(ROOT / ".tools/rojo/rojo.exe"), "build", str(path), "--output", str(place)], check=True)
items = ET.parse(place).getroot().findall(".//Item")
assert not any(item.get("class") in {"Script", "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent"} for item in items)
assert sum(item.get("class") == "LocalScript" for item in items) == 1
print(json.dumps({"place": str(place), "sha256": hashlib.sha256(place.read_bytes()).hexdigest(), "status": "BUILT_NOT_STUDIO_TESTED"}))
