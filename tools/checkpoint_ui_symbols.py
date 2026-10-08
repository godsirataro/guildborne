from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest brand and symbol checkpoint — 2026-10-02

42 original SVG/native symbols created:5class,13combat,12map,12guild-emblem. Shared typed geometry + noninteractive native renderer; Focus/Regroup/Retreat bound to actual existing buttons. Fractional scale coordinates fix clipped line endpoints caused by Roblox integer pixel offsets at18px. Synthetic Studio42×3sizes/1011primitive bounds checks passed. Actual command buttons116×44 have18×18icons at(5,13), Thai labels fit with no overlap. Other39bindings/human/device acceptance pending. Gallery: ui-symbols.png and assets/uat01/ui-symbols/gallery.html. Build/strict/repository132runtimefiles passed before final fractional-coordinate refinement; final verification log validation-symbol-types.txt.

Generated standalone transparent crest candidatesv1/v2 using existing original logo as reference; exact prompts saved CREST_PROMPTS.md. v2visible silhouette has safe padding, but faint alpha extends beyond requested16%margin; import/compression review still required. Local image manifest now17PNGs including superseded crestv1. Registry239assets65screens reconciled: only15art rows remain PLANNED; source-ready is not gameplay-complete or UAT-approved.12enemy/3region captures now trace to authored Blender/native sources. Script-free prefab packs remain available separately.

Last quota80% used/20%remaining; continue toward15%. Studio owned Play stopped. No publication, upload, ordinary-profile mutations or live commerce.326domain tests latest; main132runtimefiles. Regional player gameplay/rewards, recruitment rotation, cosmetics entitlement, Player Guild and integrated device/multiplayer/recovery/human UAT still pending.

'''
p=docs/'HANDOFF.md';s=p.read_text(encoding='utf-8');p.write_text(note+s,encoding='utf-8')
for name in ('STATUS.md','WORK_CHECKLIST.md','USAGE_STOP.md'):
 p=docs/name;s=p.read_text(encoding='utf-8').replace('last observed21% remaining','last observed20% remaining').replace('79% used / 21% remaining','80% used / 20% remaining').replace('15local generated PNGs','17local generated PNGs');p.write_text(s,encoding='utf-8')
p=root/'assets/uat01/GALLERY.md';s=p.read_text(encoding='utf-8').replace('Twelve local PNG sources.','Seventeen local PNG sources, including superseded variants.');s=s.replace('## Brand and title art','## Additional production sources\n\n42 original SVG/native UI symbols: [gallery](ui-symbols/gallery.html). Script-free Roblox model libraries: [prefab packs](roblox-prefabs/README.md).\n\n## Brand and title art');s=s.replace('Transparent logo source. Roblox upload pending.','Standalone transparent crest v2; faint-alpha padding still needs import review.\n\n![Guildborne crest](generated/guildborne-crest-v2.png)\n\nTransparent logo source. Roblox upload pending.');p.write_text(s,encoding='utf-8')
