# Original audio runtime bindings

All22WAV sources remain local, with listening/import/permission review pending. No uploaded IDs have been invented. `src/shared/Config/AudioConfig.luau` contains22cue definitions and an empty `AssetIds` mapping. Fill that mapping only with approved `rbxassetid://…` IDs belonging to the creator's usable audio library.

`AudioController` starts before the UI. It preloads only valid bound IDs, skips unloaded sounds instead of playing stale delayed cues, limits active voices to16, throttles each cue and culls spatial audio past80studs. UI audio is nonspatial; combat uses invisible, noncolliding local emitters. Ended/deadline/Destroy paths remove sounds and emitters. Loaded-audio behavior, latency and perceived loudness still need real asset acceptance.

| Cues | Current hook |
| --- | --- |
| hover, press | Enabled GUI buttons; selection focus also uses hover |
| error | Current pending mutation receives an error response; passive polling is silent |
| reward | Current pending mutation confirms a saved reward with OK |
| sword_swing, shield_block, bow_release, fire_cast, frost_cast, heal_cast | Recent own-actor cast attributes; class/effect projection |
| enemy_warning, boss_slam | Recent own-enemy telegraph/impact attributes |
| melee_hit, enemy_defeat | Own-actor HP decrease; no defeat cue when initially observing an already-dead actor |
| back, modal_open | Actual registered-menu transitions; initial registration and unchanged visibility are silent |
| confirm, level_up, recruit_reveal | Committed revision observer; initial/stale/duplicate snapshots and uncertain saves are silent. Recruitment/level cues take priority over generic confirmation |
| notification | Island entry/access-change notice |
| arrow_hit | Recent server-derived Archer damage cue on a target HP decrease; defeat takes priority |
| grass_step | Local living character running on grass, one step per3.5studs; menu, idle, sitting, airborne and teleport resets |

Settings now provide Master/UI/Combat levels plus mute. These are client-session preferences, not saved profile data. Enemy visual warnings remain visible when muted. Volume channels are multiplied by master volume and clamped to0–1; invalid preferences fall back to defaults.

Validation:4pure tests cover ID validation, bounded admission/expiry/release, invalid time and cue projection. Studio's actual running singleton passed volume/mute/clamp/fallback,28EN/THtext checks, and all22empty bindings created0Sound instances. This proves silent-safe unbound behavior, not audible playback or listening quality. See `docs/uat01/validation-audio-runtime.json`.

2026-10-03: all22definitions now have event hooks. Six pure audio tests are included in400passing domain tests. The offline client passed27checks:22unbound calls returnfalse, menu opening/closing emits exactlyone matching cue per transition, repeated visibility is silent and the real audio singleton is restored after the disposable fixture. Clean fresh-client console. Build/strict/compile/repository/offline checks pass at166runtime files. Arrow impacts, footsteps and audible/imported-asset playback still require live event/listening acceptance; these hooks do not certify audio quality.

Footstep follow-up: a disposable instance of FootstepAudio driven by actual W-key walking on native Grass requested5grass cues, then remained at5during one second idle. Its connection was disconnected and the captured Audio singleton restored. The source is called by ClientBootstrap, but this isolated controller test does not certify audible playback of the live singleton. All bindings remain empty.
