"""Exclusive Blender lease required. Render exact saved authored Walk, no edits to source blend."""
from pathlib import Path
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[3]
for actor in ('greenwood_scout', 'forest_captain'):
    folder = ROOT / 'assets/production/enemy-slice/review' / actor
    bpy.ops.wm.open_mainfile(filepath=str(folder / 'source-review.blend'), use_scripts=False)
    scene = bpy.context.scene
    rig = next(o for o in scene.objects if o.type == 'ARMATURE')
    action = bpy.data.actions['Guildborne_Walk_ForearmLoop']
    rig.animation_data.action = action
    rig.animation_data.action_slot = action.slots[0]
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 8
    scene.render.resolution_x = scene.render.resolution_y = 320
    scene.render.resolution_percentage = 100
    camera = scene.camera
    original = camera.matrix_world.copy()
    # Preserve the already fitted review composition; second view rotates it
    # around the rig's vertical axis, keeping the complete mesh in view.
    from mathutils import Matrix
    for view, angle in (('front', 0), ('side', 1.5707963267948966)):
        camera.matrix_world = Matrix.Rotation(angle, 4, 'Z') @ original
        output = folder / 'walk-loop' / view
        output.mkdir(parents=True, exist_ok=True)
        for frame in range(30):
            scene.frame_set(frame)
            scene.render.filepath = str(output / f'{frame:03d}.png')
            bpy.ops.render.render(write_still=True)
    print('WALK_REVIEW_RENDERED', actor, flush=True)
