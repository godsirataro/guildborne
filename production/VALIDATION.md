# Production v2 validation — 2026-10-09

## Source inspected

Continuation of PR #1, not a new game or clean-room replacement. Runtime and UAT
text sources were read from immutable GitHub revision
`5aa737b145ae4a4940204c0554d773abe51a618e` using the CI review archive.
The working copy omits heavy `assets/` and `review/` directories; local missing
binary references are not evidence those files are missing from GitHub. CI runs
reconciliation on a full checkout. Original game tests remain unchanged.

## Executed locally before v2 upload

| Check | Observed result |
| --- | --- |
| Python production suite | **66 passed**, zero failures and zero skips |
| Plan and skills | **33 tasks / 25 skills**, valid dependencies and skill metadata |
| Current registry intake | All **502 asset / 73 screen** rows retained, plus **89 kit** rows; no source registry mutation |
| Character authoring contract | **15 part names, 13 presets, 20 palettes**, head aliases, CSV and explicitly untested fit matrix generated |
| New Python source compilation | PASS |
| Existing repository static validator | PASS: **43 documents, 473 local links, 1 JSON fixture, 317 strict Luau files** |
| Procedural preview generator | Six local RGBA candidates plus truthful manifest; not final art |
| Fake commit / wrong tree / stale HEAD / dirty source / wrong invocation tests | Rejected as expected |
| Worker / MCP / command recording | Real subprocess fixtures exercised; **not actual Codex, Studio or Blender execution** |

The full-checkout CI workflow separately runs the existing pinned Windows
Luau/type/build/repository suite and **six additional latest-progression domain
checks**. Inspect the PR's current run for the exact commit and results. These
new Luau checks were not executed in the Linux authoring container because the
required binary was not installed. CI success is not Studio visual acceptance.

## What the additional tests check

Novice Class2 needs35 while legacy30 is preserved; a hero must meet its own level;
Class3 and quest gates remain; existing Hall caps and AP budgets remain; successful
Novice promotion clears spent SP/AP without duplicating budgets, even when the
status UI is disabled; replayed promotion cannot reset a later allocation; EN/TH
advancement text follows the same ruleset-aware threshold.

Python tests also check source hashing and reuse, canonical IDs, path containment,
quest/skill cycles and prerequisite deadlocks, explicit model-run approval,
lease ownership, bounded subprocess termination/retry/resume, read-only MCP
handshake/pagination/errors, local candidate provenance and PNG container checks.
All fixtures are labeled. A fixture server named FIXTURE_NOT_ROBLOX is never live
Roblox evidence. PNG inspection is not a complete image decoder or visual review.

## Runtime changes and preserved state

V2 changes only ruleset-aware advancement readiness, promotion refund behavior,
and localized advancement display, plus a new localized copy module. It does not
roll out a new default ruleset, rewrite profile schemas, reset old paths/levels,
remove legacy ancestry bonuses, alter market authority or enable purchases.
Hall and StatusPoints formulas already existed and are reused.

## Remaining external work

Actual Codex quota-consuming execution, Roblox Studio MCP connection/playtests,
Blender body/clothing generation and audit, asset upload/ownership, animated
human clothing fit, complete image/audio provider integration, physical devices,
independent live servers, sustained cloud soak and human UAT remain pending.
The new helpers make the workflow executable when those tools are present; they
do not claim all-game unattended generation or completed art in this session.

The normalized Character Kit is self-contained for contract/CSV/fit planning;
original17-file ZIP/XLSX intake still needs the pinned source archive. No font or
third-party binary is distributed. New commerce processing remains explicitly
deferred after the prior connector block. No safeguard was bypassed.

No merge, Roblox publication, paid API/Robux spend, live monetization, production
DataStore write, or public-market activation is authorized or performed here.
