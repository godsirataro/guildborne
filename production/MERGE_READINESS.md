# PR #1 — merge scope and outstanding game acceptance

This is an **implementation PR for the production toolchain and scoped progression
compatibility fixes**, not an all-game-complete release. Latest Guildborne goals
in LATEST_GOALS.md remain the destination; none are silently dropped to obtain a
green badge. Merging does not activate new campaign flags, commerce or publication.

## What this PR implements

| Area | Delivered and testable here |
| --- | --- |
| Agent production | 25 specialist skills and 33 dependency-ordered work packages, deeper shared playbook, cooperative file/session ownership |
| Existing work intake | Read-only reconciliation of every current UAT asset/screen plus the 89-entry character catalog; hashes, existing native bindings and explicit head aliases |
| Local execution | Opt-in Codex subprocess runner with bounded attempts/time/output, unchanged-HEAD/plan/scope checks, retained failure/resume checkpoints |
| Tool discovery | Read-only stdio MCP handshake/pagination with supported-version, schema and discovered-tool checks; reviewed local command configuration |
| Character authoring | Self-contained 15-part contract, 13 body presets, 20 palettes, explicitly untested clothing fit matrix and CSV; optional original-archive intake |
| Visual pipeline | Existing-source/rework guard, local PNG pixel/alpha validation, six procedural fallback previews, Blender audit adapter |
| Evidence | Actual Git commit/tree and clean-source verification; command receipts for quiet/failing checks; per-check packet composition; hash revalidation at submit and review |
| Content | Quest/skill dependency, Hall-deadlock, exclusive-branch and unique reward-receipt validation |
| Scoped gameplay | Novice ruleset Class2=35 readiness/copy and promotion SP/AP refund; old mode/earned paths stay readable; existing Hall and hero-start math reused |
| CI | Production-tool tests on Linux and Windows, plus original Windows Luau/type/build/repository validation and targeted progression tests |

No source library is counted as imported or human-approved merely because a file
exists. Routing is a review aid, not semantic deduplication. A shell exit code is
not an authenticated or artistic approval.

## Required checks before a maintainer merges

- Current PR revision has successful `production-tools (ubuntu-latest)`,
  `production-tools (windows-latest)` and `existing-regression` jobs.
- Review the runtime delta: ruleset-aware class readiness, promotion refund and
  localized display only. Do not confuse new-journey behavior with a global cutover.
- No unexpected changes to Runtime flags, market storage, profile schema, cloud
  permissions or existing game tests. Added tests supplement, not replace, them.
- Review warnings/pending items in reconciliation instead of treating every
  unknown native binding as missing or replacing it with a new generated asset.
- No auto-merge, paid generation, publication or live-commerce activation.

The current check result must be read from GitHub for the current head. This file
is a review contract, not a self-issued approval and not a substitute for branch
protection or independent review.

## Audit-gap disposition

| Prior gap | Current disposition |
| --- | --- |
| Registry mismatch / incomplete inventory extensions | Reconciler preserves actual row counts and hashes SVG/glTF/CSV/XLSX/WebP/etc. Dedicated NPC/island/war routing added. Semantic reuse still needs review. |
| Class2 30 versus 35 | New Novice path uses35; legacy30 and earned classes remain compatible. Targeted tests cover both, per-hero levels and no duplicate respec grant. |
| Cosmetic race versus old ancestry | Explicitly separate; no silent removal of old combat bonuses. New Orc/model appearance integration remains a downstream task. |
| Fake commit-shaped evidence | Unknown/stale commit, wrong tree, dirty source, changed receipts/logs and missing per-check proofs are rejected by the recorded-check route. |
| Empty command logs could not be submitted | Quiet streams remain zero bytes; a hashed invocation receipt supplies valid nonempty evidence without inventing output. |
| Worker could authorize parent-path changes | Directional containment replaces symmetric overlap for write authorization; plan/postcheck/interrupt failures checkpoint visibly. |
| MCP compatibility and malformed responses | Stable2025-11-25 plus earlier protocol negotiation, tool/cursor validation and controlled owned-bridge cleanup. No actual Studio connection claimed. |
| PNG only checked CRC/container | Bounded decompression, scanline/filter validation, alpha coverage and invisible-candidate rejection implemented. Visual review is separate. |
| Character Kit availability | Normalized production contract is self-contained; importing the exact original17-file ZIP/XLSX still requires the supplied reviewed archive. No original binary is reconstructed or falsely claimed bundled. |
| Full provider / Studio / Blender loop | Guarded adapters and work specifications exist. Real provider, export/import, clothing fit and visual playtests require the actual workstation. Not claimed complete. |
| Commerce specialist | Prior blocked processing scope remains deferred. This PR does not retry it through another route or enable sales. |
| PR description and draft mismatch | Update metadata after current checks. Ready for review is not authorization to merge automatically. |

## Still required for the game, not represented as completed by this PR

Human Standard/Heavy plus removable clothing, real rig/cage/import/animation fit;
remaining races and outfits; final logo/icons/HUD/panels and all applicable UAT
screens; skill VFX/audio bindings; NPC/monster/boss/world art integration; all
approved quest/hero/class content; islands/visits/themes; player guild and war/
territory acceptance; actual asset/provider provenance; sustained cloud load;
independent live server JobIds; real mobile input/performance; human art/UAT and
release signoff. The public economy and purchases stay disabled.

A missing local Studio/Blender/provider capability blocks that work package, not
safe independent coding. Never close it with a mock server, generated PNG or old
screenshot. See GOLDEN_PATH_V2.md for the first actual workstation acceptance route.
