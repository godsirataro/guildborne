# Nonoverlapping ground native review

Disposable Studio155918dd was stopped; exact NoviceRoadArt source SHA256
3ccd43ed4baa7b838ad4d188ed7952018adcbe33d830e01023af3730ed6071c4 was copied
to ServerScriptService.Server.Services.NoviceRoadArt in Edit. Full source equality
readback passed (29118 characters); Play restarted. This is original3bddf9e
candidate plus this source replacement, not the latest combined source candidate.
Earned def49833/62789207 sessions were preserved.

Initial probe failed at Settlement_GroundUnion_54 because it checked all eight
bounding-box corners of a WedgePart. Runtime vertex readback and independent
review confirmed the two reported corners are empty space. Corrected only that
shape's corner enumeration, retaining six actual vertices and unchanged bounds/
tolerance. Other shapes still receive all eight conservative corners. No geometry
was changed to appease the test. Probe compiles and corrected native run passes:
645parts,582visible,61colliders,15markers and25 engine paths/four runtime anchors.
Failed receipt, diagnosis and successful summary remain in ground645-native-v5.json.

Ordinary native Continue/Explore and WASD walks visited arrival, courier shelter,
training yard and caravan, ending near(-4560.886,2.998,31.498). Tool-visible captures
ground645_arrival_walk, ground645_courier_walk, ground645_training_walk and
ground645_caravan_walk show the checked ground without the previous dashed dark
seam/flecks. Static orange training warning remains visible. No separately saved
PNG or video is claimed, and snapshots cannot certify all temporal artifacts.

This is bounded repair acceptance for the observed ground views and paths.
The world still has broad flat/empty areas and primitive props; it is not final
custom art approval. Dynamic telegraphs, both caravan quest branches on this
candidate, eight-owner performance, physical devices and full-game play remain
separate. Stop/release the disposable review before the coordinated v6 plan change.
