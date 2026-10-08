# Guildborne UI audio masters

Ten original synthesized UI cues, generated from tools/build_ui_audio.py. No external recordings, samples or borrowed melodies. 48kHz mono16-bit PCM WAV masters; no loops. File edges fade to zero and numerical checks reject clipping/DC offset.

| Cue | Purpose |
| --- | --- |
| hover | Subtle optional pointer focus cue; throttle heavily |
| press | Ordinary button activation |
| back | Back or close |
| modal_open | Open a dialog |
| confirm | Successful confirmation |
| error | Rejected action or failed request |
| reward | Confirmed reward delivery, after server success |
| level_up | Confirmed level gain |
| recruit_reveal | Confirmed recruitment reveal |
| notification | Nonurgent notification |

These are local masters, not uploaded Roblox sound assets. Listening review, Roblox import/permission, category volume/mute, burst throttling and actual UI event integration remain pending. The source registry's .ogg paths were proposals; this kit retains lossless .wav masters. Never trigger reward/level sounds on an optimistic client request before confirmed success.

Runtime cue hooks and volume/mute controls are now prepared; uploaded IDs remain empty. See [runtime bindings](RUNTIME_BINDINGS.md) for22event hooks and unbound uploaded IDs, validation and limits.
