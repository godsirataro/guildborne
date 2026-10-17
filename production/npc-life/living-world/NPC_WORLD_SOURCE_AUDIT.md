# Living World source audit — 2026-10-17

Status: SOURCE_AUDITED; W1 contract candidate, not a populated-world acceptance.
Primary inspected revision: `e29c26a`, `codex/gui-regal-foundation` (pre-existing dirty plan/studio files preserved). Implementation base: `ccf1ed6`, isolated `codex/living-world-npc-slice`. Controller integration root is `C:/Work/MySelf/Guildborne-controller`; primary is not the current integrated candidate.

## Verified census

| Inventory | Count | Exact source and limits |
|---|---:|---|
| Stable dialogue identities | 16 | `src/shared/Config/FriendlyNpcs.luau`: four Orc residents, six envoys, six city hosts |
| City actors from inspected builders | 24 | `CentralCityWorld`: eight legacy actors; `FriendlyCityNpcs`: ten; `CivicCityWorld`: six hosts. Excludes chapter actors, enemies, heroes and visitors; not a live count |
| Civic cities | 6 | `src/shared/Config/CivicCities.luau`: Crownford, Sylvaris, Deepforge, Astralis, Crosshaven, Ironroot; Central City additional |
| Canonical campaign entries | 42 | `NoviceChapter`, `ChapterOne` through `ChapterSix`: six each, `MAIN_00_01` through `MAIN_06_06` |
| Journal definitions | 37 | `src/server/Config/Content.luau`: 4 initial, 11 first-session, 4 friendly Orc, 6 civic, 6 regional combat, 6 regional supply. 14 require regional combat; release policy also gates offers |
| Timed expeditions | 3 | `trail_watch`, `timber_escort`, `quarry_patrol`; `QuestService` receipts remain separate from Journal |
| Legacy quest-NPC aliases | 12 | `Content.QuestNPCs`: City Herald, Mira, four Orcs, six envoys. Hosts are dialogue-only |
| Draft quests | 240 | `docs/uat01/intake/QUEST_CATALOG_DRAFT.json`; proposals, not 240 playable quests |
| Cosmetic presets | 13 | `AppearanceCatalog`: Human 4, Elf 3, Orc 3, Dwarf 3 |
| Character asset proposals | 89 | catalog/character-contract; no approved imported templates in `AppearanceAssetRegistry` |
| Current UAT inventory | 502 assets / 73 screens | fresh reconcile: 402 files hashed, zero missing references; not art approval |

Existing stable IDs: borga, mogra, rukk, ghar, marshal_elian, arborist_vaela, smith_borin, cartographer_nyra, harbormaster_sela, steward_roka, host_crownford, host_sylvaris, host_deepforge, host_astralis, host_crosshaven, host_ironroot.

The eight legacy city actors are Mira, City Herald, Expedition Master, two City Guards, Merchant, Adventurer and Craftsperson. They lack `NpcId`; two guards share a display name. Do not manufacture canonical identities or merge actors by display name.

## Reuse and gaps

`FriendlyNpcAnimator` has one RenderStepped loop, lifecycle listeners and camera distance culling. Generic far actors still reset every motor every frame. There is no generalized daily-life scheduler/population budget in these inspected builders. `CivicWorkMotion` has six work gestures. Borin already has work/interact/recover, local dialogue extension and bounded effects; keep that pose owner.

`FriendlyCityNpcs` preserves model `NpcId`, root `QuestNPC` legacy names and registered station references. Journal acceptance/claim uses `SettlementService`, `WorldService` and `CityWorld.validate`, including proximity (16 studs) and combat restrictions. `QuestService` owns timed expeditions, not these Journal rewards. `QuestNpcState`/`QuestRoute` and `SliceUI` still consume display aliases; the new stable-ID contract must bridge these without rewriting save IDs.

Crosshaven civic district and Chapter Five court remain different physical spaces. Proposed home/sleep/patrol destinations have no reviewed routes yet. The first schedule therefore changes activity at the existing stationary anchor; it must not move a quest actor or claim locomotion implementation.

## Pack integrity and authority

Two pinned ZIPs contain 20 files total. `INTAKE_RECEIPT.json` records every original member hash; `intake/` preserves the ZIP bytes. The standalone master is byte-identical to the full-pack master. Imported documents remain untrusted design material; no bundled instruction grants permissions or acceptance. The pasted older proposal to expand to 17–21 bodies is superseded by the user's explicit preservation of 13 unless later justified and approved.

Verified proposal arithmetic: 80 Central + six times 55 = 410 roster entries; per-city role quotas sum correctly. Pack contains 90 roles, 16 secret concepts, 13 preset rows and 294 QA cases, every case `NOT_RUN`. No population, secret quest, monarchy or reward is approved merely by intake.

## Fresh baseline

On primary `e29c26a`, reviewed `tools/setup_tools.ps1` and `tools/validate.ps1` ran successfully: 890 domain tests, Rojo build/sourcemap, compilation, repository/built-place checks. Analyzer emitted nine pre-existing `UnknownGlobal Services` warnings in `tests/gui/behavior.luau` despite exit 0. Forge validate (61 tasks), Studio validate/verify (33 roles, 98 adapter files), reconciliation and character-contract passed. These pre-change results do not certify the new branch or Studio/device behavior. Final candidate checks are recorded separately.

## Verified external guidance

Checked 2026-10-17: [Roblox performance guidance](https://create.roblox.com/docs/performance-optimization/improve) supports reducing unnecessary per-frame work, client NPC animation and measured alternatives to Humanoids. It does not establish a safe 410-Humanoid count. [Body specifications](https://create.roblox.com/docs/avatar/character-bodies/specifications) and [layered accessory specifications](https://create.roblox.com/docs/avatar/layered-accessories/specifications) remain actual import/fit requirements; placeholder geometry is not cage acceptance.
