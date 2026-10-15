# Team combo design
Status: PROPOSED; runtime effects NOT IMPLEMENTED.

Start with one reviewed role interaction rather than all five named concepts. First candidate follows the requested Knight + Mage + Archer team: owned Knight lands an existing valid taunt, Mage resolves positive fireball damage, then Archer resolves piercing_shot on the same eligible enemy generation inside the taunt window. First experiment measures completion/readability using existing actions before any bonus damage or status is approved. Manual final activation, cancellation semantics and one-time consumption need explicit tests.

The proposal's Knight→Mage area→Archer weak-point sequence assumes effects not currently supplied by Class1 fireball/piercing_shot. Do not label those abilities AoE/weak-point without implementing and testing them. Elemental Volley, Holy Stand, Hunter's Mark and Arcane Barrier remain catalog proposals.

Define window, per-owner/team cooldown, target generation, cancellation and boss immunity in a reviewable balance table before damage-changing implementation. Events must represent effects that actually resolved, not input or animation markers. Each target generation can consume a setup once; cancellation/death/travel removes stale setup. No overlapping owner IDs or cross-party proof reuse. Solo owner with NPCs must be able to perform the interaction.

Dependencies: stable tactics, effective-action observation, existing authoritative damage/ability code, original animation/VFX/audio. Acceptance includes no duplicate proc under replay, failed taunt/out-of-range/blocked hit gives no combo, unchanged reward authority, readable low-graphics cues and human UAT. Runtime flag stays off until those effects are concrete; no reward or persistent field added by this design.
