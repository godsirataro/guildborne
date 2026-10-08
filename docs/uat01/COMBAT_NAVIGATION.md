# Combat objective directions

An active unfinished regional combat quest now points to its region gate from the city, then to the encounter's spawn area inside the correct region. From another region it first points to the return portal. Completed objectives point back to Ghar. Arrival at an enemy area displays an attack-warning reminder instead of an interaction instruction.

The field guide projects each encounter's existing reward event and marker name. The client resolves that marker from loaded world geometry, avoiding a second coordinate catalog. Missing streamed markers yield no direction temporarily; the selected quest remains and resolves on a later update. These are spawn-area directions, not live enemy tracking or an automatic safe walking path. Combat-disabled catalogs do not enable these routes.

All456 domain tests pass, including six contracts across city/correct/wrong regions, ready and available states, disabled combat, absent geometry and immutable input. Native read-only checks matched all12 projected marker names to actual map geometry and verified all6 routes with isolated quest states. No player progress was granted. A new real-client combat-quest journey with these directions, physical devices and multiplayer remain unverified.
