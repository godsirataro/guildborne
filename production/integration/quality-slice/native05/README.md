# Native cue run 05: inconclusive

Same unmodified candidate04 SHA256 e3d1ce291cc75f4f48b678055b0cf8a524450b3163d59fb0e3826557d485229e; Studio a8fce3d2-d63d-4fa2-9c64-7c17e00bc0ab. Current controller source f387f05; this is not a new candidate build. Play stopped after terminal capture.

Raw04 identified the actual camera change: ExecuteLuauActions resets Scriptable to Custom after returning. Production constructors were not the cause. Warmup now returns with probe disabled; native client Properties enables it after the MCP call returns. A short preceding client command selected the disabled probe and initialized StartRequested=false. Native Attributes sets true after READY. No executed Luau call spans active probe or teardown.

Warmup:123 samples, maximum gap0.0181536 seconds, stable2.0166196 seconds. Native UI enable preserved the probe camera. Manual arming reached first missing-target case; negative-window coverage then refused. Summary reports maximum gap0.097789049 seconds,1377 heartbeats,383 waits,0 requests,0 VFX,0 completed cases, cleanupErrors empty. This is INCONCLUSIVE, not cue acceptance. The reported gap is below0.15; boundary coverage/order needs source diagnosis, not a relaxed threshold.

Output filtered to CLIENT_CUE_PROBE_TERMINAL confirmed terminal logging; visible camera returned to the avatar. Only then a no-yield client read captured report.json and Play stopped. console.json preserves the tool's truncated response exactly; it is not a full raw stream. Long manual READY generated substantial output. Audio remains unbound and server combat was not tested.

The exact executed warmup-command.luau is preserved. The main warmup helper now uses this safe native-enable boundary. No runtime timing, camera guard or production gameplay source was changed.
