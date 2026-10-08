# Phase 0 validation evidence

Historical report: the results below describe the 2026-09-27 scaffold only. Phase 1 replaced its bootstraps with implemented gameplay. Use [current implementation evidence](PHASE1_IMPLEMENTATION.md), `.\tools\validate.ps1`, and the [Studio checklist](PHASE1_STUDIO_TEST.md) for the current project.

Date: 2026-09-27. Scope: documentation and bootstrap scaffold only.

## Environment inspection

The workspace was empty and had no Git repository or applicable ancestor AGENTS.md. Git 2.46.2, Python 3.14.0, and Node 24.19.0 were available. Roblox Studio was located under the user's local Roblox installation. Rojo, Luau CLI, Selene, StyLua, Rokit, and Aftman were not on PATH. Initialized Git on `main`; no remote, commit, or published experience was created.

For local verification, downloaded official Rojo 7.7.0 and Luau 0.740 Windows binaries into ignored `.tools/`. These do not change the global PATH or install a Studio plugin. Generated build outputs belong to ignored `build/`.

## Checks

All executed checks below passed:

| Check | Result |
| --- | --- |
| Repository validation | 11 design/evidence documents, JSON/TOML parsing, Rojo paths, 30 local links, one JSON schema example, two strict Luau sources |
| Rojo 7.7.0 build | Generated `build/Guildborne.rbxlx` successfully |
| Rojo source map | Generated and parsed `build/sourcemap.json` successfully |
| Built-place inspection | Exactly one Script at ServerScriptService/Server/ServerBootstrap and one LocalScript at StarterPlayer/StarterPlayerScripts/Client/ClientBootstrap; no ModuleScripts or remotes |
| Luau 0.740 analysis | Both bootstrap files passed with no diagnostics |
| Luau 0.740 compilation | Both bootstrap files compiled successfully |
| Metadata/placeholders | Git metadata files and .gitkeep files decoded as UTF-8 |
| Whitespace | `git diff --check` passed after marking new files intent-to-add; no commit created |
| Design consistency review | Checked slice counts/budget, authority boundaries, transfer failure states, fee rounding, schema ownership, roadmap gates, and absent forbidden implementations |

The reproducible commands are:

```powershell
python tools/validate_repository.py
.\.tools\rojo\rojo.exe build default.project.json --output build/Guildborne.rbxlx
.\.tools\rojo\rojo.exe sourcemap default.project.json --output build/sourcemap.json
.\.tools\luau\luau-analyze.exe src/server/ServerBootstrap.server.luau src/client/ClientBootstrap.client.luau
.\.tools\luau\luau-compile.exe --null src/server/ServerBootstrap.server.luau src/client/ClientBootstrap.client.luau
git diff --check
```

For a fresh checkout with new untracked files, `git add --intent-to-add .` makes them visible to the whitespace check without staging their contents. Compilation and a Rojo build do not prove gameplay, persistence, mobile UX, or Studio execution. External documentation was researched, but the validator does not test external link availability or render Markdown diagrams.

## Studio checks still required

1. Connect matching Rojo plugin to a new local test place and inspect mapped services.
2. Start a Play session. Confirm one server readiness message and one client readiness message in their respective Output contexts.
3. Confirm no critical errors attributable to the two scripts and no generated remotes or gameplay services.

Studio is installed, but these interactive runtime checks have not been executed in this task. No published staging universe was provided. Save/load, malicious request, mobile UI, economic simulation, and cross-server tests are future phase gates, not tests that the Phase 0 scaffold can pass.

## Scope review

All nine requested documents plus a research register and this evidence report are present. Runtime code is exactly two print-only Luau bootstraps. Reserved directories contain .gitkeep files excluded by Rojo. No gameplay, persistence adapter, RemoteEvent, marketplace, war, monetization, or future settlement implementation has been introduced.

Known unresolved risks are documented in [roadmap](ROADMAP.md) and [architecture](ARCHITECTURE.md): profile/session correctness, native market throughput, safe receipt compaction, thin-market manipulation, mobile/war performance, staging configuration, and audit retention. Phase 1 is not authorized by completion of this report.
