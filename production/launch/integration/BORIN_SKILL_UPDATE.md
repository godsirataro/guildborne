# Borin normal route and Berserker art — 2026-10-14

Continues the same single-client Memory session and candidate `55404c199438de6138cf0fee877151c9bc3c422e88a1f1c57e3ba2cf06e08a17`, Place0/Game0, `Guildborne_IntegrationPreview.rbxlx`. No runtime source changed in this increment. No publish, upload, paid service or production data write.

## Normal gameplay outcomes

- Learned Vitality and Path Art through Skills and equipped Berserker Art (`cleave`). A real keyboard Z cast against Forest Captain recorded ActionAbilityId=cleave, ActionEffect=Area, ActionRange8, Skill2Cooldown8 and player AbilityCount4→5/DamageDealt301→372. The earlier scout attempt did not establish a player cast: the target was initially out of range and companions killed it. Only the boss observation is used as cast evidence. This does not establish listening, imported animation quality, all cancel/respawn cases or full-party readability.
- Accepted and completed the existing Journal prerequisites separately: city_gate via City→Guild portal; stonework through three new gather actions; forge_foundation by placing a Blacksmith through native Build mode at6,-4; first_ingot by crafting after acceptance. Gathered the required resources with real hold input and cooldowns. No grants, profile edits or time skipping.
- At Borin, accepted borin_castings with two ingots already owned. Progress remained0. Returned through the city market portal to Guild and crafted two new ingots via native Base UI: progress0→1→2, inventory2→3→4. Returned to Smith Borin and claimed through his dialogue/Journal. Gold263→275; all four ingots retained; state Claimed.
- Used the normal Deepforge portal after the claim. CurrentZone became Deepforge and player arrived at800,2.998,-3892. Returned through its City portal normally.

## Separate negative network probe

After the normal route and combat test, at Borin, sent an already-claimed ClaimTask twice with one request ID and then once with a different ID. This is explicitly protocol testing, not ordinary UI route evidence. Before/after revision153, Gold296 and ingots4 were unchanged. Full final response returned code QuestNotActive. The increase275→296 occurred during subsequent combat rewards, not a duplicate Borin claim. Review the preserved console/transaction checkpoints for the distinction.

## Evidence and checks

Independent reviewer launch_progression confirmed build identity, Borin accounting, repeat rejection and cast evidence. A missing pre-cast checkpoint was supplied from the existing tool result in a separate file; earlier streams remain unchanged. This is scoped local acceptance only.

- `borin-route-raw.json`: before/accept/two crafts/claim/Deepforge checkpoints.
- `berserker-combat-raw.json`: player cast attributes and limitations. `berserker-precast-raw.json` preserves the earlier scout observation with player counters4/301 before the later boss cast5/372; no earlier raw stream was modified.
- `borin-repeat-probe-raw.json`: repeat probe before/after and response summaries; `borin-repeat-full-response.json`: separate complete response including QuestNotActive.
- `borin-skill-console-raw.json`: returned console stream, preserved before the final alternate-ID probe.
- Studio v3 validate/verify and Forge validate/doctor/plan rerun. Candidate hash unchanged. Prior736-test source baseline is retained; no new736-test run is claimed for this gameplay-only increment.

Still pending: hero-owned Class2 mentor contract, other player class branches, persistent rejoin, multiplayer/cross-server, actual devices, runtime presets/fit/audio, commerce/season lifecycle and human UAT. The local game remains in Play for the user; Stop resets Memory progress. PublicReady=false.
