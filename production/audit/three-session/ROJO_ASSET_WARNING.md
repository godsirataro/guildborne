# Asset203785492 warning attribution — 2026-10-17

Read-only independent audit identified installed Rojo plugin, not Guildborne source or Roblox Core UI, as the exact request owner. C:/Users/godsi/AppData/Local/Roblox/Plugins/RojoManagedPlugin.rbxm SHA256 de8cac278030b37f7d4f7efb931fe68087be0a851a31c33312f592b802a23714 was decoded in memory with chunk lengths validated. It contains Sounds.Notification=rbxassetid://203785492, gatherAssetUrlsRecursive and ContentProvider:PreloadAsync(contentUrls). No ID match in project src/tools/tests or generated source/places. Project AudioConfig bindings remain empty.

Upstream corroboration: https://github.com/rojo-rbx/rojo/issues/1342 and https://github.com/rojo-rbx/rojo/pull/1344. Raw audio ID preload is treated as an image; fix uses temporary Sound instances carrying the same SoundId, then destroys them. PR1344 was open/unreleased at inspection. This is not an installed fix and no plugin files were changed.

No guessed replacement ID or game asset edit is appropriate. Plugin-disable comparison in a disposable Studio could further isolate the log, but has NOT been performed. Separate CorePackages FoundationProvider warnings remain separate. Existing startup evidence must retain original warnings. Native Fireball image binding is unrelated; no sound playback acceptance follows from this attribution.
