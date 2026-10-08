--!strict
return {
	-- Guildborne - Staging; IDs read from Studio on 2026-09-28.
	-- Use Memory only for a separate offline preview; it resets when the server stops.
	StudioPersistence = "DataStore",
	NoviceJourney = false, -- Only the separate memory-only course preview opts in.
	IronveilJourney = false, -- Staged Chapter02; enable only in an explicit memory preview.
	AshenJourney = false, -- Chapter03 is restricted to an explicit memory-only preview.
	TowerJourney = false, -- Chapter04 requires the separate memory-only Tower preview.
	CrosshavenJourney = false, -- Chapter05 requires the separate memory-only Crosshaven preview.
	ArchiveHeartJourney = false, -- Chapter06 requires the separate memory-only finale preview.
	PrivateAcceptance = { Enabled = false, RunId = "", UserIds = {} :: { [number]: boolean } },
	AllowedDataStoreUniverses = { [10768425213] = "staging" } :: { [number]: string },
	LeaseSeconds = 180,
	LeaseSafetySeconds = 30,
	HeartbeatSeconds = 50,
	MaxAttempts = 3,
	RetryBaseSeconds = 0.5,
	AuditPageSize = 32,
	VerboseStudioLogs = true,
	RobloxAnalyticsEnabled = false,
	PermanentPassesEnabled = false, -- IDs remain zero; no live purchase/restore calls.
}
