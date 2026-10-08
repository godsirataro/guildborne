# Watchblade contact study — 2026-10-07

`assets/uat01/sword-contact-v1/` contains an editable Blender scene, GLB/FBX, static preview, GIF and H.264/AAC review video. The original watchblade kit is bound to the right palm. A 16-bone mannequin demonstrates guard, torso anticipation, cut, follow-through and recovery over three two-second cycles. This is a local animation study; it does not change combat damage or attack timing.

Both clean GLB and FBX imports passed all 181 sampled frames: stable hand/grip contact, fixed root/feet and closed loop seams. The blade centerline remained more than 1.42 studs from the head center in the GLB check. This geometric check does not prove all body/cloth clearance or final acting quality. The exported model has 31 meshes and 2,344 triangles.

The standalone native place `build/Guildborne_SwordContactReview.rbxlx` recreates the study with one EditableMesh MeshPart, 1,234 vertices and 16 Bones. All 181 native pose samples passed; maximum measured grip error was 0.00000055 stud. Ordinary mouse input selected Windup (0.20), Cut (0.30) and Recover (0.95), all paused. Console output was empty and Play was stopped. Evidence: `validation-sword-contact-native.json` and `evidence/sword-contact-native-cut.png`.

The six-second WAV is a synchronized reuse of `audio/combat/sword_swing.wav`, starting at 0.20, 2.20 and 4.20 seconds. It adds a review mix, not a new unique sound. Video track checks passed for 60 frames at 30 fps, 480 × 480 and AAC audio; listening approval remains pending. The Studio viewer is silent.

The video was also decoded at frame 10 and visually reviewed. The GIF/video show Blender motion without the later native trail. Roblox now has a separate untextured Trail that follows the actual blade endpoints during 0.20–0.45 seconds. A read-only live observer checked 100 samples (13 active / 87 inactive), with maximum endpoint error 0.0001221 stud. Ordinary mouse input disabled it for a full cycle, and selecting a paused cut suppressed it even when the toggle was On. Evidence: `validation-sword-contact-trail.json` and `evidence/sword-contact-native-trail.png`. This local trail does not yet replace full-game weapon/skill effects.

Pending: final character art, fingers/grip polish, footwork and locomotion blending, R6/R15 retargeting, authoritative hit timing, production trail binding and material impact variants, uploaded animation/sound IDs, device testing and human approval. This study does not complete the remaining weapon or skill animation set.

Rebuild with `blender_sword_contact.py`, `verify_sword_contact.py` (GLB and `--fbx`), `export_civic_native_review.py -- --sword`, `build_sword_contact_preview.py`, `render_sword_contact_motion.py`, `build_sword_review_media.py`, `encode_bow_motion.py -- --sword` and `verify_bow_video.py --sword`. Blender invocations require `--python-exit-code 1`.
