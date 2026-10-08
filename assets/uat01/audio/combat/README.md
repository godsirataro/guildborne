# Original combat sound candidates

Twelve locally synthesized mono 48kHz/16-bit PCM WAVs: sword swing, melee hit, shield block, bow release, arrow hit, fire, frost, heal, enemy warning, boss slam, enemy defeat and grass step. No recordings or downloaded samples were used. Rebuild with `tools/build_combat_audio.py`.

The manifest records deterministic SHA-256, duration, peak and RMS levels. Checks cover sample format, finite nonzero signal, zero endpoints, near-zero DC and no clipping. These numerical checks do not substitute for listening, mixing or in-game acceptance.

Suggested wiring after import: basic sword/bow actions play their attack cue; authoritative damage feedback chooses impact/block; ability effects choose fire/frost/heal; a boss telegraph starts the warning and cancels it on cancellation; the impact cue plays only when the server resolves the attack. Footsteps need a distance-based cadence, not one cue per render frame. Limit concurrent voices and cull distant cues. UI, combat and music volume categories remain separate work.

All Roblox IDs remain empty. Listening review, import/permissions, volume balance, spatial rolloff and runtime event wiring are pending. No sound was uploaded or added to a live place.
