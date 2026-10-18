# Native corridor return verification

Observed terminal PASS_NATIVE_FIXTURE on 2026-10-18 in disposable Studio
155918dd-6441-494e-9cf3-3506c00476f7. Raw MCP response is retained beside this file.
Game source was 8b38847, packet 4d880bce36a444e9d12e26b78dbb60001b20aea667ad844886b7b35940cf913c;
385 sources were read back during transfer. This is not whole-place identity.
Fixture source: production/world/city-zones/ContinuousPartyFixture.server.luau.

The single WorldService fixture used a real player Humanoid and five synthetic
eligible companions, walking all 38 corridor nodes outward and back. It completed
79 segments and 1488 samples, returning to City and CentralCitySpawn with no active
walking context. All five survived with recovery counters unchanged at 1, maximum
separation 22.6114501953125 studs, maximum sampled player displacement
3.8265445232391359 studs, zero reward callbacks and no notifications.

This verifies the local-tangent hairpin fix and bounded native party continuity.
Sampling does not prove absence of every transform write. Synthetic roster and
eligibility do not prove earned progression, recruitment or authorization. S15's
later presentation change is absent from this running source. The separate art
Dataset2 import failed; this result does not accept landforms, final art, full GUI,
combat, physical-device performance or all-city connectivity.

Post-integration source baseline completed separately with exit 0: 936 tests,
385 strict Luau files, 43 evidence/design documents and 488 local links. Raw log:
build/controller-greenwood-motion-v6-baseline.log. Baseline checks do not replace
native runtime acceptance. Console also reported asset 203785492 type mismatch
and Roblox CorePackages UI warnings; those were not repaired by this fixture.
