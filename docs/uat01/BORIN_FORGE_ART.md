# Borin forge art slice — 2026-10-06

User priority is reference-faithful city/NPC art and activity/weapon-specific motion. Borin is the first detailed contact study. The original community image guides dwarf proportions, ginger braided beard, leather apron, shoulder straps, gloves and metal tools. This local model is an interpretation with a softer toy-like face; exact likeness and human approval remain pending.

Editable source: [Borin forge Blender](../../assets/uat01/borin-forge-v1/Guildborne_Borin_Forge.blend). Export: [skeletal GLB](../../assets/uat01/borin-forge-v1/Borin_Forge.glb). Images: [contact](../../assets/uat01/borin-forge-v1/contact.png), [wind-up](../../assets/uat01/borin-forge-v1/windup.png).

The character uses 16 named bones matching the existing civic skeleton naming convention, rigid skin weights, and a six-second animation with three strikes at frames30/90/150 (30fps). Analytic two-bone reach preserves arm lengths; left hand holds the tongs steady, right hand lifts the hammer vertically. Feet/root stay fixed. Props share their holding-hand skin weights. Naming agreement alone does not certify Roblox retargeting or import compatibility.

Nine local spark meshes animate from each contact. Original synthetic hammer audio and a six-second review sequence use the same times1/3/5seconds: [single strike](../../assets/uat01/borin-forge-v1/forge_strike.wav), [timed sequence](../../assets/uat01/borin-forge-v1/forge_contact_review.wav), [cue sheet](../../assets/uat01/borin-forge-v1/cue-sheet.json). Technical waveform timing and peak checks pass; listening and Roblox sound import remain pending.

Clean Blender GLB reimport verifies evaluated hammer geometry against the actual workpiece surface at all three contacts, wind-up clearance, stationary feet/root, loop seam and skin weights. Source/export checks are local art evidence. The new mesh, animation, sparks and sounds are not yet bound to the playable Borin; the existing city rig/work gestures still run there. All platform IDs remain unassigned.

First export validation exposed a contact mismatch: the check initially imported into Blender's default24fps while the clip was authored30fps. The authoring pipeline also now explicitly uses quaternion rotation and updates parent bone transforms before setting child transforms. Verification uses30fps and evaluated skinned geometry rather than only computed hand positions.

Remaining polish: closer reference face/hair and costume silhouette, natural hammer wrist arc and body weight shift, finer hand grips, cloth deformation, collision review, LOD/performance, Roblox mesh/rig/animation import, runtime interruption/distance/reduced-motion cleanup, and human visual/audio acceptance. The forge backdrop is a modular station study, not completed Deepforge architecture.
