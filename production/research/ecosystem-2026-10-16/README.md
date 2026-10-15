# Ecosystem adaptation observations — 2026-10-16

Scope: tooling and workflow adaptation from the user's NEONSHIFT document. This is
a local working-tree report, not a signed Forge acceptance packet or game approval.
Existing city-landscape edits were outside this task's authorship and test scope.

## Sources inspected

- User attachment: `Pasted text.txt`, title NEONSHIFT AI Development Ecosystem,
  attached in this chat. SHA-256 is recorded in `observations.json`; the document
  is not redistributed here.
- https://create.roblox.com/docs/studio/mcp
- https://github.com/Roblox/roblox-studio-agent-plugin
- https://github.com/TabooHarmony/roblox-brain
- https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1
- https://create.roblox.com/docs/reference/engine/classes/StudioTestService

## Observed host state

The following is a summary of tool results observed during this conversation,
not a byte-for-byte raw MCP transcript:

- Studio `list_roblox_studios` returned one instance with ID
  `1e078f2a-71bd-4c20-bc35-7a41b7bbb4d4` and `name: null`, without a tool error.
  Discovery succeeded; the game/target identity was not verified and no game
  mutation was performed by this adaptation.
- Blender `get_addon_status` returned `source: error`, null addon/protocol/Blender
  versions, empty capabilities and warning: `Addon handshake failed: Connection
  to Blender lost: [WinError 10054] An existing connection was forcibly closed by
  the remote host`. Expected protocol was 13. Its `up_to_date: false` does not
  establish an installed outdated version when the handshake cannot read it.
  No addon update, generator call or scene mutation was attempted.
- `.tools/rojo/rojo.exe --version` executed and returned `Rojo 7.7.0`.
- The common Windows Blender 5.2 executable was found on disk. Existence is not
  a fresh Blender execution or proof that its addon is connected.
- Host discovery found 29 `roblox-*` skill directories. The router selects a
  bounded subset relevant to a task; the doctor reports only skills used by the
  manifest. No new skill pack or runtime dependency was installed.

`doctor.json` records fresh filesystem inventory and hashes; `route-*.json` are
read-only planning results. `checks.json` records command exit codes; matching
stdout/stderr logs preserve captured local output. An empty stream is intentional.
These checks neither exercise gameplay nor replace `tools/validate.ps1`, Studio,
physical devices, distinct servers or human acceptance. See `review.md` for the
separate reviewer disposition when present.

The first complete production-tool run found a stale 39-task count assertion.
Its original output remains intact. `recheck.json` and the `after-fix` logs record
the full rerun after replacing that assertion with required task identities and
the existing dependency validation. Read the rerun result when assessing current
local test status.

Final local result: 195 production-tool tests ran, 189 passed and 6 were skipped
for unavailable Windows symlink privileges; no failures. Forge/Studio/ecosystem
metadata validation, verification of 98 generated adapters and Python compilation
also passed. Independent review passed including the stale-test repair. These are
local results; the updated GitHub Actions workflow has not been run remotely here.
