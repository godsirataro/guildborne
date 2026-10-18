# Multi-route readiness integration

2026-10-18: S17 779948155d8a9a423e0aa736633c4ad70c1ef9ff integrated as ffd2760.
Four owned files changed: TravelService, TravelRules, focused walking tests and
continuous-travel README. Worker released its shared-v6 lease before integration;
controller holds expansion-integration, owner master-controller-multiroute.

Independent controller review found no integration blocker. Controller reran the
actual focused runners with the existing controller Luau binary against the
worker checkout: 32 continuous walking and 14 shared-local checks passed. Initial
attempt at the worker-local binary failed because that binary was absent; no test
pass was claimed for that attempt. Existing binary retry completed exit 0.

Explicit identities now include current city_greenwood_west and proposed
greenwood_ironveil_south. A known identity does not enable travel: live supplied
descriptor and controller eligibility gate remain required. Bootstrap still
permits City-Greenwood only and WorldService supplies that single physical edge.
No additional runtime connectivity, progression or release flags changed.

New regressions cover two-edge chaining, stationary shared-zone arrival, denied
second edge, duplicate/unknown/mismatched registries, order-independent ambiguous
entries and rejection of history seeded by jumping into overlaps, descriptor
revocation, civic model/spawn lookup and elevated private-mine exclusion.
Existing source-zone/respawn latch and local incoming-direction hairpin behavior
remain. Surface resolution is bounded vertically; private portals remain separate.

Full controller baseline is running as exec session 44744, raw log
build/controller-multiroute-v6-baseline.log. Inspect terminal outcome before
claiming whole-source local checks. Earlier native party passes belong to earlier
source and must not be promoted to this revision. Native regression is queued
after S14 releases ux-system's exclusive Studio environment lease. No root Studio
mutation while S14 holds it. Earned sessions remain preserved.

S14 implements native inventory/equipment composition under ux-system first,
then sequential gameplay-ui-quality for localization/tests. S13 authors coastal
composition under world-quality-slice. S15 authors isolated combat harness under
enemy-quality-slice. All native acceptance remains controller-run after review.
Full all-city/Lv100/tower/custom-quality production goal remains ACTIVE.
