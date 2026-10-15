# Actual local Party clients — 2026-10-15 Bangkok

Candidate `75169c5d3c878aba276ed9f44be9c8f4ca1d8d7829f86eb4e38402436486503b`, separate LaunchPreview file, PlaceId/GameId0, Memory-only. Dedicated local server MCP `c8da2bad-7e1a-4c2a-9afe-b69509dcc8f7`, empty JobId. Staging was not changed. Native Studio Server and Clients started seven real local clients sequentially; IDs Player1–Player7 / -1 through -7, with actual player rigs and zero equipped NPC heroes.

## Observations

- Player1 invited Player2 through visible native menu and button. First invitation expired during inspection and was cleared without adding a member. Second visible invitation and acceptance produced two members. Raw: party-two-client-native-joined.json.
- Players3–6 accepted through their real client RemoteEvents using party-real-client-command.luau. Four- and six-client packets are preserved. These later steps are scripted protocol tests, not six human UI walkthroughs.
- Six members belonged to the same party. Ready succeeded; nonleader kick failed with HumanPartyLeaderRequired. Leader transfer succeeded; former leader kick failed. Stale revision failed with HumanPartyStale. Profile revisions remained0. Raw: party-six-client-authority.json.
- Seventh real client stayed solo; the full party rejected invitation with HumanPartyFull. Native screen displayed Players:6/6. Raw: party-seven-client-capacity.json.
- Server-side Kick of local Player2 induced a real disconnect. Immediate read preceded removal; later read showed Player2 Reconnecting and Player1 promoted. Both raw observations are retained. After the30-second grace elapsed, Player2 disappeared and Player7 could be invited and join. The file named party-grace-capacity.json captured this **after-expiry** successful invitation, not an in-grace rejection; no such claim is made.
- Disband sent twice with exactly the same request/arguments returned OK both times and the same party revision26. All six remaining actual clients then projected solo with profile revision0. Raw: party-real-client-disband-result.json and party-all-clients-disbanded.json.
- The native Test → End Session action closed the owned local server/clients. Subsequent MCP inventory contained only LaunchPreview and unchanged Staging.

## Boundaries and follow-up

This establishes local multi-client Party membership/authority/disconnect observations only. No shared combat, travel, rewards, companion load, real device, distinct live servers, durable cloud saves or human UAT passed here. Seven Studio clients do not establish device performance capacity. No character progression was granted or profile directly edited.

Observed UX issue: ordinary stale/full responses showed generic retry/rejoin advice and raw codes. A subsequent source patch adds contextual EN/TH messages; its own candidate/render validation is separate from the multiplayer candidate above. Device-emulated input coordinates required fresh observation: tool success alone did not prove a button click. Screenshots were returned in the conversation; no screenshot file is asserted by this report.
