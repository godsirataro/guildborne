# Six original city landmarks

Six modular architectural prototypes translate the city identity board into editable native geometry and Blender meshes: Crownford Clock Gate, Sylvaris Council Tree Pavilion, Deepforge Grand Forge, Astralis Crystal Observatory, Crosshaven Charter Pavilion and Ironroot Welcome Feast Hall.

192 native parts /2304 mesh triangles total. Each has an open entry route, a distinct silhouette and the planned city palette. Models are simpler than the generated city illustration. They do not create six cities, city travel, quests, services or purchase rights.

Sources: kit.json; ../../../../tools/build_city_landmarks.py; ../../../../review/CityLandmarkKit.luau; Guildborne_City_Landmarks.blend. Each model has a512px transparent rendered preview and FBX/GLB exports. preview.png is a3×2 contact sheet. No cloud asset IDs are assigned.

Validation: all12exports round-trip with triangle counts, bounds, origins and materials preserved. Native fixtures verified192anchored parts,64entry clearance samples and6PathfindingService routes using a radius2/height5agent. The pathfinding ground and models were temporary and removed. Separate standalone Studio Play review then verified actual keyboard E travel both ways and character_navigation to all six interiors, with position readbacks and100health throughout. See docs/uat01/validation-city-landmarks-live.json. Mobile performance and finished-city acceptance remain pending. Native collision flags are per-part; imported meshes require a separate collision setup and Roblox import review.

Rebuild:

1. python tools/build_city_landmarks.py
2. Blender background: tools/blender_item_kit.py -- --kit assets/uat01/city-landmarks --name Guildborne_City_Landmarks --max-triangles 1300 --large-assets --front-view.
3. Blender background: tools/render_city_landmark_gallery.py
4. Blender background: tools/verify_blender_kit.py -- --kit assets/uat01/city-landmarks

The separate gallery script only arranges the editable Blender scene and renders it; exported geometry remains unchanged.
