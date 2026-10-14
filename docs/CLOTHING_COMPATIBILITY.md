# Clothing fit status

| Asset | Candidate presets | Candidate rendering | Production fitting |
| --- | --- | --- | --- |
| CLO_TUNIC_TRAVELER_01 | Human Standard, Heavy | removable rigid placeholder | layered cages/UVs/deformation pending |
| CLO_TROUSERS_TRAVELER_01 | Human Standard, Heavy | removable rigid placeholder | layered cages/UVs/deformation pending |
| CLO_ROBE_WIZARD_01 | Human Standard, Heavy | removable rigid placeholder | layered robe/bending pending |
| ACC_HAIR_HUMAN_01 | Human Standard, Heavy | rigid placeholder | real import/attachment offsets pending |
| CLO_HAT_WIZARD_01 | Human Standard, Heavy | rigid placeholder | real import/grip/fit pending |
| Other catalog assets | none accepted | unavailable | pending production |

Base modesty precedes inner top/bottom, outer clothes, then rigid accessories.
Outfit removal cannot remove the base covering. The original catalog has no
helmet ID; the first headwear test uses its actual wizard-hat ID. Weapons are
existing authoritative equipment; cosmetic WEAPON selection is rejected.

AppearanceAssetRegistry structurally rejects layered garments without a real
MeshPart Handle, WrapLayer cage/reference meshes and 15 body WrapTargets. This is
a precheck, not proof of corresponding cage UVs or animation fit. Human/Elf shared
fit-family naming does not certify fit on Elf, Orc or Dwarf. Every production
preset/item combination remains unaccepted until observed Studio fitting.

Real Blender candidates now exist for these five removable items. Their geometry,
UVs and source materials survived local static EditableMesh inspection. This is
export/inspection evidence; corresponding cage UVs, flexible layering and bend
fit on Standard/Heavy remain pending. Runtime rendering still uses the labeled
rigid substitutes in the table.
