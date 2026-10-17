# Ironveil native prompt fixture — 2026-10-18

The old `tests/studio_ironveil_world_probe.luau` failed because its injected BindPrompt callback is no longer consumed by IronveilWorld. Production still binds ProximityPrompt.Triggered directly. This new controller-owned fixture does not change production code or pretend that obsolete probe passed.

`production/integration/quality-slice/IronveilPromptReview.luau` constructs the actual server service with a private synthetic session and receipt sink. It allows only reviewed pure-objective markers to move near the stationary avatar. Travel, escort, protection and borrowed-trial activation are excluded. External enabled R prompts within reach cause preflight rejection. World mutation callbacks only count forbidden attempts without performing them, allowing cleanup to finish. Independent review caught and corrected an earlier throwing-cleanup path before runtime. Compile and scoped LSP passed.

Actual native R input was sent in isolated Memory Studio `f0806b7e-820e-4851-95b8-31a8d226533f`. No Triggered callback was replaced or directly invoked. The actual service constructed 49 native prompts. Evidence in `ironveil-native-prompts-20261018.json` preserves returned tool observations, not a fabricated subprocess receipt.

Observed results:

- The retained prompt sequence uses synthetic level35, enabling eligible objectives. The earlier level1 guard observation was not retained in this JSON packet and is not counted as packet-backed acceptance.
- Three scales each became inactive after inspection; their set produced one receipt. Carrier and reception produced the next two.
- Out-of-order signal input produced no receipt; correct 1→2→3 did. Unsafe shaft1 produced none; safe shaft2 did.
- Three support inspections produced one receipt. Wrong first repair1 produced none; repair2→1→3 completed.
- Reagent and both seals completed in order. Council choice was recorded once; pressing the completed choice again produced no second receipt.
- Mechanism1→2→3 completed. Mentor interaction completed. R on Submit produced no receipt before the borrowed-path prerequisite, and produced one after explicitly setting that prerequisite in the **synthetic** session.
- First delivery intentionally retried once. Final totals: 13 private synthetic receipts, 14 delivery attempts, 13 notifications, one retry, zero forbidden World calls.
- Final state after invalidation and Destroy shows no mine, zero prompts, unchanged character/zone and zero avatar delta. The saved packet contains the final combined state, not a separate intermediate epoch-cleanup observation or wrapper-removal observation.

Synthetic stages6..11 were selected explicitly. Stage8 protection and stage11 borrowed-trial prerequisites were deliberately prefilled in private fixture data; those activities were **not tested or completed** here. Real profile service, rewards, currency, levels and DataStore callbacks were never supplied to the fixture. The returned profileWrites=0 is a fixture constant, not an independently instrumented write counter; isolation is supported by reviewed dependency construction. This is actual server/native-input behavior over simulated progression, not earned quest traversal, protection/escort/guardian/trial gameplay, persistent saving, or complete Chapter02 acceptance.
