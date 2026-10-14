# Launch foundation implementation — 2026-10-14

**Partial implementation; local review candidate only. Public is not ready.**

Candidate: `build/Guildborne_LaunchPreview.rbxlx` SHA256 `842df8d99735bf5a245c816983f6441e95b88a90c0a9d59a9808447b061bd2b9`. Build receipt includes hashes of every source and the substituted Memory Runtime.357 script entries synced to the separate unpublished local Studio; source Runtime/Staging were not activated. Studio stopped after verification. Source worktree remains dirty, including pre-existing character work; this is not an immutable release revision.

## Changes

ReleaseContent/ReleasePolicy provide explicit local Lv35/Hall4/two-arc gates. Bootstrap selects Novice and Ironveil only for the guarded candidate. Full six-arc campaign validation preserves later earned saves. Commands enforce future-action restrictions and player mentor completion. Both chapter panel and HUD tracker recognize saved progress beyond the active catalog. Hall UI stops advertising the next cap at the release boundary.

Daily and seasonal claims extend the existing transactional profile, Commands, Protocol and ViewProjection. Missing extension remains compatible with old records; malformed claims reject loading. Seven daily material rewards rotate without missed-day loss. Six free story tiers have separate once-only claim markers. Premium is disabled with IDs0 and no client entitlement setter. This is not finished commerce or a dated production Battle Pass.

Native TH/EN reward UI is available from Guild. Display titles use translated chapter names; errors explain duplicate/locked/Premium/release states. Compact reward navigation avoids an extra large card. Existing inventory limits and save-pending behavior remain authoritative.

## Actual checks

- `tools/validate.ps1`: **732 tests passed**, Rojo build/sourcemap, Luau analysis and compilation, repository audit and diff checks passed. Log: `build/launch-preflight/validation-current.log`.
- Agentic suite: **177 run,5 skipped**, successful. Log: `build/launch-preflight/agentic-final.log`. Skipped tests are not passes.
- Studio v3 validation:39 tasks,33 roles,10 workflows;98 generated adapter files verified. This proves metadata consistency, not a running team of33 agents.
- Two actual workers implemented bounded content/reward modules and independently reviewed each other's work. Root integration was independently reviewed; historical HUD completion and builder flag-cardinality findings were fixed. No new save/authority blocker found in reviewed changes.
- Persistence harness tests cover daily save failure before/after write, callback replay, simulated crash/rejoin, corrupt receipt preservation and private projection. These are synthetic local stores, not live cross-server evidence.
- Final Studio Memory network smoke:6 requests; daily grants2herb once, second claim `DailyAlreadyClaimed`, locked free tier `SeasonTierLocked`, Premium `PremiumRequired`, TH language persisted in the session. Twelve active campaign entries, Lv35 release contract.
- Normal-speed character navigation and keyboard E completed courier meeting, walking, warning dodge and help objectives. Mouse interaction with `NoviceClaim` committed the first Novice chapter: Lv1→3, claimed1, revision7. No grants, direct receipt calls, profile edits or skipped time were used. This proves the opening only, not the full Lv35 route.
- Reward UI was visually inspected in Studio; narrow viewport requires scrolling. Screenshots were returned by MCP in the chat, not exported media files. One read-only assistant probe referenced a panel child after changing tabs and logged an instance-not-found error; it was corrected by inspecting the active UI. Do not describe this console as entirely error-free.

Raw compact Studio responses: `studio-evidence.json`. Build and logs are local artifacts; no production publication, upload or live purchase occurred.

## Remaining launch blockers

1. Full fresh-player route through Class2 for every class, hero-owned mentor trial, Borin normal crafting/claim/Deepforge, leave/rejoin on isolated persistent staging.
2. Four races/13 runtime presets and modular clothing/weapon fit; current Human placeholder policy is not production acceptance.
3. Imported licensed audio and listening, detailed weapon/animation runtime coverage, low-graphics full-party VFX and human art/feel review.
4. Reviewed priced Premium catalog, verified entitlements, real receipt delivery sandbox, PvE-only buff contract and dated season rollover/receipt retention.
5. Remaining future-content journal/path/node/portal UI needs release availability messaging. Server rejects prohibited actions, but that alone is not complete launch UX.
6. Real2/4 clients,20 heroes, actual Android/iOS, distinct live JobIds, cloud save/migration, new TH/EN testers, same-revision RC and owner release signoff.

Complete ordered backlog and post-launch tool/war/market work: `production/LAUNCH_PLAN.md` and `production/launch/backlog.json`. No automatic recurring jobs, tool-pack installs or spending were added.

## Coordination

Shared ledger v6 preserved v5 learning history. After both writers stopped, all v6 leases were explicitly released; v7 copies that history and expands root scope for independently found UI fixes. No active lease was reset and no expired worker was stolen. The current root lease is released at handoff. This source review does not mark Forge game/device/release acceptance complete.
