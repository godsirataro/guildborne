--!strict
-- Bounded staging pilot. Receipt exhaustion closes admission, never recovery.
return {
	StorageVersion = 2, PublicEnabled = false, PrivateEnabled = true,
	MaxActiveItems = 5, MaxActivePerItem = 32, MaxActiveGlobal = 160,
	EpochSeconds = 86400, ReplaySeconds = 300, ArchiveEpochs = 32,
	RawTradeLimit = 128, HistorySeconds = 30 * 86400,
	BudgetReserve = 20, MaintenanceBudgetReserve = 30, ItemWriteInterval = .5, MaxItemQueueSeconds = 2,
	FailureThreshold = 3, BreakerSeconds = 30, MaxPendingClaims = 384,
	Version = 1, Epoch = 1, FeeBps = 500, MaxPrice = 100000, MaxQuantity = 1000,
	MaxOrderValue = 10000000, OpenOrders = 5, BookOrders = 128,
	ProfileTransfers = 128, ProfileClaims = 512, BookBytes = 1048576,
	Lifetime = 7 * 86400, Depth = 20, HistoryLimit = 60, CacheSeconds = 10,
	IndexTTL = 90, RecoverySeconds = 30, AdmissionEnabled = true,
	Items = { stone = 3, timber = 4, iron_ore = 6, iron_ingot = 20, herb = 5 },
	Reference = { Window = 86400, Samples = 20, Users = 10, Pairs = 5, Buckets = 3,
		BucketSeconds = 300, VolumeCap = 100, MADMultiplier = 3, MedianBand = .2 },
}
