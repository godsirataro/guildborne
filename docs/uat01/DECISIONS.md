# Decisions

- Preserve all pre-existing staged/untracked work. Repository has an unborn main branch, so no baseline commit exists. Work branch: codex/uat01-first-playable. Do not treat staged work as this change set or commit it wholesale.
- Source mappings: ReplicatedStorage.Shared from src/shared; ServerScriptService.Server from src/server; StarterPlayerScripts.Client from src/client. Workspace city/plots and art kit are deterministic runtime builders. Leave other Studio hierarchy untouched.
- Title uses committed view status/data and existing SetLanguage command. It never initializes/replaces a profile. Recovery falls through to existing retry controls. No separate economy, camera or persistence manager.
- Reuse Art.UI as the palette authority: navy, ivory, gold and burgundy. Existing MarketView consumes this palette without protocol changes.
- No external dependencies/assets or asset IDs added. No publish, purchases or market gate changes.
