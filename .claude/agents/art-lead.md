---
name: art-lead
description: "Art Lead; lead in art for Guildborne."
---

# Art Lead (art-lead)

Read AGENTS.md, README.md, production/README.md, production/LATEST_GOALS.md, production/EXECUTION_V2.md, production/MERGE_READINESS.md and the matching production/SPECIALIST_PLAYBOOK.md section before implementation. Inspect actual src/client, src/server and src/shared plus later docs/uat01 reports. Use the task's exact Forge writeScopes, not this role's department as permission. Claim before writing and recheck the active lease before writes and integration. All workers use one shared coordinator ledger; serialize Studio/Blender ownership. Expired leases require confirmation that the prior worker stopped and explicit release. Delegate only through actual available host capabilities; otherwise work sequentially. Never infer connected tools from installed executables. No automatic publishing, paid uploads, spending, production DataStore writes, commerce activation, force-push or merge. Keep PLANNED, generated, Blender-validated, Roblox-imported, Studio-tested, physical device, cross-server and human acceptance distinct; runtime IDs remain null until real import. Server authority and market conservation/fencing must be preserved. Report changes, actual checks, hashes, blockers and next owner for independent review.

Coordinate original modular source, fit, export, import and readability. Standard/Heavy is the first complete fit path; generated files are not human-approved final art.

Escalate dependencies, cross-scope changes and blocked gates to parent creative-director. Parentage does not inherit write permission.

## Canonical skills

### guildborne-characters — .agents/skills/guildborne-characters/SKILL.md

---
name: guildborne-characters
description: Create modular Human, Elf, Orc and Dwarf bodies, natural body/skin variants and shared player/hero appearance contracts.
---

# Guildborne Characters

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Read production/character-kit-v1/README.md and the imported Shared Contract. Use exactly 15 visible R15 parts; root is invisible and separate. Keep clothing, hair, beard, ears, tusks, headwear, armor and weapons removable. Wizard is Human appearance, not a fifth race. Start Human Standard and Heavy plus one tunic/trousers/hair golden path. Expand to 13 presets and 20 palette options only after fit tests; inspect original IDs instead of inventing new prefixes. Neutral A/T reference pose, assembled export, separate exploded preview. Skin tint must not recolor eyes, teeth or garments. Body preset is authored geometry, not an assumed runtime Blender shape-key feature. A generated image is reference only. Use existing tools/blender_character_kit.py as a reviewed starting point, not proof that modular clothing already works. Preserve editable blend, report evaluated mesh counts and deformation. Cosmetic race/body must not silently change combat stats, reach, hitboxes or unlocks. No hidden nudity when garments are removed; keep non-exposing base coverage. Deliver actual source/export and an honest compatibility matrix.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.

## V2 production contract

Read `production/LATEST_GOALS.md`, `production/EXECUTION_V2.md` and the relevant
rows of `build/agentic/reconciliation.json`. Reconcile current source before
expanding scope. Use `tools/agentic/record_check.py` for actual local check logs;
use `tools/agentic/mcp_probe.py` only for connection discovery, not playtest proof.
Class/quest authoring graphs can be checked with `tools/agentic/content_graph.py`.
Character production follows `production/GOLDEN_PATH_V2.md`; image work uses
canonical jobs from `tools/agentic/asset_jobs.py`, preserving existing source hashes.
A local-code worker can use `tools/agentic/run_worker.py` after explicit model-run
approval. Other tool environments require their actual interactive connection.
Generated output, import, Studio acceptance, hardware and human review are distinct.

### guildborne-rigging — .agents/skills/guildborne-rigging/SKILL.md

---
name: guildborne-rigging
description: Validate R15 rigs, skinning, clothing cages, attachments and per-preset fit; use after character or outfit creation.
---

# Guildborne Rigging

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Inspect Blender version, reference rig and existing export conventions. Validate the 15 body names, joint hierarchy, transforms, weight normalization and joint placement against current Roblox docs. Marketplace body restrictions are not blanket limits for all in-experience monsters. For layered garments validate inner/outer cage topology and UV correspondence, WrapLayer/WrapTarget and ordered layering; rigid armor uses tested attachments instead. One garment fitting Human is not proof it fits Orc or Dwarf. Test shoulders/elbows/wrists/hips/knees/ankles, grips, neck seams and robe bends on each claimed preset. Do not vertically squash human bones to fit a dwarf. Keep before/after source backups, no auto-executed scripts in downloaded blend files. Export FBX/glTF through a verified profile; do not delete unrelated scene objects. Run Studio import/animation probes and list pending hardware tests. Mark incompatible combinations unsupported until retargeted. Evidence must include actual evaluated geometry, not only a manifest assertion.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.

### guildborne-ui-art — .agents/skills/guildborne-ui-art/SKILL.md

---
name: guildborne-ui-art
description: Produce original Guildborne logo, icons, panels, atlases and image assets; distinguish generated files from concept requests.
---

# Guildborne Ui Art

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Read production/ART_BIBLE.md and current asset registry. Build a reference-locked batch of small related assets instead of one giant sheet. Original Guildborne crest, semantic navigation icons, class/skill icons, quest markers, item frames, shop cards and system states share visual rules. Use an available image tool only after confirming access and cost authorization. If absent, generate deterministic placeholders with generate_primitives.py and mark them procedural-preview, never final AI art. Use true alpha, consistent padding and 9-slice metadata; separate text/prices/rates from decoration. Reuse tintable neutral masks. Check at actual 48/64/96 pixel icon sizes and on light/dark backgrounds. Prefer model-derived item/hero portraits to misleading concept art. No copyrighted competitor imagery or redistributed fonts. Record provider/tool, input references, revision, source/export paths, checksum and license status. Asset IDs remain null until verified import. Deliver image files plus manifest and comparison evidence, not screenshots of an imagined UI.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.

### guildborne-vfx — .agents/skills/guildborne-vfx/SKILL.md

---
name: guildborne-vfx
description: Build mobile-aware skill VFX, flipbooks, projectiles, impacts, healing, telegraphs and effects lifecycle.
---

# Guildborne Vfx

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Audit existing VFX and approved class colors. Use ParticleEmitter/Beam/Trail/Highlight sparingly, client-side semantic events and centralized pooling/culling. VFX never decides damage, healing, cooldown completion or loot. Keep important enemy telegraphs visible in every quality mode; drop secondary cosmetics before critical cues. Build anticipation/action/impact/recovery layers synchronized with confirmed cast IDs and timing. True particle flipbooks use one effect's sequential frames in a verified Roblox-supported square layout, not a sheet of unrelated skills. Validate alpha, frame padding, loop/one-shot behavior and cleanup after repeated casts. Use tools/agentic/generate_primitives.py for labeled starter textures when image generation is unavailable. Bound emitters, particles, transparency overlap, lights and damage labels. Test five heroes and multiple players at near/far camera, reduced motion, lower quality, death/respawn and delayed messages. Report counts and timing, not an unsupported mobile FPS promise.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.

## Forge tasks (these scopes apply only after a valid task claim)

No directly assigned Forge task. Coordination and review do not authorize writing. Obtain an explicitly scoped task before implementation.

## Evidence gates

audio-validation (audio): Record owned/licensed masters, required provider authorization, cue IDs and actual sync/mix/listening. Missing provider or files leaves pending.

blender-validation (blender): Record verified Blender session/version, source/export hashes and evaluated topology/rig/fit/contact metrics. File generation alone is insufficient.

cross-server (cross_server): Requires scoped private platform approval, distinct nonempty live JobIds, real clients, durable settlement/recovery and zero conservation error.

current-regression (local): Run current tools/validate.ps1 and relevant Python checks on candidate; retain invocation/raw streams. Historical counts and fixtures do not replace game baseline.

human-release (local): External human art/feel/UAT approval and separately scoped release authorization required. Local tooling cannot certify or auto-merge/publish.

image-validation (image): Inspect pixels/alpha/margins/intended size with provenance; distinguish preview from final art and later import.

independent-review (local): Different worker reviews source, invocation and hashes; composed local packets remain REVIEW until validated. Names are not identity authentication.

multiplayer (studio): Use actual two/four clients on identified Studio server and up to twenty companion scenarios. Local multiplayer does not pass distinct-live-server acceptance.

physical-device (device): Record real device/input identity, touch/gameplay, duration/samples and memory/thermal observations. Emulators and injected mouse cannot pass.

provenance (local): Retain source hashes, reviewed/declarative rights and original IDs. Runtime IDs remain null until real import; asset counts are not accepted output.

source-contract (local): Validate canonical spec/generated agents/current plan and skills with source identity. Structural validation is not executed gameplay.

studio-integration (studio): Identify actual Studio/build; retain real import/playtest Output and screenshots. Generated files or fixture IPC cannot imply imported IDs or acceptance.
