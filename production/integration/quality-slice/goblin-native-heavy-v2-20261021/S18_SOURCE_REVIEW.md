# V2 independent scoped review

Separate read-only reviewer `/root/goblin_export_review`; no Blender/Studio run.
PASS for heavy crown-only change and offline forward-reach vertex replay.

- Only two heavy arm payloads changed; other16 native files match v1 byte-for-byte.
- Each arm changes56 crown vertices, X only, maximum0.06000003 stud. Y/Z,
  topology, material indices and attachment metadata unchanged.
- Crown-only floating differences: UV<=8.95e-8, normals<=7.46e-7.
- Forward65 and100 degrees: each arm v1 had8 vertices inside torso; v2 has0.
  Replay uses recorded source limb centers, pivots and torso dimensions.
- All36 v2 roundtrip hashes match; maximum bounds error1.79e-7.
- All v2 authored-report hashes match; protected v1 builder/artifact hashes unchanged.

This is local vertex sampling/replay, not exact triangle clearance, all-motion
acceptance or fresh native testing. Ritual, boots, slash, art parity and other
equipment behavior remain pending as described in NATIVE_STATUS_V2.md.
