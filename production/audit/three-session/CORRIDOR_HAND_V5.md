# Corridor and hand-carrier integration — v5

S13 583ccb3 integrated as 73da20a after independent source/manifest/render
review. S15 9cd036c integrated as ddcb63b after independent source review.
Both are incremental changes, not final visual acceptance.

New isolated Memory candidate fce080d7c50a9af7f3c2286cf3ddc31f9d98230574e1889745128f18b9e7c005
was tested in Studio a302325a-c09b-419d-bdcf-b8eb6888459b,
Guildborne_CorridorHandReview, process67264. Edit readback confirmed PlaceId/
GameId zero, Memory, LaunchCandidate/Novice/Ironveil enabled, later journeys
disabled, and updated handTracking source. Existing earned Chapter5 and
older Chapter3 sessions were not restarted or modified.
This disposable candidate was subsequently stopped; the newer candidate is
recorded in CAMPAIGN_DURN_V5.md.

After native Continue, actual read-only course probe passed all25 engine path
queries: 564parts,510visible,61colliders,15markers, four exact runtime anchors.
Radius2/height5/no jump and under700studs remain enforced. These are navigation
queries, not ordinary interactions, companion traversal or device performance.

Hand-carrier native probe FAILED on real RightHand sampling. A second diagnostic
run changed only the error text: position error0.228706stud, rotation0.222022rad
at event age0.102130. See hand-carrier-failed-v5.json for original tool errors.
Independent cleanup readbacks after runs found zero trial/proxy leftovers and
unchanged root(-4500,2.99802518,214). At that point the cause was unresolved;
the failure was returned to S15. The resolution below supersedes that status.

Diagnostic continuation: the original probe was rerun with a deferred scheduler
read after PreRender:Wait(), without changing production source. It passed on
RightHand with actual hand movement observed, position error0 and rotation
error0.000690534rad. Both Basic and Physical paths/cancellation/expiry passed.
This narrowed the initial failure to sampling order; the exact reviewed fixture
repeat follows below. Separate cleanup again found zero leftovers.

Resolved by exact probe8638c43, independently reviewed and integrated1bf9339.
Executed against unchanged production hand tracker in newer3bddf9e candidate
155918dd: PASS with15 paired samples, actual within-sample movement, post-barrier
position error0 and maximum rotation0.000845728rad. Pre-barrier mismatch reached
1.11655stud/0.68658rad; paired same-epoch samples substantiate the sampling-order
cause. Basic/Physical, duplicate, nil/replacement cancellation and expiry pass.
Independent final readback: zero leftovers, original root, HUDactivefalse and
quality unset restored. Exact raw result is hand-carrier-repaired-native-v5.json.
R6, real death/respawn, server combat and replication remain untested by this probe.

Full baseline handle27881 completed exit0:902 tests/383 strict Luau files,
43 documents/488 links, original build/analysis/compile/boundary checks passed.
Raw log SHA256:0e57873dcf79dbf682af3e76c2598599139bfae810ead055de45fbda7496b32a.
Known harness warnings remain; this is not warning-free or Studio acceptance.
S13 next pass targets the remaining flat grid and repeated oval road edges.
S17 Durn integration and S14 routing have since passed source review and been
integrated; their scoped native evidence is in CAMPAIGN_DURN_V5.md. Goal ACTIVE.
