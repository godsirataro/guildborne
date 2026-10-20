"""Build a separate native Roblox component review place, without live game bootstraps."""
from pathlib import Path
import hashlib
import json
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

def main():
    output = ROOT / "build/gui-review"
    output.mkdir(parents=True, exist_ok=True)
    def source(path):
        return {"$path": str(ROOT / path)}
    project = {"name": "GuildborneGUIReview", "tree": {
        "$className": "DataModel",
        "ReplicatedStorage": {"$className": "ReplicatedStorage", "Shared": {
            "$className": "Folder", "Config": source("src/shared/Config"),
            "Data": source("src/shared/Data"), "Util": source("src/shared/Util")}},
        "StarterPlayer": {"$className": "StarterPlayer", "StarterPlayerScripts": {
            "$className": "StarterPlayerScripts", "Review": source("tests/gui/gallery.client.luau"),
            "UI": source("src/client/UI"),
            "Controllers": {"$className":"Folder", "AudioController":source("src/client/Controllers/AudioController.luau")}}},
        "Workspace": {"$className": "Workspace"},
    }}
    project_path = output / "review.project.json"
    project_path.write_text(json.dumps(project, indent=2), encoding="utf-8")
    place = output / "GuildborneGUIReview.rbxlx"
    subprocess.run([str(ROOT/".tools/rojo/rojo.exe"), "build", str(project_path), "--output", str(place)], check=True)
    items = ET.parse(place).getroot().findall(".//Item")
    assert not any(item.get("class") in {"Script", "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent"} for item in items), "Unsafe review place contents"
    assert sum(item.get("class") == "LocalScript" for item in items) == 1, "Unexpected client bootstrap"
    print(json.dumps({"place": str(place), "sha256": hashlib.sha256(place.read_bytes()).hexdigest(),
                      "status": "BUILT_NOT_STUDIO_TESTED", "server_scripts": 0}))

if __name__ == "__main__":
    main()
