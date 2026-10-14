# Release availability and Novice continuation — 2026-10-14

This increment continues the approved launch plan. Public readiness remains false.

## Implemented

- ViewProjection derives task and tower restrictions from the existing authoritative release policy, plus per-actor advancement refusal codes. Complete historical catalogs and saved data remain intact.
- Journal disables new tasks outside the launch boundary with a Thai/English explanation. Existing Active/Claimed entries retain progress and earned turn-ins.
- NPC work markers, dialogue fallback and suggested-next quest stop advertising blocked new tasks.
- Class advancement shows the server's distinct player mentor, hero mentor or future-content reason. Existing learned skills and equipment remain readable.
- Tower page removes start/enter actions in the candidate and retains Leave for a previously active run.
- Independent review found a pre-existing Skills crash: the view read `data.settings.language`, while network snapshots contain `data.language`. The view now uses the projected field.

## Evidence and build boundaries

On candidate `548fff321762daac8d3faa0e9315d362da580b60b5ae4de2304c33c0d3276dd8`, normal-speed navigation, keyboard E/F/M/J and mouse UI input completed the first two Novice chapters. The server recorded the courier/path/warning objectives, an actual basic hit in the training arena (120→110 enemy HP, lesson receipt delivered), area dodge and captive rescue. Ordinary UI chapter claims reached **Lv5, claimed2, revision9**. No grant, saved-state edit, direct objective receipt or clock skipping was used.

The Skills language fix produced candidate `4f56b8978cba86f11dcc0cd7f53a5c105bc9f67891911e19ce3e9bf916776e52`;357 script entries were checked in the local Studio and one source changed from the prior candidate. A separate **synthetic UI rendering fixture** consumed the real projected snapshot shape and locally substituted a Warrior solely for rendering; it did not grant a class or mutate a profile. It passed Skills rendering without a settings table, disabled mentor advancement, no tower-start actions and retained tower exit. Script: `availability-ui-probe.luau`.

The normal route was not rerun after the one-line Skills fix; do not label the Lv5 route as evidence for an immutable release revision. New unit tests cover unavailable offers, preservation of earned tasks, no-release compatibility and actor-specific projection. Full local validation is recorded separately in the companion evidence receipt.

UI automation encountered a few probe/target errors while changing panels; these were inspected and corrected. When the management menu was open it correctly blocked trial attacks; closing it using M allowed F to deliver the real hit. These are not evidence of a failed combat receipt or a fully clean console.

## Still pending

World portal/resource labels, Tower world sign, navigation and bestiary release messaging remain follow-ups. The authoritative request gates are unchanged. Next normal route: caravan chapter, keeper, five class lessons, solo class trial, Hall founding and the two main arcs through35. Memory Stop resets the run; persistent staging/rejoin acceptance is still pending.

All broader launch gates remain in `production/LAUNCH_PLAN.md`: hero-owned mentor contract, runtime13 presets/fit/audio, actual Premium commerce/season lifecycle, multiplayer, devices, cloud and human review. No publication, spending, live sales or production data writes occurred.
