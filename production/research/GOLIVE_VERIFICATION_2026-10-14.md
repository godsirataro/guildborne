# Guildborne local-to-beta verification research

Retrieved: **2026-10-14**. Status: **RESEARCH_REVIEW_PENDING; PUBLIC_READY=false**.

Read-only official-source research, followed by this scoped report write. No Studio actions, installation, cloud writes, asset upload, publication, purchase or paid model call. Free-only scope: no fee or subscription purchase is proposed or authorized. Public documentation does not establish this account's eligibility, ownership, permissions or asset availability.

## Official facts and sources

The following are facts from current, unversioned Roblox documentation, retrieved on the date above. They describe platform behavior, not completed Guildborne acceptance. Recheck the actual Creator Dashboard before a release decision because policy and UI can change.

| Official source | Supported fact |
| --- | --- |
| [Create and publish games and places](https://create.roblox.com/docs/production/publishing/publish-games-and-places) | Release requirements vary by audience. Ages16+/Trusted Friends require good standing, account age at least2 days, age check and the maturity question. All ages adds verification,2FA, subscription-history or fee criteria, evaluation and the full maturity questionnaire. Early-tester preview has separate age/access limits. Actual eligibility is unverified; no paid route is selected. |
| [Asset privacy](https://create.roblox.com/docs/projects/assets/privacy) | Restricted assets need permissions for the relevant creator/game. A collaborator's access alone does not establish runtime access for the target game. The Asset Privacy setting changes creation defaults only for Images, Decals and Meshes; audio, animations and other types have their own defaults. Open Use conversion is irreversible. |
| [Data stores](https://create.roblox.com/docs/cloud-services/data-stores) | DataStores are shared across places/servers of a game. Studio API access can reach the same stores as the Roblox client; Roblox recommends a separate test game instead of enabling this on a live game. Network operations can fail. |
| [Teleport between places](https://create.roblox.com/docs/projects/teleport) | TeleportService does not support Studio playtesting; test it in the Roblox client after an authorized publish. This is relevant if a qualified route actually uses that service; local world movement is not automatically a teleport test. |
| [Studio testing modes](https://create.roblox.com/docs/studio/testing-modes) | Server & Clients simulates one server and multiple clients, up to8. It is useful for client isolation/replication, but does not demonstrate two live server instances. Device and network simulators support iteration. |
| [Test on hardware](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | Emulation cannot reproduce real memory pressure, thermal behavior or input latency. Use device profiling and real phone controls. Roblox suggests10–15 minutes of sustained gameplay to look for thermal decline and checking real constrained/cellular networking. |

No blanket license or copyright clearance is inferred for third-party assets. Permission to load is a platform access fact; provenance/usage terms remain a separate review. No Open Use conversion, group permission grant, fee or subscription change is authorized by this research.

## Three concrete next checks

These are prioritization recommendations derived from the current launch plan/backlog, not Roblox's universal launch checklist. Each requires its own recorded result and independent review.

### 1. Approved staging identity and actual asset delivery

Owner: release lead / tools engineer / asset specialists.

Freeze the intended revision and build hash; record the approved owner/group, UniverseId/PlaceId, namespace and target audience. Capture actual Dashboard eligibility/access/maturity results without claiming eligibility from this report. The present local release resolver requires Studio, PlaceId0/GameId0 and Memory; do not silently remove that fence to activate cloud. A reviewed staging configuration is a separate work item.

Inventory every runtime mesh/texture, animation and audio binding, its provenance and type-specific target-universe permission. Test actual delivery with a tester account in the approved Roblox client environment. Beta's eight preset mappings and Public's thirteen presets are Guildborne requirements; generated geometry, null IDs, EditableMesh previews or one successful body/outfit are insufficient. Keep rights/load, rig/cage/fit and human visual approval as separate facts.

Exit evidence: immutable build/manifest, explicit staging identity and access result, asset load/errors plus per-preset fit evidence. If the free-only boundary cannot satisfy an audience requirement, record that audience gate as unresolved rather than purchasing or implying a free workaround.

### 2. Persistent normal hero route and cross-server session ownership

Owner: gameplay / QA / systems engineer.

On that same approved staging build, complete normal recruitment, hero leveling to35, subject/path trial and AdvanceClass through native UI. Exercise leave/rejoin, daily/proof replay, old-save migration and delayed/uncertain saves on isolated test data. Use two genuinely distinct nonempty JobIds for overlapping session/guild checks. Verify one durable proof/reward, correct ownership, no stale-owner overwrite and no guessed compensation. Keep commerce and market disabled unless their separate acceptance and activation are authorized.

Exit evidence: timestamped inputs and before/after authoritative revisions/value, rejoin result, server identities, retained failures/retries and no duplicate/lost value. A fixture record or two clients on one server does not satisfy this check.

### 3. Full-party multiplayer and physical-device qualification

Owner: QA / performance engineer / localization / human testers.

First use2 then4 Studio clients for isolation, permission, replication and disconnect regressions. Then qualify actual Roblox clients with four players and up to twenty companions, including Android/iOS hardware. Guildborne's threshold is a30-minute active session, target30FPS on declared minimum devices and bounded memory; those numbers come from the project plan, not a Roblox certification standard.

Record frame times/FPS, memory trend, loading, thermal decline, touch reach/readability in TH/EN, input switching, full-party VFX and actual speaker/headphone audio. Confirm constrained network behavior on hardware after simulator checks. Keep unfamiliar-tester usability and human art/feel approval separate from metrics.

Exit evidence: named device/OS/build, duration/scenario, actual-client count and hardware profile, raw metrics, observed defects and human feedback. Desktop layout emulation does not pass physical acceptance.

## Existing local evidence and its limits

Read [launch plan](../LAUNCH_PLAN.md), [backlog](../launch/backlog.json), [Hero mentor update](../launch/integration/HERO_MENTOR_UPDATE.md) and [checks](../launch/integration/hero-mentor-checks.json). At this review snapshot, candidate41e341d4 had749 automated tests and scoped Studio fixture evidence. Later changes require fresh identity/validation; this report does not freeze the current dirty workspace.

The Studio mentor fixture covered Berserker, Cleric and Guardian, pending-cancel refusal, restoration, active epoch cancellation and injected acquisition failure. Its commit sink applied the pure proof operation to a separate fixture record, not live bootstrap PlayerDataService or a DataStore. Transaction uncertainty/rejoin was exercised by automated PDS tests. The initial fixture failure was retained; contextual diagnosis involved the separate MCP require context missing bootstrap's ability merge.

Normal boot showed Lv1, no heroes and revision0; private receipt/foreign-start rejection was observed. The normal hero recruitment-to-Class2 route, remaining runtime paths, cloud persistence, distinct live servers, physical devices and human release acceptance remained pending. Earlier normal player journey evidence belonged to a different candidate and must not be promoted to current-build acceptance.

The launch plan's older implemented-list sentence saying hero proof is missing conflicts with its newer outstanding/latest sections saying source is implemented. Treat the missing item as normal-route/persistence acceptance, not another competing proof service; the coordinator owns correction of canonical launch documents.

## Handoff

Research-file-only change. Source facts were retrieved through web tools; no new game or Studio test was run for this report. Independent research review is pending. Next owners should turn the three checks into scoped, dependency-ready acceptance work while retaining explicit approval for cloud/publication/spending and external hardware/human gates. Automated learning may preserve evidence and propose tested improvements; it cannot promote these external gates to PASS.
