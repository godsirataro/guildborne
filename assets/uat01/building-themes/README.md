# Guildborne building themes

Original local prototype assets; not uploaded. The generated concept board is an art target. Native models are deliberately simple open utility structures and are not finished versions of the concept buildings.

- concept.png: six-theme concept board from built-in image_gen; exact prompt in concept-prompt.txt.
- kit.json: source geometry exported from the native BuildingAppearance module through tests/studio_export_theme_kit.luau.
- Guildborne_Building_Themes.blend: editable mesh gallery.
- theme_*.fbx / theme_*.glb: six models, twelve round-trip-verified exports.
- theme_*.png: six transparent Blender preview icons; preview.png is a front-elevation comparison gallery.
- export-report.json / roundtrip-report.json:119source parts,1,428triangles and12verified exports.

Generation: Blender5.2, tools/blender_item_kit.py --kit assets/uat01/building-themes --name Guildborne_Building_Themes --max-triangles400 --large-assets. Verification: tools/verify_blender_kit.py --kit assets/uat01/building-themes. Pass flags separately, e.g. --max-triangles 400.

All Roblox mesh/image/product IDs remain unbound or0. Human free, Orc quest-earned and four paid placeholders are local implementation candidates. No purchases have been enabled.
