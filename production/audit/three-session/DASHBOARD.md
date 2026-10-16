# Three-session production control

Checkpoint: 2026-10-16, Asia/Bangkok. VERDICT: AT_RISK. This is a delivery dashboard, not whole-game acceptance.

## Verified controller checkpoint — W2

### W3 GUI follow-up (latest)

Integrated e29c26a as b86253a. Worker full baseline passed 890; controller and
independent reviewer each passed 12 GUI simulations. Studio candidate
780fccae98041bb1b41525c28fd7f82ba0e1ff5837b2eab8e91e893380adcda5
matched all 369 source entries. Actual desktop English and Thai button text fit;
Thai also fits at the 680-content-width breakpoint and bounded 320x600 native
layout fixture. The latter is not physical-device evidence. Settings expands,
Credits text fits and Tab/Enter hides Title and opens management. All owned
Play sessions stopped. Evidence: studio-w3-gui.json and gui-w3-desktop.jpg.

W2 visual defects materially improved: compact header, complete default control
rail, shorter localized labels, brighter scenic citadel with layered terrain.
Visual similarity remains PARTIAL: procedural art is not the reference's painted
landscape/crest, and those original assets have no verified runtime binding.
Human visual approval and broader GUI reskin remain open. The W3 scope is
Title/components; W2 combat/quest/route results are not relabeled as W3 reruns.

Integrated S15 lifecycle c58754a, S14 keyboard 7dc131d and visual 076b753,
S13 route 78ec391 and gate-approach correction 3358598. Controller source head
5bad1f3. Original S15 raw logs restored byte-for-byte in 51adb54 and protected
against newline normalization. Metadata repair CI run 38864305260 passed all
three jobs; the earlier failed hash checks below are historical.

Fresh combined baseline before W2 passed 890 regressions and strict analysis.
Final W2 baseline passed 890 regressions, 369 strict files and all automated
checks (raw receipt: final-local-check.json); independent GUI review passed 11 simulations with
no blocking source defect. These are not visual acceptance.

First integrated Studio candidate source-matched 367 scripts. Real Tab/Enter
worked; actual player Warrior Power Strike returned OK then Cooldown, with
server damage/cooldown/action attributes observed. High/Low lifecycle probe
passed cancellation, replacement, death/removal and malformed/stale observation
checks. Pose probe produced 225 finite samples; audio IDs remain unbound.
Central city services probe passed 29 assertions. Raw first-run MCP responses:
studio-first-run.json.

Synthetic five-hero route reached city, portal, island and camp with 1498 samples,
maximum gap 23.8816, no unexpected recovery or rewards, then failed at return
gate: its approach went through a solid pillar. This was a probe-path defect.
3358598 stops before the pillar within native prompt range; corrected Studio
run PASSED: 35 segments, 1587 samples, maximum gap 24.0493, two explicit travel
transitions, zero unintended recovery/rewards and cleanup true. Raw receipt:
studio-w2.json. Synthetic leader/roster is not earned-player proof.

W2 GUI candidate SHA256
6cf20020949d5aeb214306ee2f26bb992edf8998039b8e370e7a3d301791db0a
matched all 369 source entries in standalone PlaceId=0/GameId=0 Studio.
Actual 796x675 image was compared with 03_MAIN_MENU. Visual review failed:
blocky/dark citadel, oversized header, clipped lower controls and cramped
language text. S14 has a bounded revision assignment. User reference fidelity
is the current priority. No final-art or physical-device approval is claimed.

Separate actual-player ordinary-input journey PASSED: Journal city_gate Accept,
walk/E travel Guild->City->Guild, Ready 1/1, Claim, visible Gold 0->15 and
Claimed 1/1 with claim control removed. No fixture grants or class XP claim.
Raw receipt: quest-ordinary-input.json. This proves actual owner travel and
earned quest reward/UI binding, separately from the synthetic follower probe.

Contract revision 2 corrects an overstatement: QuestRoute does not navigate
within the owner island. The combined pinned quest-to-camp combat journey is
still pending. Imported art/audio, broader screens/classes/world, multiplayer,
device and human gates remain open.

The sections below preserve the historical W0 assignment/baseline; the W2
checkpoint above supersedes their pending/not-run statuses.

## Base and authority

Verified remote main: bf948c636aa47e1d1b92a617895d324fcfaf42e9. Map PR #3 head 42cb34b targets main; GUI PR #4 head 49c5162 targets codex/world-connectivity. Map's three CI jobs passed; GUI's regression passed but both production jobs failed on generated source hashes. Controller reproduced the failure in a fresh checkout and corrected only two hashes in 84fe8cb. CI revalidation remains required.

The user authorized coordinating and messaging the three existing chats, autonomous routine decisions/research, review, commits and pushes, without new PRs. No main merge, publication, expenditure, production persistence or commerce activation is authorized. Attached prompts are reference charters; current user instructions take precedence.

## Sessions and ownership

| Stream | Delivered before this cycle | Current assignment | Workspace / branch | Remaining |
|---|---|---|---|---|
| S13 / 13-Map Created | Central city service and five-follower route evidence, 19-zone inventory | Extend verification through MarketDistrict portal, owned island and existing Goblin Camp; publish exact anchor contract | C:/Work/MySelf/Guildborne-s13 / codex/s13-world-wave1 | Other regions, Round 2, device/human acceptance |
| S14 / 14-GUI Created | Native components and Title; isolated fixture evidence | Apply metadata repair, fix automatic Title keyboard focus, prepare HUD/Quest/Status scope | C:/Work/MySelf/Guildborne / codex/gui-regal-foundation | Full-game integration, remaining screens, imported branding, gamepad/device/human acceptance |
| S15 / 15-Animetion VFX Created | Combat intake only; no gameplay implementation in preceding turn | Power Strike presentation lifecycle and accepted/rejected/cancel probes | C:/Work/MySelf/Guildborne-s15 / codex/s15-combat-wave1 | Integrated combat evidence, all-class expansion, imported audio/animation, device/human acceptance |
| Controller | Live thread/CI/ancestry audit; reproducible CI hash repair | Contract review, integration, baseline, one combined Memory candidate | C:/Work/MySelf/Guildborne-controller / codex/three-session-integration | Combined source and Studio result |

All W0 messages were sent through connected send_message_to_thread, and each chat was observed active. S15's former question concerned a mismatched World ZIP; the user already answered. Combat scope now follows current runtime, not the wrong attachment. No credentials or extra prompt pack are needed to continue the bounded slice.

Shared ledger: C:/Work/MySelf/Guildborne/build/agentic/three-session-v1.sqlite3. Prior ledgers inspected read-only contained no owned jobs; workers must confirm their old processes stopped. Every writer claims/checks its lease. No ledger per worktree. All worktrees start from 49c5162, so Map is already present exactly once. Only each stream's new commits are candidates for integration.

S13 owns its p1-city-verification probe/report subset; any spatial repair requires p1-city-services. S14 owns gui-foundation only. S15 owns the presentation-integration runtime/probe subset, excluding generated adapters and build tooling. Controller owns audit documentation. Plan, protocol, bootstrap, PlayerCombatController and tests/run.luau remain reserved until explicit shared-file handoff. Studio mutation is serialized and reserved for the integrated candidate; workers prepare probes without touching open instances.

## Acceptance

| Layer | Current combined candidate |
|---|---|
| SOURCE | PARTIAL: Forge 61 tasks, Studio 33 roles/10 workflows, ecosystem validate, registry and character contracts checked |
| LOCAL | Pending fresh combined validation; historic checks are not promoted |
| STUDIO | NOT_RUN on combined candidate; earlier city and GUI fixtures are separate evidence |
| MULTIPLAYER_ONE_SERVER | NOT_RUN |
| DISTINCT_LIVE_SERVERS | NOT_RUN; requires separately scoped platform execution |
| PHYSICAL_DEVICE | NOT_RUN |
| HUMAN | NOT_RUN for new combined candidate |

Inventory reconciliation observed 502 assets, 73 screens, 89 kit entries and zero missing references; this does not mean implementation/import/approval. Audio bindings remain empty. GL2 publicReady and p0Complete remain false.

## Integration and next trigger

Review each bounded commit, then integrate S13/S14/S15 deltas onto the controller branch, preserving existing stacked ancestry. Run tools/validate.ps1 and focused suites on the combined source; source-check the exact Memory build before ordinary-input Studio execution. See CONTRACT.md for the route and authority boundary. Failed checks reopen the responsible stream, not the entire project.

Next checkpoint: worker commit or blocker, GUI CI completion, or combined baseline result. No invented completion percentage and no unattended monitoring claim. Routine design/technical choices are delegated to controller judgment; external art/device/release gates stay explicit.
