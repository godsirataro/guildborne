# Guildborne standalone art review

Open `build/Guildborne_ArtReview.rbxlx` as a separate local Roblox Studio place and press Play. This dedicated project contains a walkable gallery with15hero visuals,30item models and8cosmetic prototypes. Three pads lead to Greenwood, Ironveil and Ashen blockouts; five more lead to furnished city room cutaways. Each destination has a return pad. Each island also has an18-second synthetic combat demo near its boss platform.

Added2026-10-03: the Six city landmarks pad leads to a separate plaza with six192-part city prototypes and a return pad. These are architecture assets, not six finished cities. The review dependency allowlist now includes the navigation/locomotion modules used by the encounter preview and excludes unrelated review helpers.

Demo targets are neutral gray training echoes. Regional enemies attack those synthetic records, not player characters. Bosses start at half health to demonstrate both warning patterns. The file deliberately has no main-game bootstrap, data stores, purchases, reward writes or networking endpoints. Its travel prompts validate server distance and cooldown. Falling returns the player to the gallery. This is an art/combat review tool, not a finished Alpha or a replacement for the main game.

Build with `python tools/build_review_project.py`, then `.tools/rojo/rojo.exe build art-review.project.json --output build/Guildborne_ArtReview.rbxlx`. Verify with `python tools/verify_review_build.py`. Default game builds continue to use `default.project.json` and do not include this directory.

Verified: strict review-source analysis; built artifact dependency/persistence boundaries; latest isolated Studio construction1544parts/19travel-demo prompts, all16travel destinations have floors. Three demo lifecycles produced92synthetic damage events in this fixture;18-second cleanup, restart and repeated Destroy passed. No player/profile state was passed to the world-builder test. Opening the standalone file and playing its complete join/travel flow in a fresh Studio instance remains an acceptance step.
