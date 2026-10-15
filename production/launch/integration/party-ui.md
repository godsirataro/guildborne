# Human Party native UI

The Human Party panel is distinct from the existing NPC heroes tab. Guild provides a shortcut even before the Novice story is complete; the NPC team panel links to Human Party. Existing `data.party`, NPC selection, saved heroes and profile revision remain unchanged.

Projection is top-level `humanParty`. Membership, invites, directory and availability changes must advance its viewer revision; SliceUI compares that revision independently of profile revision. All controls submit the captured `partyRevision`; the server rejects stale state. Incoming invitations never auto-open the panel or change a pending request. Player names are plain TextLabel content with RichText disabled.

Actions: invite, accept, decline, leave, disband, kick, transfer leader and ready status. Leaving, disbanding, kicking and transferring require a second local confirmation; any revision change clears the confirmation. Ready status is explicitly not travel consent. Copy describes membership preview only and does not promise shared travel, combat or reward settlement.

## Studio fixture recipe (pending coordinator execution)

Use the existing native UI with local Memory profiles. Supply server-issued state, not client ownership edits. Check at 360×800 portrait, 800×360 landscape and 1280×720 desktop, in English and Thai. No physical-device acceptance is implied.

1. Solo profile: Guild shortcut exists before founding, panel explains solo play, NPC team link preserves the selected NPCs.
2. Two users with identical display names and distinct usernames: identities remain distinguishable, including literal markup-looking names; send/accept/decline controls refer to correct IDs.
3. Incoming invite with unchanged profile revision but increased human-party revision: panel refreshes without forced navigation. Wait for expiry and verify stale acceptance receives a server rejection.
4. Six members with five heroes each: scrolling fits all rows; no duplicate sixth invite; nonleader cannot kick/transfer/disband. Reconnecting row communicates reserved place.
5. Leader: tap kick/transfer/leave/disband once to arm, cancel or tap again to submit. Update party revision between taps; prior confirmation must clear.
6. Busy/loading/unavailable state: mutations disabled; ready button reflects server state only. Keyboard/controller selection and touch targets use the existing 52-pixel buttons. Confirm long Thai text wraps without clipping.
7. Return to NPC heroes: original UpdateParty intent and personal Guild ownership still apply. No human action changes another owner's NPC team.

Pending: real two/six-player Studio run, narrow screenshot evidence and physical touch testing. Local fixture checks cannot establish multiplayer or device acceptance.

## Active Novice layout priority correction

The coordinator observed the chapter-1 claim outside the scroll viewport at 874×402 (content height 144px), behind optional daily/season and Human Party navigation. `SliceUI.guild` now draws an unfinished Novice journey (`claimed < 6`) before the Human Party shortcut. The shortcut remains available immediately after the Novice card. Completed/non-Novice Guild ordering is retained.

The existing scroll UIListLayout sorts by LayoutOrder. Guild's Daily and season rewards navigation now uses LayoutOrder 100, after the core Guild/Novice cards whose default order is 0. The same navigation on LaunchRewards retains order 0, preserving the top Back to Guild control. Button names, callbacks, enabled states and English/Thai labels are unchanged; other tabs and profile loading/paused states are untouched.

Scoped compilation and Roblox-aware static analysis passed for SliceUI. No implementation-mirroring layout test was added. Actual viewport/click verification and independent diff review remain coordinator-owned; this source fix alone does not claim physical-device acceptance. See `production/design/integration/NOVICE_CHAPTER1_OBSERVATION.md` for the observed original behavior.

Visual follow-up: coordinator verification found the priority corrected but the 52px claim button still clipped by 5px in the 144px content viewport. The compact duplicate guidance line is now suppressed only on the Active Guild tab with an unfinished Novice journey and a Novice objective already shown in the HUD tracker. Loading/error/paused states, other tabs, non-Novice tracking and their guidance remain unchanged. This saves the duplicated line's height; final English/Thai viewport verification remains required. Compilation and static analysis passed after this adjustment.

## Contextual Human Party outcomes

Actual multi-client observations surfaced generic retry/rejoin wording for normal HumanPartyStale and HumanPartyFull outcomes. SliceController now maps all nine currently emitted HumanParty outcome codes to useful English source strings, with corresponding Thai translations: Stale, Full, LeaderRequired, AlreadyMember, InvitePending, InviteLimit, InviteExpired, NotMember and Unavailable. These messages describe changed membership, capacity, invitation lifecycle or temporary availability without exposing internal code strings or recommending an unnecessary rejoin. Unknown unrelated errors retain the existing fallback.

The path remains State.OnClientEvent → messages[view.code] → ui.Update → localized status text; when the management panel is closed, the existing localized world notice displays the same message. No server validation, network packet, profile, membership behavior, view layout or retry behavior changed. Both changed files compile and pass scoped Roblox-aware static analysis. No dictionary-mirroring test was added. Coordinator verification should replay an isolated copy of an existing valid state snapshot through the actual State remote with each code and EN/TH display language, assert rendered text contains neither the raw code nor generic rejoin advice, and inspect Stale/Full wrapping with the party panel open and closed. Such presentation-only replay must not write a player profile or claim real server rejection behavior; actual membership rejection evidence is separate.
