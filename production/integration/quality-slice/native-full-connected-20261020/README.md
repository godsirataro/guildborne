# Full connected Memory preview — bounded startup verification

2026-10-20, root base 6ebb908 plus the full-connected gate/builder/tests committed with this packet.
Candidate SHA256 ee1e72905495abcf62773ce1cd6742fe33591a3309ebd3de0462d7dd02f9f79e.
Studio 09141cc2-7974-47ef-b394-9ac4bf640ff4; Play stopped after collection.
This build uses zero art datasets and is not an art acceptance candidate.

## Observed
- Actual startup used Studio, PlaceId/GameId zero, Memory, empty allowed DataStore universes,
  all six journey flags and FullConnectedWorldCandidate. Launch release remained off.
- 395 expected source checks matched 395 actual sources, with zero source/attribute mismatches.
  Method is normalized UTF8 length/Adler32, not cryptographic live-place identity.
- Server world contained City–Greenwood and Greenwood–Ironveil corridors alongside later regions.
- Actual GetState response exposed 36 campaign chapters, MAIN_01_01 through MAIN_06_06,
  including required level100, with Active StudioMemory and regional combat available.
- Fresh level1 Novice sent one protocol TravelZone(Ashen) admission probe.
  Server returned NoviceJourneyRequired, revision0; before/after character pivot identical.
  This checks one server rejection, not ordinary UI navigation or all admission cases.
- Pure gate tests:32 cases passed;3 incompatible builder-option combinations rejected beforebuild.
  Tests extract the actual gate into a local harness. Full baseline remains pending at packet creation.

## Evidence limits
fullStateInitial.json preserves the first incomplete catalog query (wrong Order field).
fullChapterCatalog.json is the corrected actual replicated chapter catalog.
fullStartup.json includes a standalone Config.Content require whose flags differ from bootstrap's
configured runtime; do not use those standalone flags as evidence of actual server content availability.
The actual GetState catalog provides the runtime evidence above.
Console retains FoundationProvider warnings and asset203785492 type mismatch.
No XP, class, heroes, items or travel entitlement were granted. No DataStore calls or publication.
No earned Lv100 journey, five-hero road test, tower victory, Class3 proof, physical-device,
cross-server or human art acceptance is established. Only two continuous road pairs exist;
the six civic cities remain portal connected and regional monster level coverage is unfinished.
Existing normal walking/session/release/novice/private-arena checks remain in force.
Class3ProofCandidate remains off. Legacy release/default Runtime files are unchanged.
