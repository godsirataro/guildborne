# Local Novice chapter1 observation — 2026-10-14

Candidate b9a287d74c27cc7d1c59767d018568a4dae03ef6c05950216d2ff9b33178bbd0; local Place0/Game0, Memory persistence. One actual local player client. No profile editing, grants, teleport or time skip.

The coordinator clicked Begin your adventure and Explore, issued client Humanoid.MoveTo for physical walking, and used native keyboard E for courier interaction. The server advanced Meet the courier → Follow the training path → Move clear of the warning → Help the courier. During the visible practice warning, physical MoveTo moved the player about9 studs before resolution. The courier interaction completed the final objective.

J opened the Guild panel. All four objectives displayed checkmarks. The initial click targeting NoviceClaim did not claim because the control was outside the scroll viewport. Native wheel scrolling revealed it; a subsequent visible button click advanced the tracker to Practice a basic attack (chapter2). This is an automated movement-assisted normal objective/claim path, not human UAT, full Novice completion, mobile performance, persistence/rejoin or duplicate-claim verification.

## Observed usability issue

At the captured874×402 viewport, the management content viewport was only144 pixels tall. Daily/season navigation and Human Party controls appeared above the Novice objective card, pushing Claim100XP below the fold. The first click reported tool success without activating the clipped control. Onboarding should prioritize the active Novice chapter/claim before optional navigation and keep a clear scrolling affordance. Native GUI visual verification is needed after a scoped layout change.

Actual screen captures were returned in this conversation: SharedPvE_LocalPreview_AfterBegin, Novice_Chapter1_Ready and Novice_Chapter1_ClaimScroll. No local image artifact is asserted by this report.

## Chapter2 follow-on, same candidate

Physical MoveTo waypoints reached the training yard. E started the real practice arena (the game's own travel moved the player into it). M closed management; F executed one Basic Attack. Arena attributes reported Basic hits1/1, dummy HP110/120, TrialStatus=Won and ReceiptDelivered=true. The native LeaveTrial button returned normally. The coordinator then physically moved clear of the next warning and pressed E at the practice captive. All three objectives completed. J again opened the claim outside the viewport; three wheel steps and a visible claim click advanced the tracker to Follow the caravan tracks (chapter3). The claim visibility issue therefore reproduced on two chapters before the pending source fix. This is still movement-assisted automated testing, not natural human UAT or persistent rejoin evidence.

Chapter3 also completed through physical movement and E interactions: caravan tracks → rescue travelers → recover supplies fallback → visible claim. Chapter4 started the real Crossroads Keeper arena. The coordinator used F/Q while standing in place and paused for inspection; this attempt failed with playerHP0/48 and KeeperHP44/240. TrialStatus=Failed, TrialProblem=TrialDefeated and retry guidance displayed. This is a retained failed attempt, not a boss-completion claim or evidence that the encounter cannot be won. A later attempt must actively respond to warnings; no difficulty or HP was changed to pass.
