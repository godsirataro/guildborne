--!strict
-- Approved uploaded IDs only. Local PNGs are catalogued in assets/uat01/manifest.json.
-- Empty means native fallback. Upload/permission review is a separate owner action.
return {
	Logo = "",
	KeyArt = "",
	ItemAtlas = "",
	EquipmentAtlas = "",
	EquipmentAtlasSize = Vector2.new(1254, 1254),
	EquipmentOrder = {"watchblade","oathblade","yew_longbow","tide_staff","dawn_crozier","scout_coat","runewoven_mantle","harbor_mail","vanguard_harness","pilgrim_robes","sentinel_seal","hunters_token","focus_prism","wardstone"},
	ItemAtlasSize = Vector2.new(1254, 1254),
	ItemColumns = 4,
	ItemRows = 4,
	ItemOrder = {
		"stone", "timber", "iron_ore", "iron_ingot",
		"herb", "training_sword", "short_bow", "apprentice_staff",
		"iron_sword", "knight_sword", "mage_staff", "leather_vest",
		"guardian_plate", "woven_robes", "bronze_ring", "vitality_charm",
	},
}
