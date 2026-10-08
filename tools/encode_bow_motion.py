"""Encode actual rendered frames and authored cue using Blender's bundled encoder."""
from pathlib import Path
import bpy,sys
study='sword'if '--sword'in sys.argv else'bow'
R=Path(__file__).resolve().parents[1];O=R/f'assets/uat01/{study}-contact-v1';F=R/f'build/{study}-contact-motion'
assert all((F/f'{i:03}.png').exists()for i in range(60))
bpy.ops.wm.read_factory_settings(use_empty=True);s=bpy.context.scene;s.render.fps=30;s.frame_start=1;s.frame_end=60;s.render.resolution_x=480;s.render.resolution_y=480;s.render.resolution_percentage=100
editor=s.sequence_editor_create();strip=editor.strips.new_image('BowFrames',str(F/'000.png'),channel=1,frame_start=1)
for i in range(1,60):strip.elements.append(f'{i:03}.png')
strip.frame_final_duration=60
editor.strips.new_sound('OriginalWeaponCue',str(O/f'{study}_contact_review.wav'),channel=2,frame_start=1)
s.render.image_settings.media_type='VIDEO';s.render.image_settings.file_format='FFMPEG';s.render.ffmpeg.format='MPEG4';s.render.ffmpeg.codec='H264';s.render.ffmpeg.constant_rate_factor='HIGH';s.render.ffmpeg.audio_codec='AAC';s.render.ffmpeg.audio_bitrate=192;s.render.ffmpeg.audio_mixrate=48000
s.view_settings.view_transform='Standard';s.render.filepath=str(O/'motion-with-sound.mp4');bpy.ops.render.render(animation=True);print('BOW_VIDEO_ENCODED',s.render.filepath)
