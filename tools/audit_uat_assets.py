"""Read-only image inspection; writes metadata, never changes source pixels."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "uat01"
ITEMS = ["stone", "timber", "iron_ore", "iron_ingot", "herb", "training_sword",
         "short_bow", "apprentice_staff", "iron_sword", "knight_sword", "mage_staff",
         "leather_vest", "guardian_plate", "woven_robes", "bronze_ring", "vitality_charm"]
SKILLS = ["Knight.basic", "Warrior.basic", "Archer.basic", "Mage.basic", "Priest.basic",
          "taunt", "power_strike", "piercing_shot", "fireball", "heal", "bulwark", "cleave",
          "volley", "nova", "renewal", "bulwark_master", "cleave_master", "volley_master",
          "nova_master", "renewal_master"]
EQUIPMENT = ['watchblade', 'oathblade', 'yew_longbow', 'tide_staff', 'dawn_crozier', 'scout_coat', 'runewoven_mantle', 'harbor_mail', 'vanguard_harness', 'pilgrim_robes', 'sentinel_seal', 'hunters_token', 'focus_prism', 'wardstone']
GRIDS = {"guildborne-equipment-icons-v1.png": (4,4,EQUIPMENT),"guildborne-item-icons-v1.png": (4, 4, ITEMS),
         "guildborne-skill-icons-v1.png": (5, 4, SKILLS)}
entries = []
previous = json.loads((ASSETS / "manifest.json").read_text(encoding="utf-8")) if (ASSETS / "manifest.json").exists() else {"images": []}
for path in sorted((ASSETS / "generated").glob("*.png")):
    with Image.open(path) as im:
        im.load()
        w, h = im.size
        alpha = im.getchannel("A") if "A" in im.getbands() else None
        item = {"file": str(path.relative_to(ROOT)).replace("\\", "/"),
                "width": w, "height": h, "mode": im.mode,
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "generator": "built-in image_gen", "date": "2026-10-01",
                "robloxAssetId": None, "uploaded": False,
                "status": "local_art_source" if any(x in path.name for x in ("logo", "keyart")) else "concept_reference",
                "alphaRange": alpha.getextrema() if alpha is not None else None}
        if alpha is not None:
            item["transparentPixelFraction"] = round(alpha.histogram()[0] / (w * h), 4)
            item["nontransparentBounds"] = alpha.getbbox()
        if "crest" in path.name:
            item.update(date="2026-10-02",promptSource="assets/uat01/CREST_PROMPTS.md",status="brand_crest_candidate_import_pending")
            assert alpha is not None
            bounds=alpha.getbbox();assert bounds
            item["minimumTransparentMarginPx"]=min(bounds[0],bounds[1],w-bounds[2],h-bounds[3])
            item["requestedMarginMet"]=item["minimumTransparentMarginPx"]>=min(w,h)*.16
            item["visibleAlphaBoundsOver8"]=alpha.point(lambda a:255 if a>8 else 0).getbbox()
            item["warning"]="Generated alpha includes faint pixels beyond the visible crest. Padding/compression/import review remains pending; no raster edits applied outside image_gen."
            if path.name.endswith("v1.png"):item["status"]="superseded_crest_candidate"
        if "texture" in path.name:
            rgb=im.convert("RGB")
            left=list(rgb.crop((0,0,1,h)).getdata());right=list(rgb.crop((w-1,0,w,h)).getdata())
            top=list(rgb.crop((0,0,w,1)).getdata());bottom=list(rgb.crop((0,h-1,w,h)).getdata())
            edge=lambda a,b:round(sum(abs(x-y) for p,q in zip(a,b) for x,y in zip(p,q))/(len(a)*3),3)
            item.update(date="2026-10-02",promptSource="assets/uat01/UI_TEXTURE_PROMPTS.md",status="ui_texture_candidate_tiling_import_review_pending",edgeMeanAbsoluteDifferenceRGB={"horizontal":edge(left,right),"vertical":edge(top,bottom)},warning="Opposite-edge difference is diagnostic only, not seamlessness certification. No runtime asset ID; import and text contrast review pending.")
        if path.name == "guildborne-city-identities-v1.png":
            item.update(date="2026-10-03",promptSource="assets/uat01/CITY_IDENTITY_PROMPTS.md",status="six_city_architecture_concept_reference",warning="Planned city identities; not six completed playable cities or a literal navigable layout.")
        if path.name == "guildborne-island-arrival-v1.png":
            item.update(date="2026-10-06",promptSource="assets/uat01/ISLAND_ARRIVAL_PROMPT.md",status="guild_island_arrival_concept_reference")
        if path.name == "guildborne-crosshaven-chapter05-v1.png":
            item.update(date="2026-10-06",promptSource="assets/uat01/CROSSHAVEN_CHAPTER05_PROMPT.md",status="crosshaven_chapter05_concept_reference",warning="Art direction only, not a game screenshot or literal navigable layout. Named NPC identities remain in the native city cast kit.")
        if path.name == "guildborne-archive-heart-v1.png":
            item.update(date="2026-10-06",promptSource="assets/uat01/ARCHIVE_HEART_PROMPT.md",status="archive_heart_finale_concept_reference",warning="Atmosphere reference only, not playable terrain. Runtime routes need continuous walkable bridges; the staged boss uses three seals, not the four decorative disks shown here.")
        if path.name == "guildborne-vfx-healing-ward-v1.png":
            assert alpha is not None and alpha.getextrema()[0] == 0
            bounds=alpha.getbbox();assert bounds
            margin=min(bounds[0],bounds[1],w-bounds[2],h-bounds[3])
            item.update(date="2026-10-06",promptSource="assets/uat01/HEALING_WARD_PROMPT.md",status="single_ward_texture_candidate_import_pending",minimumTransparentMarginPx=margin,requestedMarginMet=margin>=min(w,h)*.15,warning="Single static sprite, not a flipbook. Generated margin and glow need compression/background review. No upload or runtime texture binding.")
        if path.name == "guildborne-vfx-guild-portal-v1.png":
            assert alpha is not None and alpha.getextrema()[0] == 0
            bounds=alpha.getbbox();assert bounds
            margin=min(bounds[0],bounds[1],w-bounds[2],h-bounds[3])
            item.update(date="2026-10-06",promptSource="assets/uat01/GUILD_PORTAL_PROMPT.md",status="guild_portal_texture_candidate_import_pending",minimumTransparentMarginPx=margin,requestedMarginMet=margin>=min(w,h)*.125,warning="Static aura with irregular silhouette. Glow margin, alpha fringe, compression and mobile overdraw review pending. No upload or runtime binding.")
        if path.name in GRIDS:
            cols, rows, ids = GRIDS[path.name]
            item.update(status="static_atlas_candidate_crop_review_required", columns=cols, rows=rows, cells=[])
            for i, asset_id in enumerate(ids):
                x, y = i % cols, i // cols
                # Match Luau math.round (positive values); varying cell size is intentional.
                rect = [int(x*w/cols+.5), int(y*h/rows+.5), int((x+1)*w/cols+.5), int((y+1)*h/rows+.5)]
                item["cells"].append({"id": asset_id, "rectXYXY": rect})
            item["warning"] = "Uneven pixel dimensions: use explicit rectangles. Check each crop/gutter at 48px and Roblox import resolution before enabling. Never use as a flipbook."
        if path.name in {"guildborne-vfx-slash-v1.png", "guildborne-vfx-smoke-v1.png", "guildborne-vfx-impact-v1.png"}:
            item["status"] = "single_particle_texture_candidate"
            item["promptSource"] = "assets/uat01/VFX_TEXTURE_PROMPTS.md"
            if "impact" in path.name:
                item["promptSource"] = "assets/uat01/IMPACT_PROMPT.md"
            item["warning"] = "Single sprite, not flipbook. Upload, compression, runtime tint and dark/light background acceptance pending."
            assert alpha is not None and alpha.getextrema()[0] == 0 and alpha.getextrema()[1] > 0, path.name
            bounds = alpha.getbbox()
            assert bounds, "Empty sprite"
            item["minimumTransparentMarginPx"] = min(bounds[0], bounds[1], w-bounds[2], h-bounds[3])
            item["edgeReviewRequired"] = item["minimumTransparentMarginPx"] == 0
            requested = .18 if "impact" in path.name else .2 if "smoke" in path.name else .15
            item["requestedTransparentMarginFraction"] = requested
            item["requestedMarginMet"] = item["minimumTransparentMarginPx"] >= min(w,h)*requested
            item["visibleAlphaBoundsOver16"] = alpha.point(lambda a: 255 if a > 16 else 0).getbbox()
            if item["edgeReviewRequired"]:
                item["status"] = "particle_candidate_faint_edge_alpha_review_required"
            elif not item["requestedMarginMet"]:
                item["status"] = "particle_candidate_margin_review_required"
        entries.append(item)
for existing in previous["images"]:
    if existing["file"].startswith("assets/uat01/generated/"):
        continue
    path = ROOT / existing["file"]
    with Image.open(path) as im:
        im.load()
        assert list(im.size) == [existing["width"], existing["height"]]
    assert hashlib.sha256(path.read_bytes()).hexdigest() == existing["sha256"]
    entries.append(existing)
manifest = {"schema": 1, "generatedAssetCount": len(entries), "images": entries,
            "permissionStatus": "No cloud upload or external rights verification performed.",
            "sourcePolicy": "Original generation prompts in PROMPTS.md. No third-party images imported; do not label generated outputs public domain."}
(ASSETS / "manifest.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False)+"\n", encoding="utf-8")
print(f"Inspected {len(entries)} PNGs; manifest written; source pixels unchanged.")
