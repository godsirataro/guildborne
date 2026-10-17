# Ironveil chapter-7 routing checkpoint — 2026-10-17

Reviewed source integrated as 0edd88a. Only CityNavigation, QuestRoute and city_waypoint tests changed. Existing server marker names, owner attributes, enabled prompts and floor geometry are consumed without changing combat, quest or reward authority.

The public Guild/City/other-region travel legs no longer depend on streaming the private mine. Private Ironveil guidance requires the actual owner's model and floor; Y distinguishes surface, own interior and other vertical slots. Explicit scale/carrier/reception marker names prevent always-enabled MineExit from winning nearest-objective selection. Completed/disabled scales retarget to remaining enabled scales. Unstreamed private geometry stays unavailable.

Independent review approved after public-leg ordering and localized entrance-name corrections. Final focused existing city_waypoint suite: 15 PASS (build/ironveil-route-focused.log); final scoped LSP passed. Earlier full suite started before final corrections, and its observation handle was unavailable to root; no final-source full-baseline claim.

Actual earned Studio a6d25956-416f-4c3b-96bd-8a471f6f9819: client-only review5 navigation/route source copies installed, preserving review3 beacon and review4 menu gate. Ordinary N and Guide to quest objective click selected current server snapshot objective inspect_ironveil_scales, chapter7/claimed6/Hall2. Initially route unavailable: read-only ray inspection found the owned Warrior HumanoidRootPart between player and first island path point. Ordinary S held1second moved player from(-0.4065,3.998,-5.4217) to(-0.4084,3.998,11.2159); actual card then displayed Follow the island path / Central City / 7 studs. No profile/reward/position injection. Navigation selected and map closed.

This proves actual current snapshot and initial island route rendering only. Full ordinary city-to-mine traversal, scale completion/retargeting, carrier/reception interactions and source-composed whole-build acceptance remain pending. Transient companion obstruction can currently suppress authored path guidance; preserve this observed limitation for followup rather than treating a pure-route test as end-to-end acceptance.

## Ordinary traversal and chapter completion — subsequent actual run

Using only ordinary keyboard movement and real E/R prompts, controller walked the existing earned character along island path/bridge/promenade, used the city exit, walked the city road and entered Ironveil. City card showed Follow the city road / Ironveil /670studs from(0,3.698,-720). After real city gate E, surface arrival(500,4.998,1515) showed destination-direction Ironveil /17studs. Real MineEntrance R moved the player to the server-authored interior(500,102.998,1502); card changed to Inspect all three ore scales /56studs, without confusing MineExit at the same arrival position.

Ordinary W/A movement reached scale3 at approximately(461.338,102.998,1466.489); R disabled scale3 on the server and card retargeted from3 to17studs. Subsequent A/R completed scale2 then scale1. Enabled prompts changed to carrier at(431,100.15,1473), and card changed to Speak with the ore carrier /7studs. Ordinary S/R accepted carrier and card changed to Reach the Ironveil mine reception /71studs. Ordinary D/S/R reached reception at(497.871,102.998,1490.562).

Fresh actual State event then projected ready=true / Claim chapter rewards in the Guild menu, with claimed=6, hallPermit=2, objectives inspect_ironveil_scales=true, interview_carrier=true, enter_ironveil=true; Hall2 and688Gold unchanged. Chapter7 reward has NOT been claimed yet. Route-unavailable after ready state is expected from no physical objective, but its wording merits UI polish. Intermediate owned-companion ray blocking also briefly suppressed island guidance; do not claim continuously available authored-route UI.

This extends evidence to ordinary island→city→surface→mine travel and all three chapter7 objectives/retargeting on the earned server. No injected profile/quest/reward/position. Client navigation still uses review5 source copies, not a fresh combined whole-build. Current earned character remains by mine reception, menu closed, chapter7 ready for GUI reward.

## Ordinary chapter reward claimed

Actual Guild menu button, scroll-up and CampaignClaim click accepted chapter7 reward. Fresh State: claimed7, level22,XP1053,Hall2,748Gold, nextobjective read_mine_signal / Read the three-symbol safety signal. Player still by mine reception; Management open. No reward/profile injection. Chapter8 onward route expansion is being implemented separately, not yet accepted.

## Remaining chapter routing and real chapter8 escort

Independently reviewed five-file remaining-Ironveil routing candidate integrated41ff1c8. Final focused tests17routecases,GUI simulation,LSP/compile passed. Candidate adds explicit objective areas for puzzles/choices, replicated escort/protection state, own guardian surface exit and trial suppression, plus coordinate-free claim instructions. It does not invent server-private puzzle progress. Live context for protection/guardian/trial is still unverified.

EarnedStudioa6d client now uses exactsource navigation/route/beacon review6 copies, keeping review4MenuGate. Actual N/Guide selection near(538.670,102.998,1468.409) displayed Read the three-symbol safety signal with destination-direction guidance. Controller read actual MineInstructions Billboard text: TRIANGLE→DIAMOND→CROSS, diamond safe shaft. Ordinary movement/R followed these instructions; server-enabled markers changed from read signals to shaft choices. Ordinary A/R selected diamond and objective became rescue_miner.

At approximately(543.355,102.998,1469.268), real R started escort. Actual replicated mine attributes: EscortStatus Walking, EscortPosition(544.831,100,1470), EscortExit(555,100,1478), DeliveryProblem OK; card pointed to live miner1stud away. Ordinary D/S movement stayed near worker; after3seconds escort completed and dynamic attributes cleared. No NPC/profile/reward/position mutation.

Fresh State confirmed claimed7, objectives read_mine_signal/choose_safe_shaft/rescue_miner alltrue, readytrue,748Gold unchanged. Actual card displayed Claim chapter rewards in the Guild menu., TextFitstrue, blank destination/distance, DestinationCompass.Visible=false, WaypointBeacon.Enabled=false. Chapter8 reward NOTclaimed yet. Player remains(551.028,102.998,1471.989),Hall2,Lv22,Managementclosed. This is actual puzzle/escort/instruction transition evidence, not allremainingminecontent orfreshwholebuild acceptance.
