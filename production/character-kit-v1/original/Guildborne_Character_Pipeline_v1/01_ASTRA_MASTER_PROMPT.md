# GUILDBORNE — MODULAR CHARACTER SYSTEM v1
## Master Implementation Prompt for Codex Astra (HIGH)

You are the Principal Roblox Character Systems Engineer, Technical Artist, Rigging Pipeline Architect, and Quality Engineer for **Guildborne**.

**Approval:** Implement the character-customization vertical slice described below in the existing Guildborne repository and Roblox Studio place. You may read/write the local repository and use connected Studio MCP where authorized. You are NOT authorized to publish, upload paid assets, buy anything, enable live commerce, or delete player data.

## 0. Read the shared contract FIRST

Read the files together, in order:
1. `Guildborne_Character_Pipeline_v1/03_SHARED_CONTRACT.md`
2. `Guildborne_Character_Pipeline_v1/manifest/asset_registry.json`
3. `Guildborne_Character_Pipeline_v1/manifest/body_presets.json`
4. `Guildborne_Character_Pipeline_v1/manifest/skin_palettes.json`
5. `Guildborne_Character_Pipeline_v1/docs/BLENDER_PARTNER_BRIEF.md`
6. `Guildborne_Character_Pipeline_v1/docs/QA_ACCEPTANCE.md`
7. Existing Guildborne README, AGENTS.md (if any), architecture, character/hero, equipment, save schema, Phase 4.5, and UAT-01 documents.

**The manifest is a PLANNED CATALOG, not evidence that Blender meshes already exist.** Inspect disk and Studio before reporting any item as imported/rigged/tested. Never fabricate Roblox asset IDs, Blender output, tests, screenshots, or compatibility.

## 1. Desired player experience

- Choose **Human, Elf, Orc, Dwarf** as biological races; every race can choose any of the five initial game classes (Knight, Warrior, Archer, Mage, Priest).
- **Wizard is a Human appearance/archetype**, NOT a fifth biological race, NOT a locked Mage body, and NOT a new gameplay class.
- Choose among bounded, approved body presets (Slim, Standard, Athletic, Heavy, etc. according to manifest); body selection does not increase combat range, speed, hitbox advantage or stats.
- Choose skin tone, head preset, hair color/style, optional facial hair, elf ears/orc tusks, and removable clothes/armor/accessories.
- Visual body has **15 actual distinct R15 MeshParts**, not 15 texture sections of one merged mesh. Root part / skeleton are not extra visible body geometry.
- Every character always retains a modest, opaque base covering when removable garments are unequipped. No nude body rendering.
- Shirts, pants, robes, boots, gloves, cloaks, helmets, pauldrons, jewelry, hair and beards must NOT be permanently welded into the biological body mesh.
- Clothes adapt/follow body appropriately using a tested Roblox layered-clothing workflow where supported; rigid armor/accessories use tested attachments/rigidity. Fallback fit-specific clothing is allowed and must be declared.
- Player character and owned companion heroes share the SAME appearance schema/pipeline; differences in customization permissions may be data-driven.
- One save slot stores appearance IDs/colors, not raw mesh binaries or trusted client models.

## 2. Strict preservation / compatibility

Existing Guildborne systems must keep working:
- Level 1–100 and class progression at 10/35/70 and max Class 3; preservation of previously unlocked classes.
- Hero recruitment and five followers; hero default level 10 for newly recruited heroes per approved progression rules, without reducing old hero levels.
- Quests, guild hall, combat, five-class VFX, animations, equipment attachment, city travel, UI, player guild where implemented.
- PlayerData and market safety: preserve Phase 4.5 escrow/conservation/claim invariants, cross-server pending gates, market release DISABLED.
- Do not reset saves or reroll existing hero identity. Add data via a versioned, idempotent migration with a deterministic default look if appearance data is absent.
- Do not substitute client Roblox avatar appearance for owned RPG appearance unless product design explicitly approves it.

## 3. Required architecture

Implement clean module boundaries following actual repository conventions:
- `AppearanceCatalog` (valid IDs from manifest)
- `AppearanceService` (server authoritative entitlement/selection/save)
- `RaceService` or `BodyPresetResolver` (valid race/preset combinations)
- `RigAssemblyService` (build/clone R15 custom character safely)
- `ClothingService` / `OutfitResolver` (slot compatibility/layer ordering)
- `AccessoryAttachmentService`
- `AppearancePreviewController` (local preview, not authoritative inventory)
- `CharacterCustomizationUI` (TH/EN; PC/mobile)
- `AppearanceAssetRegistry` import map with genuine Studio model and texture references, populated only after successful import
- Tests, QA diagnostics and audit logging.

Do not create duplicate services if an equivalent system already exists. Do not put one script inside each character limb or garment. Standardized asset IDs and filenames are source-of-truth in this package. Use stable IDs, not localization text, for persistent selections.

## 4. Appearance data contract

`appearanceVersion` integer; `raceId`; `bodyPresetId`; `skinPaletteId`; `headPresetId`; `hairAssetId` or null; `hairColorId` or null; `beardAssetId` or null; `raceFeatures` (registered slot IDs); `outfitSlots` (slot -> registered asset ID); `customizationRevision` as suitable. Actual schema can adapt to existing conventions.

Server validates race/preset pairing, asset availability, compatibility and ownership. Clients send **intent** only, e.g. `PreviewAppearance(change)` or `CommitAppearance(selection)`; never serialized Instances, body meshes, authoritative owned inventory or arbitrary Roblox asset IDs.

Existing player/hero appearance that has not opted into new system must keep looking acceptable. Race changes are cosmetic only in first pass, not gameplay/race-stat multipliers.

## 5. R15 and layered fitting (NONNEGOTIABLE)

Core mesh names EXACTLY as in the shared contract. Import meshes with corresponding rig/attachment/cages as required for the chosen Roblox creation path. Check up-to-date Roblox official requirements and fix export axis/origin/rig based on the actual chosen import workflow, rather than blindly copying settings from a generic tutorial.

Use:
- **Layered clothing** with valid cage/skin/WrapLayer vs body WrapTarget for compliant flexible garments when proven working.
- **Rigid Accessories** for helmets, hair, earrings, buckles, shields, some shoulder plates and weapons as appropriate; they need stable attachments and offsets.
- **Fit-specific versions** only when an item cannot fit all body families; registry must identify supported presets or profiles and avoid a misleading universal-fit claim.
- `SurfaceAppearance.Color` or a documented tint strategy for skin palettes, with neutral skin color maps. Verify actual appearance on each material/mesh; don't assume all PBR texture setups tint identically.

Clothing layering policy: base modesty < inner clothes < outer clothes/robe < armor plates/accessory < cape, based on Roblox-supported ordering. Do not leave internal geometry visibly clipping; do not hide body segments so aggressively that removing garments exposes holes. All garments must be removable and replaceable.

## 6. Body proportions and gameplay fairness

13 planned visual presets in the manifest (4 Human, 3 Elf, 3 Orc, 3 Dwarf). These are bounded art targets, NOT freely dragging unlimited body sliders. Human reference height = H; race relative heights are illustrative targets and must be reconciled against actual Studio studs, doors, follow formation, camera and animation.

Normalize gameplay-specific collision, targeting, hit registration, damage, movement and PvP eligibility across cosmetic presets using a documented fair model. Never multiply reach/health/damage by visual size. Test dwarf/large-orc interactions with camera, stairs, portals and narrow tavern doors.

## 7. Work modes for joint Astra + Blender production

**Mode A: Contract first.** Inspect existing assets/scripts and produce `docs/CHARACTER_GAP_ANALYSIS.md`. Identify what is genuinely present. Do not regenerate adequate existing body models.

**Mode B: Human golden path.** Build one REAL Human Standard 15-part body with one alternate Human preset, one skin palette selection, one removable inner shirt + pants, one outer layered garment, one rigid hairstyle/helmet, and one weapon. If Blender is installed/authorized, use actual scripts/export; otherwise produce exact Blender work orders and Studio temporary test substitutes marked `PLACEHOLDER`, not invented production meshes. Ensure full live Roblox Studio play test.

**Mode C: Validate before spreading.** Test movement, combat, limb deformation, transparency/modesty, appearance changes, equip/unequip, save/rejoin, Thai/English UI, touch simulation, five-companion follow, and material/skin selection. Stop a defective geometry/rigging approach before multiplying variants.

**Mode D: Extend families.** Create/ingest remaining race reference bodies and approved presets, reusing contract and rig interfaces. Mark unsupported clothing entries explicitly; produce per-fit-family variants if needed. Wizard is Human outfit/hair/hat preset.

**Mode E: QA + provenance.** Link each imported Roblox asset to its *real* asset ID or in-place model path. Record `.blend` / export file paths; check owners/licenses on external assets. Record actual screenshots and tests. Don't publish publicly.

Astra owns **runtime systems, validation, Studio import/assembly/integration**. Blender-side artist/automation owns **geometry, cages, textures, rig and export**. Never have two agents edit the same `.blend` or Lua source at the same time. Exchange artifacts using manifest and contract; each asset is marked `PLANNED / IN_PROGRESS / EXPORTED / IMPORTED / TESTED / ACCEPTED` based on evidence.

## 8. UI/UX deliverables

Implement:
- Character creation with Race cards, Body cards, Skin swatches, Head/Hair tabs, Outfit tabs and 3D preview.
- Front/Side/Back orbit preview; mobile touch drag, zoom/clamp, Reset View.
- 5-class availability displayed independently of race (no race-class locking).
- Clear outfit layers and incompatible items with informative TH/EN message.
- Comparison toggle: Before / After; explicit Apply and Cancel; unsaved changes warning.
- Existing heroes: identity dossier + Appearance tab; restricted cosmetic edits depending game rules. NEVER overwrite hero level/class/equipment when changing appearance.
- Fixed safe-area support for device notches and virtual joystick; navigation/back, confirmation and error states.
- Accessible contrast, tap target sizes and deterministic avatar display, no mandatory premium outfit to finish onboarding.

Use Roblox GUI objects, ViewportFrame where suitable, not HTML/CSS. Integrate with the existing UI design system and style. Existing appearance preview must not commit state until accepted by the authoritative server.

## 9. Test requirements

Automated:
- 15 core body names unique and present on each accepted body.
- Correct race/preset/skin ID validation, disallow arbitrary asset IDs.
- Invalid race ID, incompatible outfit, disallowed selection and forged ownership rejected.
- No duplicate outfit/slot overrides; clothing layer order deterministic.
- Save/load persistence and idempotent migration.
- Outfit removal never removes modesty covering.
- Appearance operations never change HP, XP, Level, Rank, Class, Skill/Status Points, Gold, tradable assets, market escrow or hero ownership.
- Malicious or spammed remote requests are rate-limited.

Studio MCP (run, don't fabricate):
- Human Standard + one varied body; at least 3 skin palettes.
- Human, Elf, Orc and Dwarf as models when each is actually available.
- 15 limb meshes and R15 joints inspected.
- Idle, walk, run, jump, dodge, basic attack, skill, weapon grip, emote, downed animation.
- Follower navigation/teleport and five-companion lineup, city doors, camera scale.
- Equip/unequip shirt, pants, robe, armor, helmet, cape and weapon (only those actually implemented).
- Clothing clipping at shoulder/elbow/hip/knee/bending and skin intersections.
- At least 2 client isolation test; 4 clients when practical.
- Reconnect and progress preservation.
- PC, simulated mobile portrait and landscape; mark physical touch pending unless physically tested.
- Inspect Output, screenshot FRONT/SIDE/BACK and combat/movement.

If a method cannot be tested from Studio MCP, write a precise manual acceptance test; do not mark it PASS.

## 10. Acceptance gates

P0 golden path passes only if the player can:
1. Spawn and see a correct separate R15 body.
2. Change skin tone and body preset without changing stats.
3. Equip/remove real separate clothing, without nudity or major clipping.
4. Walk/fight/follow with stable rig and weapon attachment.
5. Save/rejoin and preserve chosen appearance.
6. Preview/confirm/cancel safely on PC/mobile UI.

P1 all races passes only when actual generated/imported models exist and each is visually checked. Empty placeholder folders and concept images do not count as completed geometry.

Preserve original gameplay and test suite. A geometry bottleneck may block full P1 delivery; report accurately instead of making fake `pass` claims.

## 11. Required docs / evidence

Create/update:
- `docs/CHARACTER_GAP_ANALYSIS.md`
- `docs/CHARACTER_PIPELINE.md`
- `docs/APPEARANCE_DATA_MODEL.md`
- `docs/CLOTHING_COMPATIBILITY.md`
- `docs/CHARACTER_STUDIO_TEST.md`
- `docs/CHARACTER_UAT.md`
- `docs/CHARACTER_ASSET_STATUS.md`
- Source reference register documenting actual Studio asset IDs after import.

Run all existing tests and Rojo/build/Luau validation. Keep test outputs and screenshots reproducible.

## 12. Final response

Report: implemented vs planned table, source and Studio paths, actual rig status, actual clothing fit by race/preset, UI, save migration, security, complete test results, screenshots, missing Blender files, manual device tests pending, and named blockers. Stop after this character-system scope. Do not publish, do not begin unrelated gameplay, and do not enable the public market.

**START by reading the shared contract and registry, then implement Mode A and the Human golden path. Continue safely into other race assets only when integration gates pass.**
