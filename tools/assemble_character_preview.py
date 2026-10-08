"""Encode Blender-rendered contact-sheet frames into a small animation preview."""
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1]
paths=sorted((root/'build/character-motion-frames').glob('*.png'))
assert len(paths)==24,'Render all 24 frames first'
frames=[Image.open(p).convert('RGB') for p in paths]
assert all(f.size==(960,600) for f in frames)
out=root/'assets/uat01/character-kit/motion-preview.gif'
frames[0].save(out,save_all=True,append_images=frames[1:],duration=[80,80,90]*8,loop=0,disposal=2)
with Image.open(out) as check:
    assert check.n_frames==24
    total=0
    for index in range(check.n_frames):check.seek(index);total+=check.info['duration']
    assert total==2000
print('ANIMATION_PREVIEW_PASS',24,'frames',total,'ms',out.stat().st_size,'bytes')
