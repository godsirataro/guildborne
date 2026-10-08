# Borga and Rukk actual offline quest journeys — 2026-10-03

The existing memory-only Studio session continued from the verified Vera hire at revision10/10Gold. Actual mouse clicks accepted and claimed quests; actual keyboard E used city/region portals and resource prompts. Movement-only Character:PivotTo shortcuts reduced walking time. No tool wrote profile fields, granted items/currency, reset cooldowns or directly fired gameplay remotes. This validates interaction and accounting, not walking-route usability.

Borga's A Hearth for Everyone consumed4of the6earned Timber and paid8Gold. Timber Beyond the Harbour recorded two actual Greenwood timber gathers, paid8Gold and retained the4gathered Timber. A Hearth That Endures recorded two Ashen stone gathers, paid8Gold and retained4Stone. All three were Claimed at revision24/34Gold.

For Rukk, the player first completed A Guild of Your Own through the actual guild portal, gathered stone three times for A Lasting Foundation, collected ore twice and used the real Base preview/Place controls to build a Blacksmith. Construction consumed6Timber,8Stone and4Ore. Light the Forge then completed from the owned building. Rukk's Apprentice's First Shield consumed the earned Iron Ingot, followed by two Ironveil stone gathers and two Ironveil ore gathers for his two regional jobs. All three Rukk quests and three prerequisites were Claimed at revision51/104Gold. Final stacks:6Stone,2Herbs,4Iron Ore.

The six Borga/Rukk quests paid52Gold; the three City Herald prerequisites paid42Gold, reconciling the10Gold start to104Gold. Borga's item delivery consumed4Timber; Rukk's consumed1Ingot. Regional collection rewards retained their gathered materials as described. Combined with the earlier Mogra three-quest journey, all six regional supply quests now have actual offline interaction evidence across separate sessions.

Evidence: validation-orc-supply-borga-rukk-live.json. Runtime domain checkpoint remains462tests. No persistence/reconnect, real multiplayer, physical device, final balancing or human UAT is claimed.

The journey exposed raw English crafting error codes in disabled recipe buttons. ExpansionView now uses existing localized player-facing sentences for missing Forge and missing materials. Four isolated native UI cases verified both reasons in English and Thai with crafting disabled and no profile actions. This copy fix changes neither recipe gates nor server behavior.
