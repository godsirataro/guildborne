# Four existing residents: occupation pose candidate

Base: 6c5be3b, shared v9 ledger, living-world-npc-slice. This adds four exact
keys to CivicWorkMotion and extends its existing registered test module.
No builder, schedule, identity, animator or server authority changes.

| Actor | Intended reading | Existing prop binding | Joints to observe |
|---|---|---|---|
| borga | Offer a mug, lower it again | Mug/MugRim -> RightHand | RightUpperArm, RightLowerArm, RightHand |
| mogra | Glance down toward the herb satchel | Satchel/Herbs -> LowerTorso, unchanged | Head, LeftUpperArm, LeftLowerArm |
| rukk | Raise and inspect the hammer | HammerHandle/HammerHead -> RightHand | RightUpperArm, RightLowerArm, RightHand |
| ghar | Lift the shield slightly and survey the road | Shield/ShieldBand -> LeftHand | LeftUpperArm, LeftLowerArm, Head |

Existing eight-second envelope and six civic poses remain unchanged. All new
angles remain below 0.7 radians; no root, pelvis, leg or foot channel is emitted.
The existing animator resolves these actors by model name, blends through its
work/pause weights, suppresses work during dialogue/greetings and restores poses
when culled or Reduced Motion is enabled. No second motor writer is added.

These are procedural pose candidates, not imported clips or approved art.
Rukk inspects his held tool: no anvil, impact event, flash or audio is introduced.
Mogra's herbs stay on the satchel; no picking, grasp or hand-contact claim.

## Local verification

The existing tests/civic_work_motion.luau is already called by tests/run.luau.
Coverage now includes ten nonempty, bounded upper-body loops, reduced-motion and
invalid-time refusal, distinct peak signatures, prop-arm activity, returned-table
isolation and wrap continuity. Exact final baseline/review receipts are reported
in the delivery handoff; this document does not certify native acceptance.

## Controller native check: pending

Walk normally to Borga (-150,-837), Mogra (218,-1034), Rukk (404,-990) and Ghar
(39,-1508), using X/Z anchors only; retain actual ground/root Y. Within 50 camera
studs and with Reduced Motion off, observe each for at least 48 seconds. Record
the named Motor6D C0 values above, the prop world transforms, root/foot transforms
and NpcLifeActivity/WorkWeight. Confirm visible role-specific motion, planted
feet, stable grips and no torso/face intersections before approving the look.

Open normal E dialogue during Work and across a pause, close it and allow the
existing interaction hint to expire. Check fade/recovery, greeting and prompt
availability. Walk beyond 160 camera studs and return, then test the existing
Reduced Motion control: no pose/effect backlog or stale joints. Compare the six
civic actors, especially Borin, for regression. An unavailable actor/route is a
pending gate, not permission to seed earned progression. No native tests were
performed by this source-only worker.
