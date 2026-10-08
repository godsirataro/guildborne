# Civic envoys — 2026-10-06

Six representatives now inhabit Central City with rigged portraits, EN/TH dialogue, quest markers and optional one-time community jobs. They introduce the six home cities; this does not represent six completed playable cities.

| Envoy | Home city | Optional task | Prior task |
| --- | --- | --- | --- |
| Marshal Elian | Crownford | Visit your guild island | city_gate |
| Arborist Vaela | Sylvaris | Gather two Greenwood herbs | herb_field |
| Smith Borin | Deepforge | Craft two iron ingots | first_ingot |
| Cartographer Nyra | Astralis | Gather two Ashen stones | herb_field |
| Harbormaster Sela | Crosshaven | Deliver four timber | company_reinforcement |
| Steward Roka | Ironroot | Deliver four herbs for a shared meal | borga_hearth |

Gather/craft tasks retain materials; deliveries consume the specified stack once. Regional tasks retain the existing encounter availability gate. The journal now contains 37 tasks, plus three expedition definitions.

Validation: 666 domain tests pass, including prerequisites, exact rewards, duplicates and twelve uncertain-write/rejoin cases. Strict analysis passes. Native geometry checks verify all six no-jump paths, clear approach volumes and prompt activation range, with 322 rig parts and 90 motors. Normal-input acceptance completed city_gate then elian_charter at revision 9 / 25 Gold. Other five dialogues and locked prerequisite messages were opened through ordinary movement and E, without profile grants or gameplay remote injection.

Actual play found Roka standing on a roof although the adjacent approach path was valid. His final location is (-102,-856); a fresh boot verified ground-level dialogue. Prompt range is now explicitly asserted. NPC journal navigation also competed with scroll restoration; it now uses the same generation-controlled focus mechanism. Fresh Herald input placed the selected card at Y144 in the viewport beginning Y128.

The completed quest run preceded the final Roka placement and journal-focus fix; those two fixes were checked in a separate fresh session. No real persistence, full six-city acceptance or final art approval is claimed. Evidence: [native observations](validation-civic-envoys-native.json), [domain suite](validation-civic-envoys-domain.txt), [strict analysis](validation-civic-envoys-types.txt).
