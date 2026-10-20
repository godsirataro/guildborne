# Hero support probe repair candidate

R4 server capture showed Archer at time 1792457791.678412 grounded on
Greenwood.Landing (root Y5, floor Y2, RecoveryCount1). At 1792457791.894459,
RecoveryCount became2 and root Y15.5, with the downward observer ray hitting
RegionalGateLintel at Y12.5. Mage repeated the transition at 1792457820.560792,
count2 to3. Compressed page hashes were verified against page-manifest.json.
City-to-Greenwood arrival occurred, but first-road companion settling failed.

HeroService.floor previously began its downward ray eight studs above a root
history/formation reference, selecting the overhead gateway. The unattainable
goal then triggered the existing seven-second stuck recovery. The candidate
starts the probe one stud above that reference and casts down 17 studs. It
preserves the original lower search bound (reference Y minus16),
collision filters/group, three-stud root offset and every recovery threshold.
It has no fixed world-height limit and does not change terrain or progression.

Focused validation command:
`python -B production/world/continuous-travel/check_hero_support.py`

Observed result: 18 checks passed against functions extracted directly from
HeroService, including the native floor/lintel coordinates, Travel root Y7,
jump reference Y9, repeated support resolution, ten-second stationary dwell,
elevated floor, slope, modest upward step, void, rejection of a floor20 studs
below the reference, acceptance at the original minus16 boundary, and unchanged
far/stuck recovery.
The exact same regression fails when the extracted source is mutated back to
the previous +8 probe, reproducing the root Y15.5 lintel target.
HeroService compiled with luau-compile --null.

These are geometric mocks, not native pathfinding or jump acceptance. Actual
gateway arrival and more than seven seconds of stationary five-hero settling
still require a fresh native candidate. Historical R4 and R4b results must remain
unchanged and attributed to their original source.
