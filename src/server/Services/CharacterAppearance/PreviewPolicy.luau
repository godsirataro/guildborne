--!strict
-- Only injected in an isolated, cloud-free Studio Memory session. These pairs
-- authorize labeled test substitutes; they do not certify garment fit or import.
local ids = {
	"CHR_BDY_HUMAN_STANDARD_V01", "CHR_BDY_HUMAN_HEAVY_V01", "CHR_HEAD_HUMAN_01",
	"ACC_HAIR_HUMAN_01", "CLO_TUNIC_TRAVELER_01", "CLO_TROUSERS_TRAVELER_01",
	"CLO_ROBE_WIZARD_01", "CLO_HAT_WIZARD_01",
}
local assets: {[string]: boolean} = {}
for _, id in ipairs(ids) do assets[id] = true end
local presets = {HUMAN_STANDARD=true, HUMAN_HEAVY=true}
return table.freeze({
	AllowPlaceholders=true,
	AllowedPresets=table.freeze(presets), AllowedAssets=table.freeze(assets),
	StarterEntitlements=assets,
	ApprovedFits={HUMAN_STANDARD=assets, HUMAN_HEAVY=assets},
	Evidence="PLACEHOLDER_TEST_SUBSTITUTES_ONLY_FIT_NOT_ACCEPTED",
})
