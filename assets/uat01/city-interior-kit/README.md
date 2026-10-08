# City interior furnishings

Five original room layouts: guild office, hearth tavern, exchange office, forge workshop and alchemy study.169 native parts /2028 triangles,5FBX,5GLB,5individual previews plus gallery and editable Blender scene. Geometry is authored locally from kit.json by tools/build_city_interiors.py; no marketplace meshes.

CentralCityWorld installs the layouts inside the five existing main buildings. Eight-stud central entrance aisles remain clear through31samples per building;169anchored parts are bounded inside the shells. Larger furnishings collide, small props do not; all disable touch events. These are environmental furnishings, not new services or purchase interactions.

Portable mesh exports round-trip through Blender with triangle counts, origin, dimensions and materials preserved. Studio native runtime probe is tests/studio_city_interiors_probe.luau. Neutral standard R15 walked into and out of all five live buildings at speed16 without auto-jump. This caught and fixed overlapping decorative street frontage. Arbitrary avatar collision and final device performance acceptance remain pending. No Roblox mesh IDs or human UAT approval.

Rebuild: python tools/build_city_interiors.py, then Blender tools/blender_item_kit.py with --kit assets/uat01/city-interior-kit --name Guildborne_City_Interiors --max-triangles1200 (pass value as separate argument), then tools/render_city_interiors.py. Verify with tools/verify_item_kit.py --kit assets/uat01/city-interior-kit. Main runtime uses CityInteriorKit.luau, so no mesh upload is required for the current native version.
