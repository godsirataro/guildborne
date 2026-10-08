# Phase 4 Studio verification — 2026-09-29

**Studio Definition of Done: met for the bounded pilot. True cross-server live trading: NOT YET VERIFIED.** No publication occurred. Place 86788611613035, universe 10768425213. Real Studio multiplayer sessions used temporary Memory persistence and fresh test users, avoiding existing staging saves. Production cloud configuration is restored in the final source sync. API access settings were not changed.

## Executed checks

The original 136-test baseline passed before changes. Final suite: 210 tests (136 existing + 74 market), strict Roblox-aware analysis, compilation, Rojo build and repository checks. See [final validation log](evidence/phase4-validation.txt). Three pre-existing lint warnings remain in ExpansionView, InventoryView and SettlementView; there are no analysis errors. The market tests instantiate independent service workers with shared deterministic adapters and real PlayerDataService; they are not native independent Roblox servers.

Two actual clients completed quests, recruited five companions each and equipped earned gear. Seller listed five ore at 10; buyer took two at 10. Seller collected 19 Gold, retained three in escrow, then cancelled twice and received those three exactly once. Final seller wallet 69/ore 4; buyer wallet 30/ore 8. Initial 100 Gold =99 wallets +1 fee; 12 ore conserved. See [two-client observations](evidence/phase4-two-client.json) and [Output](evidence/phase4-two-output.txt).

Four actual clients each earned 50 Gold and six ore using existing quests, recruited five companions and entered the city through validated travel. Sell orders at 9 and 10 matched in price order across two buyers. Both buy and sell immediate orders, limit buy/sell, partial fills, cumulative rounding, settlement and repeated cancel/refund ran through the public Market remote. The checkpoint was 194 wallet Gold +6 fees =200 starting Gold, and 24 ore conserved. See [raw clients](evidence/phase4-four-client.json) and [explicit reconciliation](evidence/phase4-native-conservation.json). Subsequent screenshot orders were cancelled; a later real trade supplied materials for the Hall upgrade and is intentionally outside that checkpoint.

All four users retained independent profiles and five companions (20 total). After market activity, one player upgraded Guild Hall to level two through the existing command, consuming the configured 80 Gold and materials. A 600-sample native combat observation recorded all five classes using basic attacks/abilities, damage, healing, taunt, downed states, five enemy deaths and five saved rewards. Existing equipment, quest and travel paths also succeeded. See [combat/performance](evidence/phase4-combat-performance.json) and [final server Output](evidence/phase4-final-output.txt). The Output tool truncates old log prefixes; this is not a claim of a complete lifetime log.

Actual cloud smoke used isolated `smoke4_1790655522`: production MarketCloud DataStore write and uncached read through another adapter, MemoryStore depth read, explicit two-second TTL expiry, deletion/rebuild, and one observed MessagingService notification. Passed in 13.95 seconds, no adapter failures, four projection writes and two notifications. See [cloud smoke](evidence/phase4-cloud-smoke.json). A separate `p4fill_*` smoke executes real-cloud prepare/deposit/match/replay/repeated cancel and second-adapter read; [result](evidence/phase4-cloud-fill.json). Neither test writes a player profile or constitutes independent live-server trading.

## Interaction and performance methods

Desktop MCP mouse input opened item detail, buy/sell entry, review confirmation and navigation. The actual Exchange R prompt opened the market. Transaction automation uses the QA-only `tests/studio_market_probe.luau` helper to send the same public remotes as the UI; it does not grant Gold/items or bypass server rules. Positioning near valid portals/camp/Exchange was assisted with server PivotTo for repeatability. The four-client image uses an inspection camera. Probe code is outside the runtime build.

Native TextBox assignment with CaptureFocus/ReleaseFocus tested English `iron` and Thai `แร่เหล็ก` filtering after synthetic keyboard focus proved unreliable. Mobile MCP mouse/gamepad activation did not reliably trigger buttons, so mobile evidence certifies rendering/layout only. Device simulator iPhone 17 Pro portrait and landscape were inspected in EN/TH with safe-area scrolling and large controls. **Physical touch, virtual keyboard and real-device performance remain pre-release requirements.** A UTF-8 corruption in the final UI polish was found and repaired, then the corrected module was loaded and visually rechecked.

Four-client server Heartbeat sample: 180 frames, mean 16.67 ms, p95 18.04 ms, maximum 19.92 ms, 3,578 BaseParts. One actual Memory-adapter Market Read round trip measured 32.38 ms. These are small Studio observations, not market-only CPU cost, low-end-phone FPS or production capacity. The UI has no constant polling loop. Recovery rotates books every 30 seconds; cache invalidation coalesces for two seconds, read TTL is ten seconds. Adapter metrics count cloud attempts. Full cloud request/latency saturation remains a private-server acceptance gate.

Server Output was inspected after native flows and showed successful profile commits, market transfer events, Hall upgrade and combat rewards without a game runtime exception. QA command errors included an incorrect prompt path, synthetic-input assertions, a wrong device-service name and a TravelZone probe with the wrong payload key; corrected probes were rerun. The first additional cloud-fill probe omitted the Orders factory's Util dependency and failed before writing a book. The corrected probe passed; the final adapter also now rejects a nil UpdateAsync result explicitly and was cloud-tested again (namespace p4fill_1790656942: seven writes, one trade, four claims, one fee, 1,790 serialized bytes, zero profile writes/failures). These were test-command errors, not hidden passing tests. Client module reloads were temporary QA artifacts and disappear when multiplayer stops.

Cleanup completed: multiplayer ended, device simulation stopped, Studio returned to its default viewport/Edit mode. [Source verification](evidence/phase4-source-sync.json) confirms all 81 scripts exactly synced from disk, DataStore staging restored and temporary bootstrap observer removed. No Studio API setting was changed. The generated Rojo place also contains the final sources.

## Screenshot index

| Required view | Native evidence |
| --- | --- |
| Exchange exterior; two-client session after trading | [Exterior](evidence/phase4-exterior.jpg), with two-client JSON above (avatars overlap; image alone does not prove balances) |
| Browse | [Browse](evidence/phase4-browse.jpg) |
| Item detail | [Detail](evidence/phase4-detail.jpg) |
| Order book | [Two-sided depth](evidence/phase4-order-book.jpg) |
| Price history | [Final chart](evidence/phase4-chart.jpg) |
| Buy confirmation | [Buy review](evidence/phase4-buy-confirmation.jpg) |
| Sell confirmation | [Sell review](evidence/phase4-sell-confirmation.jpg) |
| My Orders; partial fill | [Original 5 / filled 4 / remaining 1](evidence/phase4-partial-orders.jpg) |
| Completed transaction/history | [Own history](evidence/phase4-history.jpg) |
| Thai market/search | [Thai search](evidence/phase4-thai-search.jpg) |
| Mobile English | [English portrait](evidence/phase4-english-mobile.jpg) |
| Mobile Thai | [Thai portrait](evidence/phase4-thai-mobile.jpg), [landscape](evidence/phase4-thai-landscape.jpg) |
| Four-client market session | [Four players at Exchange](evidence/phase4-four-players.jpg), server asserted four players / twenty hero models |

Screenshots depict real runtime states at different checkpoints; orders/history naturally change between them. Earlier screenshots precede the final English status wording/axis polish. The native transaction JSON is the accounting evidence. [Private-server acceptance](PHASE4_PRIVATE_SERVER_ACCEPTANCE.md) specifies the remaining independent JobId, offline rejoin, crash, throttling, physical-device and retention gates.
