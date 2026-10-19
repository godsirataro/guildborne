# Native cue06: manual-arm endpoint still inconclusive

2026-10-19, Studio b09fd8fb-bc78-4c36-a2b5-ac3141e6f2cb, isolated 0/0 Memory,
candidate f9d8ac1cb7f0e9d01affaa7fd0aea1779571fed43963047f58b130652a0e3684.
Probe fefe3d8 was enabled and StartRequested armed through native Properties.
No ExecuteLuau spanned active recording or cleanup. Warmup passed122 samples,
max gap0.0186865s and consecutive stable2.0000226s. Raw envelopes preserved.

Actual terminal result INCONCLUSIVE before any cases/requests/VFX.1267 Heartbeats,
maximum gap0.0186948776s; cleanupErrors empty. Manual-arm interval endpoint
1792380237.978566 preceded its latest recorded sample1792380237.971273 by7.293ms.
Coverage explicitly says end_sample_pending, maxWindowGap0.0180940628s.
Manual-arm line still called synchronous covered(), bypassing the new observe
publication barrier. Independent reviewer confirmed the call-site defect.
S15 follow-up98d9edf applies the same barrier to the captured preceding1s arm
window. This run does not prove that follow-up or any cue acceptance.

Console tool response was truncated; preserve it as returned, not a full stream.
Final assert line389 was observed after terminal output/cleanup, then summary
attribute was read and Play stopped. No audible or server-combat acceptance.
