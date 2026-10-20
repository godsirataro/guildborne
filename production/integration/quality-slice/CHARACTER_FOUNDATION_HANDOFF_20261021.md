# Shared character foundation: bounded continuation

2026-10-21. Source intake: `0dfdad55b036a13628dba1dae7f7642d2ffe462e`.
Latest supported quota: 37% weekly used / 63% remaining. Stop new work at
30% remaining; no shutdown. Full game completion and human art acceptance
remain outstanding.

Latest result: source4e15b6f/evidence9bd2bba completes local cosmetic hiding and
exact restoration; native grip alignment/attack retargeting failed. See the
latest section below. Earlier intake/ownership notes are historical.

## Ownership decision

Keep plan9 and the shared ledger
`C:/Work/MySelf/Guildborne/build/agentic/four-session-v10.sqlite3`.
No new checkout, duplicate controller or ledger. Controller owns the existing
integration checkout and Studio; S13/S14/S15/S17/S18 have no new runtime write
assignment in this wave. S14's existing checkout was clean at `9ad74a0`;
that inventory repair is already integrated as `0dfdad5`. Its later creator
audit stopped with workspace routing discovery timeout. Recovery was sent to
the original S14 chat, read-only, with no replacement worker on those files.

The previous controller lease expired while idle. Its owned GUI Play session
was stopped explicitly before releasing and reclaiming integration ownership.
Before character source edits, release integration and claim `character-import`;
those scopes overlap ServerBootstrap. Do not modify the plan to bypass this.
That existing task covers appearance rules/schema/renderer, the creator UI,
HeroRig and original character/clothing/accessory assets. HeroAnimator remains
outside that task: no inferred authorization to rewrite it.

S17 is design lead for shared appearance and the subsequent class/skill-tree
contract. S15 supplies motion/equipment-fit requirements. S14 supplies creator
UX. Controller owns source reconciliation, server/save validation, integration
and native verification. Independent read-only review may run concurrently.

## Frozen minimal contract for this slice

Use the current AppearanceService, AppearanceRules, AppearanceCatalog,
CharacterCustomizationUI and modular renderer. No second character pipeline.

| Concern | Required behavior |
| --- | --- |
| Identity | Player actor ID stays `player`; heroes use a distinct owned hero instance ID. Never infer ownership from a template or class. |
| Shared appearance | Preserve version1 fields: raceId, bodyPresetId, skinPaletteId, headPresetId, hairAssetId, hairColorId, beardAssetId, raceFeatures, outfitSlots. |
| Gender | A future versioned, server-validated cosmetic identity choice. Never infer it from Standard/Heavy, retroactively assign old saves, or expose an unsupported model variant as ready. Version1 currently has no gender field and rejects unknown fields. |
| Race | HUMAN/ELF/ORC/DWARF are cosmetic namespaces; Wizard is Human. Preserve legacy ancestry bonuses and earned progression. |
| Readiness | Only an actual asset/preset combination with fit evidence can become available. Catalog definitions, shared skeleton names and placeholder buttons are insufficient. |
| First fit pair | HUMAN_STANDARD, CHR_HEAD_HUMAN_01, ACC_HAIR_HUMAN_01, CLO_TUNIC_TRAVELER_01, CLO_TROUSERS_TRAVELER_01. Existing candidate files first. |
| Authority | Server validates actor ownership, revision, approved asset IDs, entitlement, slot/fit compatibility and readiness. Preview-only permission is not production entitlement. |
| Gear | Existing equipment owns weapons and stats. Cosmetic wardrobe must not grant or substitute gameplay equipment. |
| Saves | Preserve IDs, items, quests, progression and appearance-disabled migration defaults. No persistent schema rollout in this bounded preview/fit wave. |
| Fairness | No gender/class restrictions or bonuses; no cosmetic changes to combat reach, hitboxes or rewards. |

Current blocker confirmed by S15/S17 and source: production Renderer supports
Human Standard/Heavy placeholder overlays. Hero gameplay rig is R6. The separate
source-derived LocalGeometryRig has articulated joints, but explicitly rejects
unskinned flexible garments. It is isolated from gameplay rigs. These facts
must remain visible even if a local garment or motion repair passes.

Acceptance sequence: existing source/license and hash -> real mesh/rig/material
inspection -> removable garments and modesty -> articulated motion/attachment
fit -> actual player and owned-hero rendering -> native creator/equip lifecycle
-> visual review. Record each layer separately; no invented runtime asset IDs.
Human Standard alone cannot pass race x gender coverage.

## Other work retained behind the foundation

- S17 per-class Skill Trees reuse current canonical class IDs and 10/35/70
  gates. S15 motion/VFX/SFX, S14 UI, Controller server/save integration follow a
  shared contract before concurrent edits.
- Representative world slice uses the existing city/Borin workshop route and
  first Greenwood fight. Blocky fixtures are rejected as final art targets.
- Art gates include silhouette/material consistency, hand/weapon and foot
  contact, anticipation/impact/recovery, readable effects and cleanup, real
  licensed audio playback, lighting/navigation and responsive EN/TH UI.
- Desktop 60 FPS and mid-range Android 30 FPS are proposed performance targets,
  not measurements. Hardware/profile identification, sustained frame traces
  and physical-device verification remain pending.
- Optional hero work/training must first reuse/audit existing Dispatch. Any
  future implementation needs explicit start/stop, bounded server time/caps,
  exclusive actor reservation and replay-safe claims. No anti-idle emulation.
- S18 item families, rarity, enhancement, elements, sockets and crafting remain
  proposals. Lv1-100 is the first content wave; future101+ extensibility is
  design only, with no immediate change to approved Hall caps or old saves.
  Preserve existing recipes and separate hero professions from combat classes.
  New enhancement probabilities and crafting IDs are not approved balance.

## Concrete cloud QA handoff

One immutable existing model is available in the already-pushed repository:

- Repository: `https://github.com/godsirataro/guildborne`
- Commit: `71f4c4427b8419e612a8b1c7059d461c105dd2bb`
- Input: `assets/characters/export/CHR_BDY_HUMAN_STANDARD_V01.glb`
- Bytes: 111224
- SHA256: `db2370d83f1535326f72e88d27539cd1297433d42f3023b522c4e3effaf5785e`
- Optional source inspection: `assets/characters/source/CHR_BDY_HUMAN_STANDARD_V01.blend`
- Source bytes: 133711
- Source SHA256: `d2d0c49d61f811715553fb7aa898a001edf03c2aa4ccf45756e017ab90247226`

Cloud worker may read this revision through its authorized repository access;
verify the input hash before inspection. If repository access fails, report it
without changing permissions. Do not upload a different private snapshot.
Output outside the game checkout: report JSON, tool versions, exact argv,
unmodified raw output, input before/after hashes and optional inspection images.
Check finite coordinates/scales/bounds, the 15 named visible body objects,
material references and actual skeleton/weights/attachment structure against
the Shared Contract at the same revision. Do not confuse 15 body meshes with
15 total bones. Report unsupported evaluated geometry or compression honestly.
Do not edit or publish the model. Structural QA is not visual, deformation,
clothing fit or Roblox acceptance.

Cloud QA candidate `libfile_5417fd5a7db48191b6225a95ff65c6f2`
(`cloud-modular-qa-review.zip`, 291921 bytes,
SHA256 `b7ccd424a3cd4f841f96aec812b085a72b8d21583114371052aefdf912e05188`)
has **not been read or executed locally**. Tool discovery exposes Page-reference
readers requiring a Page ID and observed reference; they explicitly do not
support arbitrary ZIP archives. No standalone Library binary reader/download
route was found. An opaque Library ID alone is not a downloadable URL.
This is the exact candidate-review access blocker; do not bypass it with an
unrelated service. The cloud owner can supply reviewed source text through a
supported file/Page route, or perform this bounded model check in its own
authorized environment after inspecting the candidate. Parent-reported
synthetic tests are not local review or game acceptance.

ForgeGUI's existing generated inventory concept has been used for native UI
refinement. Free verified operations may support the slice. No new paid call:
an exact action/cost and spending limit are still needed for a new generation.
No purchase, publishing or persistent access change.

## Completed bounded continuation

Source7198429 and evidence2e283a6 now implement and verify the local Standard
garment/actor prototype described in the ownership decision above. See
[native results and exact remaining gates](../../character-import/human-standard-native-20261021/README.md).
The initially unsupported simultaneous pair exhausted EditableMesh memory;
shared immutable backing fixed that case without reducing the geometry.
Player and synthetic owned Warrior walked with separate elbow/knee motion.
Cleanup and server isolation passed; this is not production appearance rollout.

S14 recovered its original session and clean checkout; S17 reviewed this
contract without blocking issues. Cloud structural QA on the exact immutable
GLB completed and is incorporated as an attributed cloud report; raw cloud logs
and the inspector ZIP are not falsely represented as locally reviewed.
Current quota at this checkpoint is67% weekly remaining. Character-import lease
released after the reviewed source/evidence commits. The next deliverable is
legacy-cosmetic restoration plus actual grip/contact and attack inspection;
art, gender variants and the full shared-character foundation remain open.

## Latest completed gate: cosmetics repaired, grip/attack inspected

Sourcea0f0636 then4e15b6f and reviewed evidence9bd2bba implement the next bounded
gate above. [Native packet](../../character-import/human-standard-cosmetic-grip-20261021/README.md)
preserves63 hashed files, two new screenshots, exact source attribution and the
initial actual-avatar hair failure. Real Roblox hair used RigidConstraint rather
than Weld; the final narrow binding classifier fixes that actual case.

Final48 native policy assertions and actual player/owned Warrior hide/restore
checks pass, with all5 equipped player weapon parts preserved. Original22/45
part comparisons and5/38 WeldConstraint comparisons pass. Final resources,
backings, pending builds and handles are0. The Studio fixture is stopped in Edit.
Full unchanged4e15b6f baseline passed973 tests/399 strict files; warnings retained.
Independent code/evidence review passed. No saves/production renderer changed.

The player weapon remains welded to the old hand. The authored new grip was
0.111–2.234 studs outside the Grip box during99 walking samples. During31
action-window samples of an existing server-approved Basic, gap0.772–2.616
studs remained and new shoulder/elbow C0 did not change. Server recorded one
player Basic and14 damage. This is a failed weapon/retarget gate, not animation
acceptance. Five accepted Hold commands did not isolate companion AI; the lab
recorded one synthetic counter-only reward callback and profileWrites0. The
brief missing-Goblin read is retained. No video was recorded; the second static
image is after the return, not the strike frame.

Character-import was released; quality-slice-integration is held only for this
checkpoint and released after its commit. S15 received the exact result with a
read-only request for the smallest source-derived weapon presentation/action
retarget plan. No new writer, checkout, access, paid ForgeGUI or publishing.

Next owner must reclaim character-import (and explicitly reconcile any additional
scope) before implementing local weapon presentation plus server-approved action
retarget. Preserve original authoritative equipment, collision, actor identity,
timing and cleanup. Repeat the actual grip/contact gate before wiring production
renderer/creator. Gender, races, Heavy fit and art completion remain pending.
Current quota63% weekly remaining; stop new waves at30%; no shutdown.

## Latest bounded result: local weapon and server-event action retarget

Source `c4d34cf5214cd2deb8c0bc7ede8b04b61824c96a` and evidence `ac33040`
implement S15's reviewed proposal in local inspection modules. The production
renderer, save schema and source assets are unchanged.
[New native packet](../../character-import/human-standard-weapon-retarget-20261021/README.md)
contains30 hashed files/2,100,247 bytes with independent source/evidence review.

LocalWeaponPresentation validates and creates fresh five-part training-sword
geometry at the source socket; only validated originals receive reversible local
LTM. Server originals remain visible and preserve equipment, physics and welds.
LocalActionRetarget consumes fresh server-observed events via injected existing
ActionPose, with full joint-basis conversion and per-frame bind reset. No server
timing/damage/cooldowns or authoritative motion are changed by these helpers.

The revised Memory fixture suppresses Available recruitment models as well as
clearing the party. Server/client/probe verify actual hero count0.34 native weapon
policy assertions and14 standalone action checks pass. Walking120 samples and
attack270 samples show zero displayed grip/socket gap;35 active samples show
shoulder/elbow motion and exactly one start/completion. Existing Basic is accepted
for14 damage, with rewardCallbacks0/profileWrites0. Original player22parts/five
welds and server fiveweaponparts/fivewelds preserve compared state. Exact restore
passes; supplemental native lifecycle explicitly returns pending, backing,
reference, handle and helper connection counts to0. Studio stopped; original
fixture source restored and normal bootstraps disabled.

Contact remains OPEN: displayed Blade box is at least2.673 studs from the recorded
target point near the existing0.24s marker. This is not target-surface collision
proof. Grip alignment and server damage alone do not accept a visible strike.
Actual during-Basic screenshot and timestamped samples are archived; no video
was recorded because native recorder support/ffmpeg were unavailable. No tooling
installation, publishing, paid ForgeGUI call or access expansion was performed.

Full unchanged-candidate receipt f6cf672caf80467ca48e4f20eb38457b passes973 tests,
401 strict files and build/repository checks; existing stderr warnings preserved.
Reviewer approved source attribution, metrics, cleanup and all30 evidence hashes.
Art, faces/hair, garment fit, gender/other races, creator/renderer rollout and
physical-device/human acceptance remain open.

Next owner: reclaim character-import and reconcile existing client choreography
ownership before refining sword orientation/reach. Use the same zero-companion
lab, measure actual enemy geometry and contact-window frames, and preserve all
original physics/timing/cleanup invariants. No duplicate writer or worktree.
Character-import is released; quality-slice-integration is only held for this
handoff and released after commit. Current quota62% remaining; stop new waves
at30%; no shutdown.

## Latest bounded result: actual Blade-to-body sampled contact

Source `0fecd4a` and final fit `c60f44b`, with independently reviewed evidence
`a3a4ed8`, close the local sampled contact gate for the single zero-companion
Human Standard/Warrior/training_sword/Basic fixture. This supersedes the previous
OPEN strike-contact result only within that measured scope.

[Evidence, actual side-camera image and independent review](../../character-import/human-standard-strike-contact-20261021/README.md)
retain53 hashed files/9,329,013 bytes. Old baseline had zero overlaps/minimum
actual Block gap0.969238 studs; first .35 fit contacted but failed two conservative
floor bounds. Final Rx(pi+.45) and the local pose profile yield12 overlaps among
270 samples/36 active, including Tunic at0.252989s in Contact. All grip gaps0;
120 walk poses have no negative queried collidable-floor bounds, minimum+0.014695.
Invalid invisible-proxy floor query and both prior results remain unchanged.

No authoritative timing/damage/range/physics, source sizes, global ActionPose,
production renderer, saves or runtime IDs changed. Independent reviewer checked
16 source fingerprints and recomputed11,340 SAT comparisons without mismatch.
Full final baseline passes973tests/403strict files with existing warnings.
One accepted Basic deals14 damage; heroes/rewards/profile writes0. Original
equipment/client states restore exactly and resources/handles/pending/models0.
Camera restored; Studio stopped in Edit and original fixture sources restored.

Next owner must claim character-import before extending visual motion checks
across distances/orientations, representative targets, terrain and companion
motion. This does not accept continuous sweeps, exact Wedge contact, arbitrary
terrain, physical devices or final art. Faces/hair, clothing, gender/races,
GUI quality and creator/renderer rollout remain open. Character lease released;
quality-slice-integration held only for this handoff and released after commit.
Latest quota59% remaining; stop new waves at30%; no shutdown.
