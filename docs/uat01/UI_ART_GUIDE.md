# UI and art direction

Original Guildborne identity: an adventurer company in an inviting harbor kingdom. Strong landmark silhouettes and approachable island exploration take priority over dense decoration. Blox Fruits is an adventure-readability reference; the generated maps and characters are original proposals.

Native palette comes from Shared.Config.Art: navy background (15,21,35), card (26,34,49), ivory text (245,236,216), warm gold accent (220,183,107), burgundy action (91,39,53). Cyan supports arcane emphasis. Existing class/VFX colors are retained until a measured combat readability review justifies changes.

Prefer live text, native rounded panels and thin strokes; do not bake state or translated text into textures. Images are decorative and must degrade cleanly. Use native ViewportFrames for actual owned models. The concept UI's invented values are never authoritative. Thai/English strings need the same visual hierarchy and room to wrap.

World art uses deterministic Parts and the existing modular kit. IslandScenery adds ocean, shallow shelves, cliff rocks, a forest landmark, quarry terraces, rune ruins and two boat silhouettes. These are distant non-colliding scenery, not accessible levels. Current procedural fidelity is substantially simpler than the generated concept sheets.

Use the bestiary and hero sheets as modeling targets. Each final rig still needs scale/pivot, attachments, collisions, articulation, animation and permission checks. Model count is not behavior count. Imported dependencies must be recorded before use.
