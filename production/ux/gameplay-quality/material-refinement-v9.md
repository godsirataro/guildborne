# Ore and timber refinement — 2026-10-20

Base `e34a2e7`; task `gameplay-ui-quality`; owner `s14-ore-timber-v9`.

The controller's native 80px gallery showed stone/ore too similar and timber
ends resembling gears. This follow-up changes only iron ore and timber.

- Ore: darker, narrower host with larger silver patches embedded against its
  front face. Shortened metal faces avoid the earlier draft's projecting rods.
- Timber: two bundled logs with convex six-sided bodies constructed from a
  rectangular core and four triangular side quarters. The previous overlapping
  rotated-square outlines were removed, not merely renamed. Cut faces remain
  stylized rectangles inside the bark; this is not a circular high-detail model.

Ore uses 8 parts, timber 15; the complete kit uses 272. Other 28 definitions,
entire palette and runtime constructor remain identical to the base. No game
rules, server code, external assets or historical Blender exports changed.

`material_refinement_probe.py` checks the bounded diff, palette, constructor,
supported shapes and dimensions, every item's camera fit, and independently
parses all 272 emitted runtime pieces against the kit. It renders an 80px local
approximation, 2x nearest enlarged view and 48px downsample, explicitly separate
from native Studio evidence. Outputs are under
`assets/production/ui-slice/material-refinement-v9/`.

Checks run: source/runtime probe, deterministic generator, Luau compile and LSP
analysis. Full baseline was not rerun for this geometry-only refinement.
Independent read-only reviewer `material_review_v9` found no actionable issues
on final kit SHA256 `dd0cb8ead2e2ace8a7938d85395f7ab5622d8f3ae89a04a8b5f67a13f0e08afe`.
The native controller gallery retake is the next
acceptance step. No worker Studio/Blender calls, upload, publishing or push.
Studio acceptance of this revision, physical-device testing and human art
approval remain pending. This refinement does not close overall art acceptance.
