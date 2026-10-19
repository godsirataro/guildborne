# Second-edge policy preparation

2026-10-19, source a60a10d. Bootstrap now permits exactly Greenwood/Ironveil in
both directions alongside City/Greenwood. Identity/session/Active/busy, novice,
release, tower, civic charter, mentor and private-arena checks are unchanged.
WorldService still supplies only the existing City/Greenwood physical descriptor.
This change does not activate a new road, publish content or change release flags.

check_walking_gate.py extracts the actual marked Bootstrap functions and executes
walking_gate_cases.luau. Four directions each passed26 checks (104 total), including
expected refusal propagation and frozen profile tables. Independent gate_review
accepted the source and reran the probe. Content/Release are stubs here: the probe
does not certify real progression eligibility, physics, routes or Studio behavior.
Initial harness failed because an old reverse-direction call conflicted with its
destination assertion; corrected before final pass. Initial compile invocation
also supplied null as a filename; corrected --null compilation passed.

Original tools/validate.ps1 subsequently completed exit0 on unchanged a60a10d:
944 tests, Rojo build/sourcemap, analysis invocation, all-source compilation,
389 strict runtime modules and built-place coverage passed. Nonfatal existing
UnknownGlobal/ImplicitReturn diagnostics in GUI simulation fragments remain in
the raw log; this is not a warning-free claim. Class3 focused43 checks passed
separately on31713a4 before this gate-only change.

Exact captured stream SECOND_EDGE_POLICY_VALIDATION.log SHA256:
fbe60b7218773c834d6ca2ba32553fc1c8ed57f3e2d4404ce63a02cab2e317e6.
Captured exec session45772 completed; no validation job remains from this run.
S13 owns new physical geometry; controller composes descriptors after review;
S14 must extend both WalkingRouteContext and QuestRoute before guidance acceptance.
