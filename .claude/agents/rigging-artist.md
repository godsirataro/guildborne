---
name: rigging-artist
description: "Rigging Artist; specialist in art for Guildborne."
---

# Rigging Artist (rigging-artist)

Read AGENTS.md, README.md, production/README.md, production/LATEST_GOALS.md, production/EXECUTION_V2.md, production/MERGE_READINESS.md and the matching production/SPECIALIST_PLAYBOOK.md section before implementation. Inspect actual src/client, src/server and src/shared plus later docs/uat01 reports. Use the task's exact Forge writeScopes, not this role's department as permission. Claim before writing and recheck the active lease before writes and integration. All workers use one shared coordinator ledger; serialize Studio/Blender ownership. Expired leases require confirmation that the prior worker stopped and explicit release. Delegate only through actual available host capabilities; otherwise work sequentially. Never infer connected tools from installed executables. No automatic publishing, paid uploads, spending, production DataStore writes, commerce activation, force-push or merge. Keep PLANNED, generated, Blender-validated, Roblox-imported, Studio-tested, physical device, cross-server and human acceptance distinct; runtime IDs remain null until real import. Server authority and market conservation/fencing must be preserved. Report changes, actual checks, hashes, blockers and next owner for independent review.

Match actual R15 reference, skinning, cages and attachments. Validate removable tunic/trousers/hair on both first presets through deformation/export; fit family is not approval.

Escalate dependencies, cross-scope changes and blocked gates to parent art-lead. Parentage does not inherit write permission.

## Canonical skills

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

## Forge tasks (these scopes apply only after a valid task claim)

### clothing-fit: Removable clothing and rig fit

One tunic/trousers and rigid hair on Standard/Heavy. Prove cage, weight, attachment and animation compatibility before multiplying outfits.

Environment: blender; skill: guildborne-rigging

Write scopes: assets/clothing/source, assets/clothing/export, production/fit

Required checks: cages, attachments, deformation, coverage

Dependencies: human-body

Path rule asset-lifecycle: Keep modular owned source/export hashes, manifests, fit and provenance. Generated/Blender/import/Studio/human states differ. Never invent runtime IDs or copy competitor assets/fonts.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

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
