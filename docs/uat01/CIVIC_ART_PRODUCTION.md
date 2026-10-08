> Updated checkpoint: all six local NPC activity studies and twelve native city service buildings now exist; see CIVIC_CONTACT_SIX.md and CIVIC_SERVICE_ARCHITECTURE.md. Historical pending counts below describe their original checkpoint. Final likeness, main-world NPC replacement and human approval remain pending.

# Six-city art and motion priority — 2026-10-06

User direction: prioritize final-looking cities, NPC models faithful to project references, and animations matched to weapons, skills and daily activities. This priority applies to the existing first-release scope.

Reference baseline: assets/uat01/civic-community/concept-v1.png. Preserve its six readable silhouettes, navy/ivory human marshal, green elf gardener, copper dwarf smith, purple cartographer, teal harbor official and friendly green Orc cook. The single perspective image is an art reference; hidden surfaces require authored interpretation. Existing 226-part civic rigs and generic motion are blockouts pending replacement/polish.

## First production slice

Deepforge / Smith Borin is the first contact-animation reference: dwarf silhouette, braided beard, leather apron, gloves, hammer and tongs. Build a matching anvil station; the tongs hold the workpiece while the hammer strikes it. Use this slice to establish mesh, rig, hand grip, foot contact, animation marker, sound and VFX conventions before adapting the other five professions.

| City / NPC | Model identity | Activity and prop contact | Motion, VFX and audio alignment |
| --- | --- | --- | --- |
| Crownford / Elian | Navy coat, ivory sash, brass seal, charter | Read charter on desk, point at a line, stamp paper | Paper movement and stamp sound at actual hand contact |
| Sylvaris / Vaela | Elf ears, pale hair, green gardening clothes | Support seedling tray, prune plant, water soil | Blade contact at branch; water starts at tilted vessel mouth |
| Deepforge / Borin | Short dwarf proportions, braided beard, apron | Tongs on workpiece, hammer on anvil | Contact marker controls spark and strike sound; hammer recovers before next strike |
| Astralis / Nyra | Purple mantle, dark tied hair, star chart | Hold chart, trace symbols, inspect prism | Finger follows chart; subtle prism glow follows survey phase |
| Crosshaven / Sela | Teal coat, harbor hat, cargo ledger | Write ledger, close book, signal ship | Pen contacts page; cloth and flag motion follow arm direction |
| Ironroot / Roka | Friendly Orc face/tusks, broad shoulders, ivory apron | Hold bowl, stir, serve meal | Ladle stays inside bowl during stir; steam from food, serving sound at transfer |

## Shared animation production rules

- Keep distinct clips for unarmed, sword, heavy weapon, bow and staff grips. Match skill anticipation, release/contact and recovery to the actual equipped weapon and gameplay timing.
- Author grip sockets and prop pivots before animation. A held prop follows its hand; a placed prop follows its station. Explicit transfer events prevent popping or duplicate props.
- Use named contact/release markers for cosmetic VFX/audio. Server combat remains authoritative; decorative work markers grant no damage, items or rewards.
- Test interruption by greeting, walking, menu, reduced motion, distance culling and removal. Restore joints and stop transient effects/audio cleanly.
- Validate weapon/prop clipping, stationary feet, reach to the station and loop seams in Blender and Studio. Skeleton/mesh import and ordinary gameplay must be checked separately.

## City finishing order

Each city needs a recognizable arrival view, architecture kit, market and tavern interiors, profession station, signs, lighting, ambience and navigation. Finish one connected street and two usable service interiors before multiplying buildings. Reuse modular construction while preserving each region's materials and silhouette.

## Acceptance and honest status

Require reference-versus-render front/side comparisons, editable Blender source, reviewed exports, correct imported rig scale, contact animation preview and ordinary-input Studio demonstration. A file export or passing unit test alone does not make a final art asset approved. Human visual acceptance, platform imports, mobile performance and the other five city journeys remain pending.

Current baseline: six civic blockout rigs, six eight-second upper-body work references, six exploration cities with shared market/tavern bindings. New reference-faithful meshes and detailed contact animations have not yet been completed under this priority.
