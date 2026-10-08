# Longbow contact and reload study

Checkpoint: 2026-10-06. This is an isolated art study, not accepted gameplay combat.

- Editable Blender scene, GLB and FBX: `assets/uat01/bow-contact-v1/`.
- Existing original yew longbow geometry; 16 body bones and 2 flexible bow bones, 3,218 triangles including quiver, arrow and strings.
- Six seconds at 30 fps, containing three two-second review cycles. Draw, release, recoil, reach to quiver, withdraw arrow along the quiver axis, rotate and nock. This review timing does not change attack cadence or damage rules.
- GLB and FBX clean imports each passed 40 sampled poses, including hand/string contact, fixed feet, arrow flight, quiver-axis withdrawal and clearance at extraction.
- Local Roblox EditableMesh review uses four MeshParts and 23 bones. Its 36 sampled poses passed with maximum contact error 0.00007405 stud; no profile writes. Evidence: `validation-bow-contact-native.json`.
- Standalone review place: `build/Guildborne_BowContactReview.rbxlx`; no HTTP service, game economy or player character required.
- Updated ordinary mouse checks reached Pickup at 1.10 seconds and Nock at 1.85 seconds, both paused; fresh console output was empty. Native screenshot: `evidence/bow-contact-native-nock.png`.
- `motion-with-sound.mp4` is the updated 60-frame, 480-square H.264/AAC review video. Container tracks passed checks and frame 43 was decoded and visually inspected after regeneration. `motion.gif` contains the same cycle without sound.
- Review audio reuses the existing original bow-release WAV at 0.24, 2.24 and 4.24 seconds. It is a synchronized mix, not a new unique sound or uploaded SoundId.

Pending: final archer/NPC likeness, skin and acting polish, R6/R15 retargeting, gameplay weapon-hand bindings, blending with locomotion and skills, authoritative hit/release alignment, asset upload IDs, mobile performance, listening review and human approval. Numeric contact checks do not prove absence of all body/cloth intersections. No published AnimationId or gameplay completion is claimed.

Rebuild: run `blender_bow_contact.py`, both modes of `verify_bow_contact.py`, `export_bow_native_review.py`, `build_bow_contact_preview.py`, `render_bow_contact_motion.py`, then `encode_bow_motion.py` and `verify_bow_video.py`. Blender scripts require Blender background mode with `--python-exit-code 1`. The native probe is `tests/studio_bow_contact_probe.luau` and operates only on the isolated art fixture.
