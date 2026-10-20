# Shared character foundation: bounded continuation

2026-10-21. Source intake: `0dfdad55b036a13628dba1dae7f7642d2ffe462e`.
Latest supported quota: 32% weekly used / 68% remaining. Stop new work at
30% remaining; no shutdown. Full game completion and human art acceptance
remain outstanding.

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
