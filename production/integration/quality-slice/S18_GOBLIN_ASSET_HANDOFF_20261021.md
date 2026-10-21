# S18 Goblin equipment asset handoff — 2026-10-21

Recipient: **18-Item Created**, thread01a15a59-1223-75b2-b3d3-ea4f7355453c.
Human request in that chat: complete the Goblin set until it can be used/imported
in Roblox. This grants isolated asset production; no catalog, economy, schema,
balance, production renderer or save changes are assigned here.

## Exclusive scope and environment

Reuse the existing S18 main checkout; no new worktree/controller/ledger. Its
production/plan.json differs from the controller plan. Do not overwrite either
plan. For ledger commands use the authoritative controller root explicitly:

`python C:/Work/MySelf/Guildborne-controller/tools/agentic/forge.py --root C:/Work/MySelf/Guildborne-controller --ledger C:/Work/MySelf/Guildborne/build/agentic/four-session-v10.sqlite3 ...`

Before writing, S18 claims `enemy-quality-slice` with owner`s18-goblin-assets`.
Controller narrows that existing file lease to these NEW asset-family subtrees
inside its permitted scope (in S18's existing main checkout):

- `assets/production/enemy-slice/goblin-equipment/`: source, export and renders.
- `production/integration/enemy-quality/goblin-equipment/`: provenance, item
  manifest, reviewed asset-only Blender recipe, validation and handoff.

The lease name does not authorize changing enemy code or any other listed scope.
This equipment family is player/hero gear themed after Goblins, not permission to
replace an enemy body. Existing tools/blender_item_kit.py and blender_weapon_kit.py
are read-only references; put a new bounded recipe inside the assigned subtree.
No changes to runtime IDs, shield slots, catalog entries, item stats, loot,
enhancement, crafting recipes or market/save/network modules.

Before Blender processing, also claim `enemy-blender-window` under the same owner.
Fresh coordination checks: S13 turn is completed/notLoaded, world-quality-slice
and enemy-blender-window are unowned, and no blender.exe process was returned by
Win32_Process. This is the explicit stopped-worker handoff for that window.
Recheck both leases immediately before each write/run. If another owner wins,
wait; never steal a stale interactive session. Use installed binary
`C:/Program Files/Blender Foundation/Blender 5.2/blender.exe` with reviewed local
recipe and `--background --disable-autoexec`; no arbitrary downloaded scripts.

Studio remains controller-coordinated. Fresh f291dbaa-f592-422b-adc2-cf15a90e0173
state is Edit after the completed contact fixture; it is not assigned to S18.
Deliver reviewed files and an exact import/fit procedure before the controller
claims and performs the next isolated native verification. Do not open/mutate
other Studio instances. Publication/upload is not granted by this handoff.

## Actual rig contract

Controller source4f19d79 is the reference. HeroRig.luau builds a real R6 Humanoid
with Right Arm/Left Arm and six-part gameplay skeleton. Its Equip path accepts
RightHand or Right Arm and uses an actual Grip/Shaft with current .65 scaling.
Do not migrate gameplay rigs based on generic R15 skill guidance.

The Human Standard source-derived preview is separate: articulated R15-named
parts with RightHand/RightGripAttachment. LocalWeaponPresentation's current
training_sword-only copy and Rx(pi+.45) fit are a bounded test, not a universal
adapter or canonical orientation for new Goblin weapons. Flexible garments
without real skinning are unsupported by that preview. No outfit is usable
merely because its mesh exports.

Author each rigid item with explicit units, axis convention and named grip pivot;
preserve editable geometry and document separate measured R6 and preview fit
transforms. Start with one Warrior sword, review silhouette/materials against
the actual concept and validate export, then extend the same original family to
the other four class weapons, shield, three outfits and three accessories.
Outfits need actual matching source body/rig, weights/deformation or explicitly
rigid component construction; never claim R6/R15 interchangeability by naming.

## Deliverables and evidence

Preserve the four supplied concept job identities in provenance; inspect images
and provider terms before deriving geometry. Keep generated concept, editable3D,
Blender-validated export, Roblox-imported and Studio-equipped states separate.
Per item: source/export hashes, units/pivot, dimensions, triangles, material and
texture inventory, rig/deformation requirements, license/provenance, preview
renders and validation logs. Runtime IDs remain null until actual import.

Produce FBX/GLB where supported by the reviewed existing workflow, plus source
.blend and required textures. Validate round-trip and materials; source-generated
files alone do not prove native import/fit. No paid generation is assigned by
this handoff; any separate scoped human Forge authorization remains in S18's chat.

S18 reports exact changed files, source/export receipt, outstanding fit/import
gates and stopped Blender process, then releases both leases. Independent review
precedes controller integration/native verification. Preserve other dirty work;
commit only owned outputs after review. Latest observed quota59% remaining;
stop new waves at30%, no shutdown.
