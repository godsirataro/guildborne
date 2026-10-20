"""Actual InventoryView, Localization, Equipment and Content; recording pane only."""
from pathlib import Path
import subprocess,tempfile
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
def q(s): return '[====['+s+']====]'
code=''
for name,path in [('Equipment','src/shared/Data/Equipment.luau'),('Locale','src/shared/Config/Localization.luau'),('Content','src/server/Config/Content.luau')]:
    code+=f'local {name}=assert(loadstring('+q((ROOT/path).read_text(encoding='utf-8-sig'))+'))()\n'
code+='local source='+q((ROOT/'src/client/UI/InventoryView.luau').read_text(encoding='utf-8-sig'))+'\n'
code+=(HERE/'hall_label_behavior.luau').read_text(encoding='utf-8')
with tempfile.TemporaryDirectory(prefix='hall-label-') as folder:
    entry=Path(folder)/'run.luau';entry.write_text(code,encoding='utf-8')
    raise SystemExit(subprocess.run([str(ROOT/'.tools/luau/luau.exe'),str(entry)],cwd=ROOT).returncode)
