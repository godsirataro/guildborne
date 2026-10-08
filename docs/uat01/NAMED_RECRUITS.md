# Fifteen named Tavern recruits

The owned memory-only build now scouts from three original named recruits per root class, using the fifteen existing visual templates. Rank odds, equal class odds, base class stats and hiring prices are unchanged. Within the selected class, each of its three templates is equally likely. The selected template ID is committed with the offer and copied to the hired hero. Name, UI and native appearance use that identity.

| Class | Template 01 | Template 02 | Template 03 |
| --- | --- | --- | --- |
| Warrior | Rowan | Kira | Toren |
| Knight | Bram | Elian | Vera |
| Archer | Ash | Neris | Fenn |
| Mage | Lyra | Orin | Selene |
| Priest | Sage | Iona | Corin |

The optional fields preserve legacy offers and actors without assigning them new identities. Legacy appearance hashing remains the fallback. Schema validation rejects unknown or class-mismatched templates and mismatched bound names. Disabling new template scouting does not invalidate already committed template identities. This is an optional schema-7 extension, not the Novice/v2 migration.

All462 domain tests pass, including all15 scout/hire identities, class-stat and weapon preservation, ordinary-build legacy behavior, before/after-write uncertainty, replay and rejoin. Native15 visual models and116 EN/TH candidate views passed. Full strict analysis, compilation, repository and both builds passed at194runtime modules.

Actual fresh offline UI earned70Gold, scouted Vera/Knight/E/knight_03 at revision8/50Gold, hired her for40Gold and added her to the party. Revision10 had10Gold, Rowan plus Vera following, an equipped Knight Sword, persisted templateId knight_03, native VisualTemplateId knight_03 and bilingual world label Vera/เวรา. This actual case differs from the old h:1 hash fallback, which selects variant01.

Earned tickets, weekly rotation, 1/10 recruitment, v2 progression gates, production import and device/multiplayer/human UAT remain open. Default ordinary runtime scouting remains legacy; only the owned offline bootstrap enables named templates.
