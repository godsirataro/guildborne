# Primary-source research and adoption ledger

Reviewed for this change: **2026-10-09**. Public docs verify capabilities, not this repo's implementation. Research report pasted in the conversation was planning input, not an independent code audit. Existing source was separately inspected through GitHub at commit `efd853d18578f7225e90c2d9f52f9e9ed755bc7e`.

| Topic | Primary source | Decision and limits |
|---|---|---|
| Codex skills | [OpenAI build skills](https://developers.openai.com/codex/skills/) | Repository `.agents/skills`; SKILL.md name/description; progressive loading. Do not infer installed models/tool availability from branding. |
| Portable skill format | [Agent Skills specification](https://agentskills.io/specification) | Lowercase hyphenated directory/name, scoped instructions. Skills specify workflows; they do not grant tools or enforce a sandbox. |
| Studio MCP | [Roblox MCP](https://create.roblox.com/docs/studio/mcp) | Official Studio server, trusted stdio client, session identification and current tool discovery. Do not invent generation/playtest APIs absent from the connection. |
| Coding workflow | [Roblox coding harness](https://create.roblox.com/docs/ai/coding-harness) | Repo/source synchronization plus Studio verification; keep existing Rojo workflow. |
| Native UI | [Roblox UI styling](https://create.roblox.com/docs/ui/styling) | Shared tokens/styles/components, native layout. Figma may author concepts; no HTML/CSS browser inserted into gameplay. |
| Animation | [Roblox animation events](https://create.roblox.com/docs/animation/events) | Semantic markers align presentation. Server timing/validation still determines gameplay outcomes. |
| Body requirements | [Roblox character specifications](https://create.roblox.com/docs/avatar/character-bodies/specifications) | Preserve15-body contract, source names/rig/cages. Marketplace-specific requirements are not blanket budgets for every in-experience monster. |
| Particle budgets | [Roblox particle emitters](https://create.roblox.com/docs/effects/particle-emitters) | Bound effects and transparency overlap; engine maxima are not sensible per-effect budgets. |
| Server validation | [Roblox client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary) | Types, finite numbers, context, ownership, rate limits and authoritative purchase grants. |
| Physical testing | [Roblox test on hardware](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | Studio emulation does not certify physical input, thermal behavior or memory pressure. |
| Persistence | [Roblox DataStores](https://create.roblox.com/docs/cloud-services/data-stores) | Existing durable architecture remains; isolate Studio/cloud testing from real player data. |
| Transient state | [Roblox MemoryStores](https://create.roblox.com/docs/cloud-services/memory-stores) | Disposable projections; expiry/loss must not remove economic truth. |
| Live server gates | [Roblox teleport](https://create.roblox.com/docs/projects/teleport) | Qualifying teleport/cross-server test is separate from local multi-client Studio; retain private-publish approval gate. |
| Random item policy | [Roblox paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items) | Any indirect Robux-funded random path requires dedicated policy review/disclosure; don't activate in this PR. |
| Purchase grants | [Roblox developer products](https://create.roblox.com/docs/production/monetization/developer-products) | ProcessReceipt and durable idempotency; client UI completion is not entitlement proof. |
| Asset export | [Roblox Blender workflow](https://create.roblox.com/docs/art/blender) | Editable source and inspected FBX/glTF import round-trip. Art source is not proof of runtime readiness. |

## Adoption matrix

**Use now:** existing Git/Rojo/Luau validators, Python3.11 standard library, repo-scoped skills, official Studio MCP on the workstation, current Blender source generators after inspection, shared manifests and evidence review.

**Optional after verification:** Figma for original UX/source design; image/audio providers with approved usage rights and budget; reviewed/version-pinned community Blender MCP. Blender Python is the reproducible baseline. Never auto-install a community plugin or silently enable telemetry.

**Do not assume:** any MCP's image/mesh/material tools, GUI input support, arbitrary Studio instance access, paid AI credits, full R15 autoconversion, universal clothes fitting, production throughput, or successful physical-device tests. The current web lookup of the previously cited `ahujasid/blender-mcp` URL returned404; treat package location/version as unresolved, not installation advice. Blender command-line docs were not retrievable in this research attempt; validate exact installed flags via `blender --help` before use.

No third-party skill source was copied wholesale or installed. The specialist skills are project-authored instructions based on the above capabilities and Guildborne contracts. No open-source license is assigned to the user's game by this PR.

## Repository audit findings

The root contains no existing AGENTS.md or .agents/skills tree at the inspected commit. Existing UAT asset generators and files already cover city/region, weapon/item, character/enemy/hero and cosmetic libraries. `tools/audit_production_libraries.py` distinguishes native/source/exported art from pending rig imports, gameplay bindings and human approval; preserve this distinction. Its recorded323-test note differs from older README271-test summaries, so neither number is claimed as a newly executed baseline here. `tools/validate.ps1` is the actual regression entrypoint, with pinned tool setup. Runtime source and existing Rojo project files are intentionally unchanged by the control-plane addition.
