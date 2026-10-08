# Phase 1 Studio acceptance checklist

Updated 2026-09-28. **Phase 1 accepted for the agreed solo-play handoff.** The user confirmed Roblox Player rejoin with “โอเค ผ่าน”, then confirmed the remaining checks with “ผ่านหมด”. Those remaining results are **USER-REPORTED PASS**; no additional device details, failure scenarios, screenshots or logs were supplied. Two-player data/plot isolation remains **DEFERRED, not passed** by explicit agreement.

The detailed test statuses below preserve the earlier **agent-observed evidence**, including partial/not-run subcases; they are not rewritten as agent-verified passes by this sign-off. The final acceptance decision is recorded under Sign-off. Agent evidence includes the complete Studio route, 37 automated tests, [Memory-mode Output](evidence/studio-native-2026-09-28.txt), and [real DataStore rejoin Output](evidence/studio-persistence-2026-09-28.txt).

Tester: Codex through native Studio UI and the client Command Bar. Studio executable build: `version-6b0e880a1a144428`. Date: 2026-09-28, Asia/Bangkok. The gameplay evidence used a local generated place in Memory mode, before persistent staging was configured. Desktop manual route was followed by `tests/studio_client_probe.luau` in a fresh memory session. The probe printed `GBQA NATIVE LOOP AND REJECTION TESTS PASSED` at 14:38:18. Result labels below describe observed subcases, not a blanket release sign-off.

Record tester, date, Studio version, device/viewport, mode, universe/place, and observed errors for each run. Use an unused test account in a separate staging experience for the fresh persistent run. Do not erase an existing profile to manufacture a fresh result.

## Open and connect

In PowerShell at `C:\Work\MySelf\Guildborne`:

```powershell
.\tools\setup_tools.ps1
.\.tools\rojo\rojo.exe plugin install
.\.tools\rojo\rojo.exe serve default.project.json
```

Restart Studio if the plugin was installed while Studio was open. Open Guildborne - Staging, place `86788611613035`; `servePlaceIds` restricts live sync to this place. Open the Rojo plugin, connect to `localhost:34872`, review and accept the sync. Confirm `Shared` in ReplicatedStorage, `Server` in ServerScriptService and `Client` in StarterPlayerScripts. Press **Play (F5)**, which creates a player; Run alone does not exercise the client loop. Open Output with both client and server messages visible.

Alternative: run `.\tools\validate.ps1`, then open `build/Guildborne.rbxlx` using Studio's Open from File. No Rojo connection is needed for that generated snapshot. The world/UI appear during Play, not in edit mode.

Current `Runtime.StudioPersistence = "DataStore"` targets the allowlisted staging universe. Standalone local snapshots have no universe ID and refuse persistence. For offline preview only, temporarily set `Runtime.StudioPersistence = "Memory"` and rebuild; restore DataStore before staging sync/publish. The memory HUD says **Studio memory · not saved after Stop**. This mode cannot pass persistent Stop/Play or cross-server tests. Published servers never use this adapter.

## Configure real persistence for tests 10–11

Preparation status (2026-09-28): **Guildborne - Staging** was created with a TH/EN description and PC/phone/tablet support. Studio returned universe **10768425213** and place **86788611613035** at 15:05:59 Bangkok. Runtime now selects DataStore and allowlists only that staging universe; Rojo allows only that place. The Runtime source was synced into Studio, all 37 automated tests/build/analysis passed, and Studio confirmed publication of version **4** at 15:08:00. API access was initially OFF; the user enabled it, and actual DataStore access subsequently passed as recorded below. Native Computer Use cannot change in-app security/privacy settings. A read-only request to `https://develop.roblox.com/v1/universes/10768425213` returned the matching name/rootPlaceId, `privacyType: "Private"` and `isActive: false`; no audience setting was changed. Publication is not evidence of a successful DataStore load or rejoin.

1. Create/publish a **separate staging experience** under your authorized account. Completed for Guildborne - Staging; Private audience was verified through Roblox's universe endpoint.
2. In that place's Studio Command Bar, `print(game.GameId, game.PlaceId)` identifies the real universe ID and place ID. The universe ID must be nonzero. Record them locally; they are different identifiers.
3. Edit `src/server/Config/Runtime.luau`: set `StudioPersistence = "DataStore"` and add the real universe ID as a numeric key in `AllowedDataStoreUniverses`, with value `"staging"`. Keep the table type annotation. Do not use a placeholder ID or allowlist production for Studio.
4. Enable **Studio Access to API Services** in that staging experience's security settings. Add its actual place ID to the Rojo project's `servePlaceIds` allowlist before live sync to the published place.
5. Sync the code, save/publish the staging place, then Play. Require the HUD and readiness log to say **Persistent · staging**. If loading fails, inspect configuration/API access and retry; do not treat defaults or memory mode as a persistence pass.
6. Use a real account in a published staging server as well as Studio Stop/Play for final rejoin acceptance. Keep all players on the same code/content revision during the test. Negative Studio test-player IDs are not a substitute for real account testing.

The stores are `GB_Player_staging` and `GB_PlayerAudit_staging`. Keep any subsequent memory preview setting out of the staged persistent build. An unclean exit may require the 180-second lease to expire before another server acquires the profile. Do not bypass ownership fencing.

### Executed persistent run, 15:22–15:30 Bangkok

After the user enabled API access, Studio logged `Persistent · staging` and loaded revision 0. `tests/studio_persistence_probe.luau` requires the real positive account ID, exact staging IDs, and Active Persistent mode. It sends public RemoteEvents only and never resets or directly writes profiles.

- Session 1 saved Thai, tutorial, Warrior, a one-member party and active Trail Watch. Checkpoint revision 7 was captured before Stop.
- Session 2 loaded revision 7. An equality assertion compared every field of `{revision, data}` with the captured checkpoint, including the active run ID/deadline/reward/party snapshot and Thai preference: `GBPERSIST EXACT REJOIN MATCH 7 th` at 15:27:36. It completed all three quests, rejected duplicate claims without balance/revision changes, equipped Training Sword, recruited Archer/Priest, upgraded Hall, and selected English. Final checkpoint revision 17: Hall 2, 10 Gold, Warrior XP 90/level 2, four weapons, no remaining material stacks and tutorial complete.
- Session 3 loaded revision 17; all projected fields matched exactly: `GBPERSIST EXACT REJOIN MATCH 17 en` at 15:30:11. Thai was restored and saved at revision 18. [Final Thai UI](evidence/persistent-rejoin-th.png). Studio Play was then stopped normally.

The first probe stopped on an expected `Busy` response while the audit writer held the session lock. The manual probe was corrected to retry the same immutable packet after Busy; it resumed without resetting the profile. Original failure and subsequent success are retained in the Output evidence. These transient Busy responses are visible in the gameplay UI and remain a pacing consideration for backend playtests. No runtime gameplay source was changed during this persistent run.

Roblox Player is installed and the user completed sign-in. Published-server testing was interrupted by physical Escape before leave/rejoin was verified. Actual backend fault injection, two-server races and physical touch testing remain separate acceptance subcases.

## Full gameplay route

Guild → Begin tutorial → Party → recruit Warrior free → select Warrior → Save selected party → Quests → Trail Watch → wait/claim → Inventory → equip Training Sword to Warrior → Party → recruit Archer (20 Gold) → Quests → Timber Escort → wait/claim → Party → recruit Priest (20 Gold) → optionally select all three/save → Quests → Quarry Patrol → wait/claim → Guild → upgrade Hall → leave/rejoin in persistent mode.

For deterministic XP assertions, keep only Warrior selected throughout the three first clears. Expected final Warrior XP is 90, level 2; Archer/Priest XP is 0. Selecting recruits for later quests is also valid; record which members were assigned to each run and award its XP only to that snapshot.

## TEST 1 — Fresh player join

- **Steps:** Start with a fresh memory server or unused staging test profile. Play and wait for loading. Use Explore / M; walk to Hall, Quest Board, Party and Inventory markers and activate each prompt.
- **Expected:** Own primitive plot/spawn, Hall 1, 0 Gold, empty roster/party/inventory, welcome guidance. Four prompts open their intended screens. Data status becomes Active. No session tokens/audit/receipts appear in the client State snapshot.
- **Pass/fail:** PARTIAL PASS — fresh local spawn/Hall 1/zero balances/loading observed; owner-only snapshot reviewed by native probe. Four world prompts still need direct checks; two-player isolation is DEFERRED by user.
- **Output:** `[Guildborne] Phase 1 ready` with correct mode, client readiness, `profile_loaded`, `session_started`. No initialization errors.

## TEST 2 — Tutorial and resume

- **Steps:** Guild → Begin tutorial. Follow the route above while checking guidance after each action. Close/reopen management between steps. In staging, leave/rejoin once mid-route, then resume from the suggested step. Complete equip, all three recruits, quests and Hall upgrade.
- **Expected:** Guidance advances from persisted milestones, navigation remains available, and rejoin resumes progress. Hall 2 with the required milestones completes the tutorial. Repeated welcome/equip actions do not reset or trap the player.
- **Pass/fail:** PARTIAL PASS — local tutorial route completed; TH/EN guidance and M/Explore verified. Real DataStore mid-route resume and completion passed across Studio sessions; unaided published-client route remains open.
- **Output:** `tutorial_started` once for the committed welcome transition; `tutorial_completed` once when all milestones are met. `profile_saved` for committed actions.

## TEST 3 — Party creation

- **Steps:** Recruit Warrior free. Select Warrior and save. After earning Gold, recruit Archer/Priest for 20 each. Try different owned selections between quests, then save Warrior alone for the deterministic XP route. Attempt to save no members and change party during an active quest.
- **Expected:** One party, at most three unique owned members; empty/active-run changes rejected without altering the saved party. Recruits appear once; Archer/Priest each grant their compatible weapon. Selected unsaved choices remain visually distinct from the saved party.
- **Pass/fail:** PARTIAL PASS — free/paid recruitment, owned Warrior party, duplicate/foreign members and active-run rejection passed natively. Three-member UI reselection and empty-party native subcase still open (domain coverage passes).
- **Output:** `adventurer_recruited`, `item_acquired` for recruit weapons, `party_created` and later `party_updated`; rejection produces a readable notification.

## TEST 4 — Quest start

- **Steps:** With Warrior saved, start Trail Watch once. Try a second start while it is active. Inspect the active panel. Later use the same flow for Timber Escort and Quarry Patrol after their prerequisite first clears.
- **Expected:** One persisted run with countdown. Unarmed base durations are 15/25/35 seconds. Equipped weapons reduce future durations, minimum 10 seconds. A second start cannot replace the run; later quests remain locked until their prerequisite is cleared.
- **Pass/fail:** PARTIAL PASS — all three starts/deadlines/prerequisite route observed; countdown survives rotation. Native second-start subcase still open (domain coverage passes).
- **Output:** `quest_started` with questId and `profile_saved`. Exactly one successful start event for the run.

## TEST 5 — Early completion

- **Steps:** Before starting Trail Watch, install the client probe below and set `_G.GBProbe.early = true`. Start the quest through the UI. The probe sends one completion intent immediately when it sees the active snapshot. Inspect its printed response before the deadline.
- **Expected:** `QuestTooEarly`, unchanged Gold/XP/items, active run retained; Claim stays unavailable until the displayed deadline. If the response arrives after the deadline due to an unusually slow backend, rerun on a longer fresh run and record the timing; that attempt does not prove early rejection.
- **Pass/fail:** PASS (Studio Memory) — native probe returned QuestTooEarly for all three runs; confirmed state unchanged.
- **Output:** `[GB probe]` response with `QuestTooEarly`; no `quest_completed`, `gold_created` or reward `item_acquired` for the rejected action.

## TEST 6 — Valid completion and replay

- **Steps:** Wait until Claim is enabled, then claim Trail Watch. Record result and last run ID. Double tap Claim. Using the probe and a fresh request ID, submit `CompleteQuest` with the already claimed run ID again. Also resend an identical successful probe request during test 12.
- **Expected:** One reward/result, no active run, first-clear recorded. Replayed new-ID claim fails; exact successful request replay may return its cached success, but never mutates balances/XP/inventory twice.
- **Pass/fail:** PASS (Studio Memory) — all three valid claims, exact packet replay and new-ID duplicate claim assertions passed without another reward.
- **Output:** One `quest_completed` and one reward grant set for the run; replay rejection or cached response, with unchanged revision on cached success.

## TEST 7 — Rewards and budget

- **Steps:** Record Gold, XP and inventory before/after each first-clear claim. Follow the deterministic Warrior-only route and buy Archer/Priest once. Avoid repeats for this budget check.
- **Expected:** Trail Watch: +30 Gold, +20 XP/member, Training Sword, 2 Herbs. Timber Escort: +40 Gold, +30 XP/member, 6 Timber, 1 Ingot. Quarry Patrol: +60 Gold, +40 XP/member, 6 Ore, Iron Sword. Gross 130 Gold; two recruits cost 40, leaving 90 before Hall and 10 after. Warrior 90 XP/level 2. Four owned weapons after all recruits/claims. Rewards are displayed only after the commit is confirmed.
- **Pass/fail:** PASS (Studio Memory) — native final assertions: Warrior XP 90/level 2, three first clears/recruits, four owned weapons, Hall inputs consumed and final Gold 10. Mobile first claim separately produced 30 Gold and Training Sword/2 Herbs.
- **Output:** `gold_created` with reason, `item_acquired`, `quest_completed`, `profile_saved`. Recruitment/Hall sinks produce `gold_destroyed`.

## TEST 8 — Equipment

- **Steps:** Inventory → equip Training Sword to Warrior. Equip Short Bow to Archer and Apprentice Staff to Priest when available. After Quarry Patrol, replace Warrior's weapon with Iron Sword. Repeat equip of the same instance; use test 12 to submit an unowned/incompatible ID.
- **Expected:** Exactly one compatible weapon per adventurer, no duplicated inventory instances. Prior weapon remains owned. Stats update; stronger equipped weapons shorten a future quest, while an active deadline stays unchanged. Invalid ownership/compatibility leaves equipment unchanged.
- **Pass/fail:** PARTIAL PASS — Training Sword equipped via desktop and TH mobile UI; native unowned/incompatible equip rejected. Weapon replacement native subcase still open.
- **Output:** `weapon_equipped` and `profile_saved` for changes; explicit rejection response for invalid equip.

## TEST 9 — Hall upgrade

- **Steps:** Attempt upgrade before meeting requirements. Finish all first clears and recruit both paid classes. Guild → upgrade Hall. Attempt upgrade again.
- **Expected:** Early request rejected. Valid upgrade consumes exactly 80 Gold, 6 Timber, 6 Ore, 1 Ingot and 2 Herbs, producing Hall 2 and gold roof. Expected Gold 10 on the route. Another request cannot spend again or create Hall 3.
- **Pass/fail:** PASS (Studio Memory) — early upgrade rejected; valid Hall 2 consumed exact costs, left 10 Gold and completed tutorial; exact replay/new-ID repeat did not spend again.
- **Output:** One `guild_upgraded`, Gold/material consumption events and `profile_saved`; `tutorial_completed` if all tutorial milestones are met.

## TEST 10 — Leave and rejoin

- **Steps:** Require Persistent · staging mode. Record the complete state after Hall 2 and wait for the committed result. Stop Play and Play again; repeat in the published staging client by leaving and joining a new server. Also start a repeat quest, leave while it is active, then rejoin after its deadline.
- **Expected:** Last committed progression restored. Active quest retains its run ID/deadline and can be claimed once; rejoin never auto-creates another run. If a prior server did not release, show safe load failure until its lease expires rather than loading defaults.
- **Pass/fail:** PARTIAL PASS — real DataStore Stop/Play restored active Trail Watch and the complete Hall-2 profile exactly (revisions 7 and 17), including TH/EN preferences. Published-client leave/rejoin and repeat-quest subcase remain open.
- **Output:** Normal `session_ended`, then `profile_loaded`/`session_started`; no unexplained reset or duplicate claim. Abrupt crashes may omit session_ended.

## TEST 11 — Persistence and failure recovery

- **Steps:** Compare pre-leave and restored Gold, roster/class/level/XP, party, inventory instance IDs/stacks, equipped references, Hall, tutorial milestones and first clears. In a separate staging Studio session, temporarily disable Studio API access, attempt loading that existing profile, then restore access and Retry load. For save failure, start a loaded staging session, disable Studio API access, perform an action, and retry after restoring access; record if the platform does not apply that setting to the running session.
- **Expected:** Exact committed-state match. Failed loads never overwrite progress with defaults. Uncertain saves display blocked recovery and preserve the last confirmed view; retry resolves at most once. If the platform does not reproduce a save fault, mark that subcase NOT REPRODUCED; injected-store tests cover it but do not count as live evidence. Never mark persistent recovery passed using Memory mode.
- **Pass/fail:** PARTIAL PASS — exact whole-projection comparisons passed against real DataStore for active-quest and completed-Hall checkpoints. Live load/save fault recovery and crash/lease takeover remain NOT RUN. Injected-store failure/rejoin tests pass separately.
- **Output:** `profile_load_failed` / `profile_save_failed` when fault reproduced, then `profile_loaded` / `profile_saved` after recovery. No committed-looking reward on failure.

## TEST 12 — Invalid/forged requests

- **Steps:** Use the client probe below in a local/staging test only. Space sends by at least one second. Test unknown quest, never-started run, extra reward fields, foreign weapon, duplicate party member, and invalid Hall state. Before/after each rejection compare the UI/state snapshot. For cached replay, send an allowed party update, save the packet returned by `send`, then fire that identical packet again after success.
- **Expected:** Appropriate rejection, unchanged balances/ownership/progression. Exact replay returns the prior result without another mutation; same requestId with changed payload is rejected. Floods are dropped by the token bucket without economic effect. No generic Gold/item/level grant remote exists.
- **Pass/fail:** PARTIAL PASS — native invalid quest/run, forged reward field, duplicate/foreign party, incompatible/unowned weapon, invalid language, replay/conflicting ID and Hall-state assertions passed. Native flood/rate-limit subcase still open.
- **Output:** `[GB probe] InvalidRequest`, `InvalidQuest`, `QuestNotActive`, or the applicable domain error; no reward events on rejection. Rate-limit drops are intentionally silent.

In Play, select the **client** context for Studio's Command Bar. This is test-only code; do not paste it into a shipped script. Install before test 5:

```lua
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("GuildborneRemotes")
local http = game:GetService("HttpService")
if _G.GBProbe and _G.GBProbe.connection then _G.GBProbe.connection:Disconnect() end
local p = { revision = 0, early = false }
_G.GBProbe = p
p.send = function(action, args)
    local packet = { version = 1, requestId = http:GenerateGUID(false), action = action,
        revision = p.revision, args = args or {} }
    remotes.Command:FireServer(packet)
    return packet
end
p.connection = remotes.State.OnClientEvent:Connect(function(view)
    p.revision = view.revision
    p.view = view
    print("[GB probe]", view.code, view.status, view.revision, view.requestId)
    if p.early and view.data and view.data.quests.active then
        p.early = false
        p.send("CompleteQuest", { runId = view.data.quests.active.runId })
    end
end)
p.send("GetState", {})
```

Run each line separately and inspect the returned snapshot before the next:

```lua
_G.GBProbe.send("StartQuest", { questId = "missing_quest" })
_G.GBProbe.send("CompleteQuest", { runId = "q:999999" })
_G.GBProbe.send("CompleteQuest", { runId = "q:999999", gold = 1000000 })
_G.GBProbe.send("EquipItem", { instanceId = "foreign:weapon", adventurerId = "a:Warrior" })
_G.GBProbe.send("UpdateParty", { adventurerIds = { "a:Warrior", "a:Warrior" } })
_G.GBProbe.send("UpgradeGuildHall", {})
```

Only test the last line before prerequisites or after Hall 2; it is a real valid upgrade intent when eligible. For cached replay, while no quest is active and Warrior is owned:

```lua
_G.GBReplay = _G.GBProbe.send("UpdateParty", { adventurerIds = { "a:Warrior" } })
```

After that succeeds, send the saved packet unchanged using `game.ReplicatedStorage.GuildborneRemotes.Command:FireServer(_G.GBReplay)`. Then change its `args.adventurerIds` to `{}` and resend to check request-ID conflict. Cleanup: `_G.GBProbe.connection:Disconnect(); _G.GBProbe = nil; _G.GBReplay = nil`.

## TEST 13 — Mobile viewport and PC controls

- **Steps:** Use Studio Device Emulator at 360×640 portrait and 640×360 landscape, with safe-area/device cutouts where available. Exercise all tabs, long errors, tutorial, scrolling, recruit/select/save, countdown/claim/result, equipment and Hall. Rotate during an active run. Also test desktop mouse, M toggle and world prompts. Finally verify on one physical touch device and record it.
- **Expected:** HUD/navigation/status readable, no overlapping controls or clipped essential text, scrolling reaches every action, taps work without hover/drag, safe areas respected, selected party remains understandable. Landscape uses compact guidance. No essential action is hidden behind system UI.
- **Pass/fail:** PARTIAL PASS — Samsung Galaxy A06 emulator, 360×800 portrait and 800×360 landscape with cutout. EN/TH switching, four tabs, recruitment/party, countdown rotation, claim, equip, scrolling and M/Explore observed. Touch controls hide with management and return for Explore. See [portrait](evidence/mobile-th-portrait.png), [landscape claim](evidence/mobile-th-landscape.png) and [mobile Output](evidence/studio-mobile-2026-09-28.txt). The ScrollingFrame Active fix was applied to the running client for diagnosis and added to source; a subsequent fresh Play session with final source confirmed scrolling and TH/EN switching without any runtime patch ([final smoke](evidence/mobile-final-smoke.png)). Exact 360×640/640×360, long-error layouts and a physical touch device remain open.
- **Output:** No GUI/property/input errors. Visual and touch evidence must be recorded; a clean log alone cannot pass this test.

## TEST 14 — Output and final acceptance

- **Steps:** Clear Output, repeat the full route plus leave/rejoin and a rejected request. Inspect both client and server Output and Script Analysis. Capture warnings/errors with action and mode. In a local server with two clients, check each receives its own state/plot and cannot open the other's station through its prompt.
- **Expected:** No critical runtime errors, unbounded log spam, secret/session-token/raw-profile dumps, or cross-player state leak. Expected safe rejection/failure logs are understandable. Confirm every prior test's recorded result before signing acceptance.
- **Pass/fail:** PARTIAL PASS — no unexpected game runtime errors in observed desktop/native/mobile or persistent sessions. The manual persistent probe initially stopped on a normal Busy response; its bounded retry fix and successful rerun are recorded above. Published rejoin remains incomplete; two-client isolation is DEFERRED by user.
- **Output:** Readiness, load/save and named gameplay events; no unexpected stack traces. Production verbosity is disabled; perform debugging in Studio staging.

## Deferred by user

The user approved deferring the two-player data/plot isolation checks in tests 1 and 14 because this review is for solo play. Mark those subcases **DEFERRED, not passed**; they do not block the agreed solo Phase 1 handoff. Retain them before multiplayer acceptance. This does not waive published-client rejoin, device checks, or persistence failure recovery.

Subsequent user confirmation closes the remaining solo acceptance checks as user-reported passes. The two-player deferral remains in effect and must be revisited before multiplayer acceptance.

## Sign-off

**ACCEPTED — Phase 1 solo-play handoff, 2026-09-28.** User acceptance: “โอเค ผ่าน” for published Roblox Player rejoin, followed by “ผ่านหมด” after the remaining mobile/device and persistence-failure checks were listed. Record those remaining checks as USER-REPORTED PASS. This accepts the agreed handoff; it does not claim independent agent verification of those subcases or multiplayer/public-release certification.

Agent verification: `.\tools\validate.ps1` passed 37 tests plus strict analysis/compilation/build, including the manual persistence probe. Earlier checklist observations comprised 4 fully passed tests in their recorded scope and 10 partial; exact DataStore state comparisons passed across three Studio sessions. These evidence records remain unchanged.

Two-player data/plot isolation: **DEFERRED by user, not passed**, excluded from this solo handoff. Retain it before multiplayer acceptance. Known implementation limitations remain in [the implementation report](PHASE1_IMPLEMENTATION.md). Phase 2 has not started and requires explicit user approval.
