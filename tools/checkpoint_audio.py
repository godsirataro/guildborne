from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest audio runtime checkpoint — 2026-10-02

Original22WAVs now have a22cue configuration, local AudioController,16voice cap/per-cue rate limits, preload-ready gate,80stud spatial culling and complete sound/emitter cleanup.14cues have UI/current-response/combat attribute hooks;8remain reserved (back/modal/confirm/level/recruit/notification/arrow impact/grass step). Audio asset IDs are EMPTY. Unbound cues make no requests and produce no placeholder audio. No upload or purchase occurred. Master/UI/Combat/mute controls are local session preferences; visual enemy warnings remain available.

Actual running Studio singleton passed volume mix, mute, clamp, invalid preference fallback,28EN/THcontrols-text checks and0Sound objects for22unbound cues. No audible playback or listening acceptance claimed. Four pure audio tests cover IDs, rates/expiry/release/time/cue mapping. Domain340PASS including5,000market-order soak/0invariant violations. Main143strict runtimefiles: build/analysis/compile/repository PASS. Temporary audio probe removed and preferences restored; owned Play stopped; final voice-cap guard synced in Edit.

See assets/uat01/audio/RUNTIME_BINDINGS.md. Current quota83%used/17%remaining; continue until15%. Release and ordinary-save boundaries unchanged. Excel registry remains239design assets/65screens/28work areas, not a completion percentage.

'''
p=docs/'HANDOFF.md';s=p.read_text(encoding='utf-8');p.write_text(note+s if not s.startswith(note.splitlines()[0]) else s,encoding='utf-8')
for name in ['STATUS.md','WORK_CHECKLIST.md']:
 p=docs/name;s=p.read_text(encoding='utf-8').replace('336domain','340domain').replace('is336 tests','is340 tests')
 if name=='STATUS.md':s=s.replace('Latest: responsive','Latest:14audio cue hooks/22definitions, master/UI/combat/mute and silent-safe unbound behavior; responsive')
 else:s=s.replace('PCM, clipping, DC and fades checked','PCM, clipping, DC and fades checked;14runtime cue hooks,16voice cap and master/UI/combat/mute').replace('Listening review, Roblox import, event wiring, volume categories, mute and accessibility checks','Listening review, Roblox import/permissions,8remaining event hooks and audible/device acceptance')
 p.write_text(s,encoding='utf-8')
p=root/'assets/uat01/audio/README.md';s=p.read_text(encoding='utf-8');line='\nRuntime cue hooks and volume/mute controls are now prepared; uploaded IDs remain empty. See [runtime bindings](RUNTIME_BINDINGS.md) for14wired and8unbound cues, validation and limits.\n';p.write_text(s if line in s else s+line,encoding='utf-8')
