"""Encode original Blender render frames as a review GIF, without editing source frames."""
from pathlib import Path
from PIL import Image, ImageSequence
import hashlib,json
root=Path(__file__).resolve().parents[1];paths=sorted((root/'build/enemy-motion').glob('*.png'));assert len(paths)==24
frames=[Image.open(p).convert('RGB') for p in paths]
out=root/'assets/uat01/enemy-kit/walk-preview.gif';frames[0].save(out,save_all=True,append_images=frames[1:],duration=42,loop=0,optimize=False)
for frame in frames:frame.close()
source_unique=len({hashlib.sha256(frame.tobytes()).hexdigest() for frame in [Image.open(p).convert('RGB') for p in paths]})
assert source_unique>=12,'Walk preview has insufficient visible motion'
with Image.open(out) as im:
    encoded_frames=im.n_frames
    duration=sum(frame.info.get('duration',0) for frame in ImageSequence.Iterator(im))
    # GIF uses centiseconds and coalesces identical adjacent frames while preserving time.
    assert encoded_frames>=12 and duration==24*40,(encoded_frames,duration)
(out.parent/'walk-preview-report.json').write_text(json.dumps({'sourceFrames':24,'uniqueSourceFrames':source_unique,'encodedFrames':encoded_frames,'durationMs':duration,'adjacentDuplicateFramesCoalesced':24-encoded_frames},indent=2)+'\n',encoding='utf-8')
print('ENEMY_WALK_PREVIEW',out.stat().st_size,'bytes')
