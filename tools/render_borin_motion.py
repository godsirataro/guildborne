"""Render a two-second local motion preview at 15fps from the actual v2 rig."""
from pathlib import Path
import bpy
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/borin-forge-v2';F=R/'build/borin-motion-v2';F.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(O/'Guildborne_Borin_Forge.blend'))
s=bpy.context.scene;s.render.resolution_x=560;s.render.resolution_y=560;s.cycles.samples=4
for n in range(30):
 s.frame_set(n*2);s.render.filepath=str(F/f'{n:03}.png');bpy.ops.render.render(write_still=True)
print('BORIN_MOTION_FRAMES',30)
