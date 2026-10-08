# Approved progression and identity contract

This records the user's latest design instruction. It is not a claim that every rule already exists in source. Audit source and migrations before changing runtime behavior; older phase docs remain historical.

| Rule | Target |
|---|---|
| Player | Novice Lv1; choose Class1 at10 after quest |
| Class2 | Level35 plus appropriate class quest |
| Class3 | Level70 plus appropriate class quest |
| Class4 | None |
| Maximum level |100, player and heroes |
| Newly recruited hero |Always starts at10 with Class1 |
| Recruitment unlock |Player Class1 AND main story Personal Guild Hall |
| Companions |At most5, additional to player |
| Hall cap |For Hall>=1: min(100,20+5*(Hall-1)) |
| Hall milestone |Hall1->20, Hall2->25, Hall4->35, Hall11->70, Hall17->100 |
| Hall18-20 |No extra levels; approved non-level utility/visual goals |
| Race |Human, Elf, Orc, Dwarf; Wizard is Human appearance |

No circular prerequisites: a solo Novice/class candidate can unlock the first Hall before recruiting; Hall4 permit must be achievable before level35, and Hall11 before70. Main progress cannot require live market access, paid random recruitment or a mandatory multiplayer guild.

Skill tree and status points are per actor. Class change resets allocation/refunds previously earned budget; it does not grant the same total again. The proposed draft formulas SP=(L-1), status=3*(L-1) imply9/27 at10 and99/297 at100; these are balance proposals pending reconciliation, not an order to overwrite tuned data. Learned/equipped/AI-enabled states differ. Branch exclusivity and capstones need explicit prereqs and budget checks. Hero class quest uses the hero's own level.

Migration must not lower previously earned level, remove a class unlocked under the earlier level30 rule, delete a hero, reset marketplace claims, or duplicate refunds. Preserve old quest IDs/claim receipts and active expedition snapshots. Additive versioned migration with old-save fixtures and replay tests precedes any adoption.

Class paths from the narrative design are planned content; keep currently implemented IDs and compatibility until a reviewed mapping exists. No race/body/stat bias accidentally introduced through visual size or clothing fit.
