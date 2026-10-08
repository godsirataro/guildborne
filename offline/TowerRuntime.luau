--!strict
-- Separate offline playtest build only. Every Studio server starts fresh.
return {
    StudioPersistence="Memory",
    NoviceJourney=true,
    IronveilJourney=true,
    AshenJourney=true,
    TowerJourney=true,
    CrosshavenJourney=false,
    ArchiveHeartJourney=false,
    PrivateAcceptance={Enabled=false,RunId="",UserIds={} :: {[number]: boolean}},
    AllowedDataStoreUniverses={} :: {[number]: string},
    LeaseSeconds=180,LeaseSafetySeconds=30,HeartbeatSeconds=50,
    MaxAttempts=3,RetryBaseSeconds=.5,AuditPageSize=32,
    VerboseStudioLogs=true,RobloxAnalyticsEnabled=false,
    PermanentPassesEnabled=false,
}
