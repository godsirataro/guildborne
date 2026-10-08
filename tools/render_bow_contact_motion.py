"""Actual Blender motion frames, one two-second draw/release/recovery cycle."""
from pathlib import Path
import bpy
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/bow-contact-v1';F=R/'build/bow-contact-motion';F.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(O/'Guildborne_Bow_Contact.blend'));s=bpy.context.scene;s.render.resolution_x=480;s.render.resolution_y=480;s.cycles.samples=4
for frame in range(60):
 s.frame_set(frame);s.render.filepath=str(F/f'{frame:03}.png');bpy.ops.render.render(write_still=True)
print('BOW_CONTACT_MOTION_FRAMES',60)
