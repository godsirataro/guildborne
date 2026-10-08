# Archive Heart / Chapter06 foundation — 2026-10-06

Chapter06 is bound only in the explicit local Memory preview. It is not release-ready. A full ordinary-input Chapter00–06 desktop Memory journey now passes at revision266 / Mage100 / Hall17, with no source hotpatch or profile grants. See FRESH_FINALE_PROGRESS.md and per-chapter evidence. Subsequent UI/timing polish is separately tested; reconnect, multiplayer, devices, imports and human acceptance remain pending.

## Progression and story

Six quests, eighteen objectives, level85/Hall14 through level100/Hall17. Three approaches, two warden choices and three endings create eighteen routes; all five root classes pass ninety synthetic progression routes. Guaranteed Gold and materials fund all three Hall upgrades even when the Chapter06 starting Gold is zero. Final total XP is4950; the level100 AP budget is297. Rewards do not require Robux, market purchases, random recruitment or permanent class changes. This does not implement the proposed thirty-five-class redesign.

The native world adapter supplies 42 prompts: shield/covered-escort/symbol approaches, a supply escort, temporary wards, three readable warning patterns, two boss activities, timed ledger recovery, mandatory backups, ordered interlocks, five voluntary alliance pledges and equal-power ending choices. Friendly Orc, Human, Dwarf, Mage and Elf representatives reuse the existing city cast. The covered route is an escort prototype; enemy detection/stealth AI, history-reactive dialogue, optional side-quest shortcuts and cinematic ending variants are not yet implemented.

Receipts remain server-owned, session epoch/token fenced and retryable. Native fake-session probes captured thirteen non-combat objective receipts, no actual player-profile writes, and verified foreign/distant/busy/underlevel/stale/replay rejection, checkpoint reconstruction, timer reset and mandatory backups. They do not prove player completion.

## Encounters

Last Warden: dodge the committed line, ring and targeted circle, then release each seal. Keeper of Names: dodge, rescue, release, then attack the exposed core. Each has three stages, a 240-second limit and three-mistake failure. Every root class can finish using its real basic-attack rules; Knight taunt and Priest heal do not invent damage. `ArchiveHeartCombat` computes hits through the existing server CombatStats/CombatAbilities/CombatDamage modules; clients send bounded action intents only.

The domain engine validates current/fresh server samples, distance, phases, deadlines and event identity. It rejects skipped phases and late warning samples, deduplicates hit events and caps event memory. The adapter restores the avatar on exit and retries a stable completion receipt. These encounters currently use a mistake budget rather than damage to the real avatar health. Difficulty, phase timing and final combat balance still require human playtesting.

Isolated actual-input evidence: Mage defeated Keeper with three rescues, three seals, six server combat hits, zero mistakes and one captured completion. Knight completed Warden with three seals, zero mistakes and one captured completion. Both used ordinary keyboard input and navigation at speed1, without injected gameplay Remotes or actual progression grants. The Mage's actual Leave button removed the arena and restored the avatar. One earlier harness run stopped before the last attack and failed; its successful continuous rerun is retained alongside that limitation. EN/TH completion labels fit at the tested desktop viewport. Later presentation polish adds shape-specific warning instructions, core-HP hints, warning audio and hides empty generic health bars; the latter was verified in Studio.

## Original local assets

- One generated atmosphere image: `assets/uat01/generated/guildborne-archive-heart-v1.png`; saved prompt `assets/uat01/ARCHIVE_HEART_PROMPT.md`. The concept's four disks are decorative; gameplay uses exactly three seals. The concept is not an implemented-map screenshot.
- Two blocky automaton rigs: Last Warden and Keeper of Names, 106 visible parts /1272 triangles, sixteen bones each and eight Idle/Walk/Attack/Hit clips. Twelve FBX/GLB exports pass rig/weight/motion/loop/root checks. Native animation tests cover thirty Motor6D joints, walking, attack/windup, cancellation, reduced-motion idle, death/revival and distance culling. Art polish, animation imports and human approval remain pending.
- Six modular scene blockouts: three gates, supply court, warden approach, living ledger, alliance gate and heart chamber. 236 visible parts /2832 triangles and52 markers. Twelve FBX/GLB round trips preserve bounds/origin/materials. Native isolated and assembled fixtures each pass52 no-jump paths and104 body/floor checks. Continuous floors replace the concept's platform gaps.
- Private court:360×400 studs, eight vertical slots separated by80 studs. Invalid slot inputs are rejected and adjacent scene bounds do not overlap. Two physical NPC routes cover22 and65 studs, one completion each, using synthetic owner-follow evidence; actual player escort acceptance remains pending.

## Validation and artifacts

- `validation-archive-heart-domain.txt`:625 full domain regression tests.
- 290 runtime sources pass strict analysis, compile and repository/built-place boundary checks.
- Eight builds: staging, offline, Novice, Ironveil, Ashen, Tower, Crosshaven and ArchiveHeart. `tools/build_archive_heart_project.py` verifies Memory persistence, an empty cloud allowlist and all prior journey flags; other previews retain ArchiveHeart disabled.
- `validation-archive-heart-input-native.json`, `validation-archive-heart-rigs-native.json`, `validation-archive-heart-bar-native.json`.
- `validation-archive-heart-story-native.json`, `validation-archive-heart-court-native.json`, `validation-archive-heart-world-native.json`, `validation-archive-heart-escort-native.json`.
- `assets/uat01/archive-heart-bosses/roundtrip-report.json` and `assets/uat01/archive-heart-story-kit/roundtrip-report.json`.

`validation-archive-heart-fresh-boot.json` records a clean file boot: revision0, thirty-six campaign chapters, Memory persistence, one player, no premature finale court and no console errors. Registry workbook verification reports414 assets,73 screens,33 work areas,47 formulas and zero formula errors; the original input workbook remains unchanged.

Pending: complete ordinary-input campaign, all approaches and native class combinations; mobile/gamepad/multiplayer/reconnect; story and ending polish; final environment dressing, actual imports and human UAT. No cloud publication, live commerce or production approval is claimed.

Three owner-only objective glyphs are now bound through ArchiveHeartEffects: Rescue, Mechanism and Attack. `validation-archive-heart-effects-native.json` passes29 native presentation states and176 part checks, three distinct silhouettes,16High/8LowTouch caps, static reduced-motion poses, owner/distance/expiry/status validation and cleanup. Private arena geometry now carries CampaignOwner for foreign-client visibility filtering. No additional actual-input fight is claimed after this presentation-only change. Registry417 assets; domain regression remains625.

## Fresh finale acceptance and subsequent polish

All36 campaign and6 novice quests completed through ordinary input, including both new boss activities with zero mistakes in observed samples. Return to City removed court/arena. Final Memory state was captured before stopping Play; it is not a resumable save. Campaign ending is Transform. Completion UI now reflects the enabled arc and selected ending, retains active Journal priority and earned Hall permit guidance. Protection preparation increased from1s to4s, duration18s to22s. Subsequent checks:628 domain tests; strict; eight builds;144 completion GUI views/882 bounds; isolated native normal-speed54-stud first-shutter route completed with3 blocks and full health. See validation-fresh-polish-native.json.
