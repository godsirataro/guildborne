# Cross-stream integration contract — revision 1

Status: source-backed proposal awaiting stream acknowledgements of this revision. Read with DASHBOARD.md. No new network schema is introduced.

## World and quest navigation

City.Config owns public geometry; TravelService owns actual travel, live player/plot checks, gate proximity and safe landing. City.Destinations keys City/Guild map to CentralCity/PersonalGuild identities; they are not interchangeable strings. MarketDistrict is a GuildPortalStops key; Market is a district. Preserve this distinction. Configured MarketDistrict portal is (300,-1080), return (300,-1068), fallback (300,-1060) in X/Z. Do not derive service prompt positions from concept art.

QuestTracker projects server snapshot state. QuestRoute resolves actual catalog tasks/markers, gate steps, owner-island return and unavailable streamed markers. UI pinning is presentation only. A missing marker does not complete a quest. Canonical IDs, quest receipts, travel prerequisites and existing reward authority are unchanged. S13 must confirm the exact existing Goblin Camp route and service objects before an integrated test.

## Combat and skill presentation

CombatService emits server-owned action attributes: ActionAt, ActionTargetPosition, ActionEffect and ActionAbilityId. Consumers use the existing class/skill namespace and current actor identity. Power Strike is the golden existing ability; its exact runtime ID is resolved from Combat config by S15, never invented from its display name.

ActionTimeline remains presentation-only: duration .62 seconds, release .10, contact .24, recovery .26. Damage and rewards do not wait for or trust a client marker. Accepted casts update authoritative state; rejected cooldown, invalid target or downed casts do not create a successful action presentation. Duplicate observation, interrupted/replaced action, death, removal and late observation must not replay effects. Preserve existing timing unless a separately reviewed server timing migration proves necessary.

Skill UI reads per-actor state, actual points/slots/cooldowns and unavailable reason. Preserve 29 runtime classes/paths, legacy earned Class2 and Novice 10/35/70 progression; the 35-class draft remains DESIGN_ONLY. Cosmetic race is separate from combat ancestry.

## Audio, assets and GUI

AudioConfig.AssetIds is empty. Cue routing can be tested without asserting audible acceptance. No invented asset IDs, paid upload or placeholder sounds. Original source/provenance, imported binding, Studio observation and human listening are separate gates. Retain existing ownership/provenance for every image/model/audio source.

Native GUI uses one MenuRouter focus owner, runtime EN/TH labels, truthful loading/empty/disabled/pending/error states, and actual server snapshot rewards. S14 first fixes the observed Title keyboard-focus gap, then supplies exact HUD/Status/Inventory/Quest scope for review. Visual fallback does not establish final logo acceptance. No broad schema or UI rewrite is authorized by this contract.

## One integrated acceptance scenario

Build the same reviewed combined source in an isolated PlaceId=0/GameId=0 Memory candidate with empty DataStore allowlist. Record source/build hashes and all fixture setup separately. Start through actual Title, switch EN/TH, verify focus and Continue. Read/pin an available real quest, use native navigation to city service anchors, traverse Plaza/Tavern/Forge/Market and MarketDistrict portal to owned island, then existing Goblin Camp. Verify player plus up to five actual followers traverse without recovery teleports, death or fall; any seeded roster is explicitly a fixture, not earned recruitment.

Use existing Power Strike through actual input. Observe one accepted action, server HP/cooldown result and bounded presentation; attempt a cooldown rejection and confirm no new successful action. Observe actual server-earned quest/reward delta in UI only if the selected scenario legitimately produces it; never grant value merely to make screenshots pass. Exercise interruption/death/removal and cleanup. Capture Output, screenshots and expected/actual values, then stop only the owned Play session. Device, live cross-server, save/rejoin and human art/feel acceptance remain separate.

Both affected owners must acknowledge this exact revision (and its committed file hash) or return concrete corrections before changes cross their boundary.
