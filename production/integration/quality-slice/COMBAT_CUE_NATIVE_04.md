# Combat cue native attempt 04

INCONCLUSIVE, zero cases. Candidatee3d1ce291cc75f4f48b678055b0cf8a524450b3163d59fb0e3826557d485229e,
sourcec67c8c4, Studioa8fce3d2-d63d-4fa2-9c64-7c17e00bc0ab.
Verified active server scripts0, disabled bootstrap/probe, PlaceId0, neutral
spawn and64x1x64floor. No Rojo sync to this fixture.

Warmup actually passed:122samples, maxgap0.0181238s,2.0003895s stable living
grounded character and Custom camera with current Humanoid subject. Enabled
probe once at1792374769.088254; no StartRequested sent.
Camera changed back to Custom at1792374769.110428 after probe setup. Sameidentity,
subsequent camera distance9998studs, zero actions/requests/VFX/cases. Probe's four
heartbeats had maxgap0.01714897, so this failure cannot be explained by missing
warmup coverage. Raw warmup/console responses preserved. Cleanup errors empty,
Play stopped. The exact setter remains under source investigation; a sole game
Custom setter in BuildView.stop is a lead, not a proven invocation chain.

Warmup fixes empty-world setup but is insufficient. Do not weaken guards or
repeat frames to force Scriptable; resolve constructor/initialization ownership.
This is neither server combat nor audible sound acceptance.
