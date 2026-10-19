"""Execute actual NetworkService and extracted Bootstrap callbacks in a bounded fake host."""
from pathlib import Path
import argparse
import subprocess
import hashlib

root = Path(__file__).resolve().parents[3]
parser = argparse.ArgumentParser()
parser.add_argument("--luau", required=True)
args = parser.parse_args()
network = (root / "src/server/Services/NetworkService.luau").read_text(encoding="utf-8")
bootstrap = (root / "src/server/ServerBootstrap.server.luau").read_text(encoding="utf-8")
def between(start, end):
    assert bootstrap.count(start) == 1 and bootstrap.count(end) == 1
    return bootstrap.split(start, 1)[1].split(end, 1)[0]
gate = between("-- BEGIN Class3 candidate gate", "-- END Class3 candidate gate.")
gate = gate[gate.index("\n") + 1:]
code = between("-- BEGIN Class3 routing helpers.", "-- END Class3 routing helpers.")
code = code[code.index("\n") + 1:]
admission = "local function trialAdmission" + between("local function trialAdmission", "Network = require(script.Parent.Services.NetworkService)")
routing = "if HeroTrials then" + between("if HeroTrials then", 'require(script.Parent.Services.PurchaseService)')
setup = (folder := Path(__file__).parent) / "network-assertions.luau"
text = setup.read_text(encoding="utf-8")
text = text.replace("-- INSERT GATE", gate).replace("-- INSERT CODE", code).replace("-- INSERT ADMISSION", admission).replace("-- INSERT ROUTING", routing)
text = text.replace("-- INSERT NETWORK", network)
target = root / "build/agentic/class3-network-source-test.luau"
target.parent.mkdir(parents=True, exist_ok=True)
target.write_text(text, encoding="utf-8")
print("Network source SHA256", hashlib.sha256(network.encode()).hexdigest(), flush=True)
print("Bootstrap source SHA256", hashlib.sha256(bootstrap.encode()).hexdigest(), flush=True)
raise SystemExit(subprocess.run([args.luau, str(target)], cwd=root).returncode)
