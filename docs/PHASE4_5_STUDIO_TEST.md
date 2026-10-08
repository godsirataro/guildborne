# Phase 4.5 Studio verification

Final cleanup: all multiplayer sessions stopped, device simulation stopped, and all 86 runtime sources restored and verified against disk with default settings. [Exact source sync evidence](evidence/phase45-source-sync.json). The final automated validation passed all 271 tests, strict analysis, build and repository checks; see [validation log](evidence/phase45-validation.txt).

Date: 2026-09-29. Staging place 86788611613035 / universe 10768425213. Default sources use DataStore staging. Native destructive tests used temporary Studio Memory mode and ReplaySeconds=0 (production remains 300, separately unit-tested). No normal staging player saves were reset. No publication or API-setting change occurred.

## Executed native four-client flow

Four actual clients independently completed the three existing quests, recruited five classes and equipped earned gear. Each began trading with 50 Gold / 6 Iron Ore; four clients and twenty owner-tagged followers were counted. Public remotes, not direct inventory grants, performed all player transactions. Test positioning used server PivotTo before validated travel/encounter commands. This is assisted repeatable QA, not a claim of manually walking every route.

Player -3 sold five at 10. Player -2 bought two with a 12 maximum: spent 20, received two, seller collected 19, three remained. Two-participant [audit evidence](evidence/phase45-two-participant.json) reported zero violations. Player -4 then bought two at 10; Player -1 sold two at 9 and Player -2 bought one. Closing cancelled the remaining one from each seller. Reconcile returned RecoveryPending with four pending claims; it did not archive prematurely. After all owners collected: wallets **58 + 21 + 88 + 30 =197**, fees **3**, ore **5 + 9 + 2 + 8 =24**. No external faucet/sink occurred during that checkpoint.

[Closure](evidence/phase45-closing.json) and [archive](evidence/phase45-archive.json) show validated transitions and zero audit violations. Epoch 2 started, accepted a new one-Gold buy order, and repeated cancellation returned exactly one Gold. Five traded units/49 gross remained in the archived candle projection. [Final four-client audit](evidence/phase45-four-final.json) again passed. Local server JobId was empty: this is NOT true cross-server acceptance.

READ_ONLY rejected a new order with MarketReadOnly and displayed a clear banner. PAUSED preserved market data while travel to Guild, inventory snapshot, language/profile commits and actual combat rewards continued. The original combat probe initially failed its ownership assertion for the equipped Warrior; inspection confirmed automatic client ownership following gear weld changes. HeroService now reasserts server ownership after equipment/outfit synchronization. The initial diagnostic observation is retained in [combat/performance](evidence/phase45-combat-performance.json); it is not represented as a passing ownership test. A fresh two-client build reran the original ownership-asserting probe after this fix: all 600 samples completed, all five classes attacked/used abilities, healing/taunt/downed states were observed and nine rewards saved.

## Fresh two-client regression

A separate two-client session loaded the updated sources and fresh Memory profiles. Five ore listed at 10, two bought with maximum 12, proceeds collected, remainder cancelled twice. Seller ended with 69 Gold/4 ore, buyer 30 Gold/8 ore: **99 wallets +1 fee =100**, **12 ore conserved**, zero audit violations. [Final two-client evidence](evidence/phase45-two-final.json) records the operator result. Market was then paused for the original combat/ownership probe; the final result is in [two-client combat](evidence/phase45-two-combat.json).

## Cloud, input and performance

Actual isolated cloud probe [result](evidence/phase45-cloud.json): fourteen writes and a second adapter read, single match, pending-claim close, reconciliation/archive/new generation, stale generation rejection, retained 30D candle, MemoryStore removal/rebuild/TTL expiry and missed-message reader refresh. Two actual notifications were observed on a separate subscriber. This uses synthetic book fixtures with explicit acknowledgments and zero profile writes; native player-profile settlement is separate evidence. See [load/chaos methods](PHASE4_5_LOAD_TEST.md).

Desktop MCP mouse input opened material detail after scrolling it into view; server public remotes drove transaction automation via the QA-only helper. UI mode banners and archived chart were inspected natively. A stale device simulation initially made clicking unreliable; stopping simulation restored normal desktop input. The new phase does not certify physical mobile touch. Four-client Heartbeat: 180 samples, mean 16.66 ms / p95 18.10 ms / max 20.10 ms. No cloud capacity certification is claimed.

Test-command failures were retained and corrected: missing optional multiplayer argument, early first-client command timeout (fresh setup retried), and the equipped-hero ownership assertion described above. Server Output shows market/profile commits, operator transitions and cloud evidence; the tool truncates old prefixes. [Four-client Output](evidence/phase45-four-output.txt) includes the discovered ownership failure rather than concealing it. Final fresh-session Output is recorded separately after the fix.

## Visual/structured evidence

- [Temporary QA operator snapshot](evidence/phase45-operator.jpg) (values captured from the server-only API; this panel is not shipped)
- [Fresh two-client rollover](evidence/phase45-two-rollover.json)
- [Read-only banner](evidence/phase45-readonly.jpg)
- [Four actual players and twenty followers at Exchange](evidence/phase45-four-players.jpg)
- [Archived price chart in the next generation](evidence/phase45-chart.jpg) (pictured 1D; 30D also asserted in native cloud/unit tests)
- [Closing/refund reconciliation](evidence/phase45-closing.json)
- [Archive completed](evidence/phase45-archive.json)
- [Current epoch, health and audit](evidence/phase45-four-final.json)
- [Baseline](evidence/phase45-baseline.txt), [synthetic soak](evidence/phase45-soak.txt)

Final automated validation is [recorded here](evidence/phase45-validation.txt). Rate-limit rejection now sends a bounded MarketBusy response so the UI cannot remain stuck waiting for a silently dropped request. The private acceptance builder was build-tested both normally and with messaging deliberately disabled; no artifact was published.

TRUE CROSS-SERVER LIVE ACCEPTANCE: **PENDING PRIVATE PUBLISH / PLATFORM ACCEPTANCE**. PHYSICAL DEVICE: **PENDING**. Public market remains disabled. [Private runbook](PHASE4_PRIVATE_SERVER_ACCEPTANCE.md) and [device checklist](PHASE4_5_MOBILE_DEVICE_ACCEPTANCE.md) define the outstanding evidence.
