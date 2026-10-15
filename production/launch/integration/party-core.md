# Human Party lifecycle core — local implementation

Implemented temporary same-server human Parties of at most six owners, independent of the existing five-NPC companion party. No profile fields, PlayerGuild records, encounter rewards, travel, commerce or publication are changed.

## API and identity

`HumanPartyRuntime({Enabled,Data,Notify,Players?,Core?,Now?,Log?})` exposes `State(player)`, `Intent(player,action,args,requestId)`, `Add(player)`, `Remove(player)` and `Step()`. `Enabled` must be explicitly true. Root integration restricts this to the isolated local launch candidate. Notify runs only after core mutations; State is read-only and can safely be called by Notify. Optional Players/Core/Now enable runtime adapter tests without Roblox.

Top-level snapshot `humanParty` contains available, revision, capacity=6, localUserId, optional partyId/leaderUserId, members, incomingInvites, outgoingInvites and directory. Members expose userId, Roblox displayName/username, current heroCount, Connected/Reconnecting and ready. Directory exposes identity, heroCount and availability only. Invites expose inviteId/fromUserId/targetUserId/partyId/expiresAt. No profile wealth, inventory, session token or entitlement data is exposed. Snapshot tables are fresh copies.

Canonical user IDs are decimal strings, including negative nonzero Studio test IDs; no exponent, leading zero, fraction or unsafe integer aliases. Invite/transfer resolves a live same-server Player; kick can remove a reconnecting member's reserved slot. Temporary Saving/Degraded profile states retain connected membership and leadership, even beyond the disconnect grace period. New invitations, acceptance, readiness and transfers require active profile eligibility; leave, decline, disband and kick remain recovery controls. Session replacement clears request replay history. Session replacement and stale PlayerRemoving callbacks are fenced by runtime player identity plus captured profile epoch/token.

## Provisional lifecycle policy

Invites last 60 seconds. There are at most six outgoing invitations per inviter and six incoming per recipient; repeated pair invitations are rejected. Only the leader invites. Accept checks invitation identity, current membership, current leader and capacity synchronously. A party is created lazily on the first valid invite; expiry leaves its leader in a one-member Party until leave/disband. Solo players do not need to create a Party.

Disconnect reserves the member's slot for 30 seconds, resets ready state, and transfers leadership immediately to the earliest joined connected member. If nobody is connected, the existing leader remains until expiry; expiry uses deterministic ID ordering. Rejoining the same server within grace recovers membership but not ready state or leadership. Server shutdown/cross-server migration does not preserve these temporary Parties and is not claimed as recovery support.

Membership or leadership changes reset ready state. Ready is a social signal, never travel consent. No automatic movement occurs. Leadership changes/removals cancel affected invitations. Already issued invitations may survive another member accepting, but stale revision and current-capacity checks prevent overfill.

The server maintains a monotonic global revision for this bounded server-local roster. Each intent carries the last projected partyRevision, independent of profile revision. Successful mutation increments it. Per-user request replay remembers the last 64 request IDs and exact action arguments. Exact replay returns its recorded result without recreating membership/invites; changed arguments reject. After eviction, old revisions still reject. Clients must refresh after HumanPartyStale; unrelated roster changes can legitimately require retry.

## Evidence and remaining gates

`tests/run_human_party.luau` exercises six owners with five NPCs each, competing final-slot accepts, replay after disband/new membership, leadership and readiness, expiry/inbox limits, grace/rejoin/stale sessions, canonical Studio IDs, snapshot isolation, runtime profile gates, disabled mode, and kicking an offline member. These are local synthetic tests, not six-client or cross-server acceptance.

Core intentionally does not implement shared encounters, participation credit, conserved payouts, durable multi-owner settlement, ready-travel routing, friendship/blocking platform queries, or Federation. Do not infer Roblox blocking enforcement from this implementation. Full integration, native EN/TH UI and 2/4/6-client validation remain the integration owner's next checks.
