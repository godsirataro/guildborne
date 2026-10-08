# Shared current-rules XP projection

Content.HallLevelCap and Content:LevelFromXP now provide the same level calculation to timed expeditions, combat rewards, journal rewards, dispatch rewards, Tower rewards, Hall upgrades, profile validation, client view projection and the migration preview. LevelFromXP reads its supplied content object, so copied test/configuration variants cannot accidentally use the original object's XP rate.

The current rules remain 50 total XP per level and Hall level multiplied by five as the cap. Banked XP stays intact; upgrading the Hall recalculates each actor against the new cap. Legacy pre-v5 schema validation keeps its original cap of10. Roster capacity remains a separate rule. No schema version, reward amount, allocation, class choice, saved XP or actor participation policy changes. This is preparation for a reviewed v2 cutover; playable Novice, class trials and new Hall caps remain pending.

455 full domain tests pass, including known XP boundaries, cap/banked-XP behavior, isolated alternate content rates, existing reward producers, replay/recovery, Hall upgrades and migrations. Actual fresh-profile UI reached Trail Watch revision6 (Rowan20XP/level1/30Gold) and Timber Escort revision8 (Rowan50XP/level2/70Gold), with playerXP0 and cap5 preserved. No direct state grants were used.

Evidence: validation-xp-projection-domain.txt and validation-xp-projection-live.json.
