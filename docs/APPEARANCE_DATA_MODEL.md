# Appearance data extension

Each player or owned hero may carry `appearance`, `appearanceRevision` and
`appearanceEnabled`. The appearance envelope has version1, uppercase race/body/
palette/head IDs, optional hair/beard IDs, a bounded raceFeatures map and outfitSlots.
The canonical Human head is `CHR_HEAD_HUMAN_01`; `HEAD_HUMAN_01` is an intake alias
normalized at the intent boundary. Persist canonical IDs only, never Instances,
mesh binaries, URLs or arbitrary Roblox numeric asset IDs.

The existing profile envelope version and default staging configuration are
preserved. Only an explicitly injected appearance dependency introduces
deterministic version1 defaults during new/load migration. Defaults have revision0
and `appearanceEnabled=false`, so loading old heroes does not reroll their visible
identity. Replaying migration leaves existing choices untouched. New actors without
stored appearance receive read-only defaults in the local preview projection.

`CommitAppearance` carries `actorId`, full `selection` and expected
`appearanceRevision`. Existing network/session/operation receipt fences remain in
force. The domain resolves the actor from the caller's profile, checks shape,
catalog pairing, availability, entitlement, per-preset fit eligibility and stale
revision, then changes only the actor's appearance fields. Appearance changes
never change legacy ancestry, HP, class, XP, level, stats, points, gear, Gold,
inventory, receipts, ownership or market escrow.

The implementation's candidate policy is injected exclusively in Studio at
place0/universe0 with Memory persistence. Its starter IDs authorize explicitly
labeled test substitutes, not production ownership or proven layered fit.
Production import records and entitlement rules must replace that policy before
a separately reviewed persistent rollout. Memory Close/Load tests exercise the
real transaction code against injected storage; they are not DataStore rejoin.
