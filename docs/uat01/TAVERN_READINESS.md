# Tavern candidate review and readiness

The Tavern shows each candidate's name, class, role, rank, base stats, included equipped weapon, separate hiring fee and remaining Gold. Base stats are labeled separately from rank, level and equipment bonuses. Scout price comes from the catalog. Class odds and all rank odds remain visible.

Display-only readiness disables actions for insufficient Gold, full roster, expedition/recovery states, Hall/material/maximum-level requirements and a full equipment inventory that cannot hold the starting weapon. Existing server transactions still validate and commit every action; no odds, pricing, profile fields or rewards changed.

Replacing a candidate uses confirmation tied to the specific offer ID and includes a keep-current-candidate action. A changed offer or leaving the Tavern clears that confirmation. The previous scouting fee is explicitly nonrefundable.

All459 domain tests pass. Native fixtures passed56 views across all5classes,240/640px and English/Thai, including text bounds, focus/readiness and4 replace/cancel/stale-offer/hire callback cases. Fixtures never sent profile actions.

Actual fresh memory-only UI earned70Gold through Trail Watch and Timber Escort. Scouting cost20Gold and produced Knight/Bram/F at revision8/50Gold. Replace then Keep left revision8/50Gold/offer:1 unchanged. Hiring cost30Gold: revision9/20Gold, h:1 Knight F level1, equipped Account-bound knight_sword, offer removed. Read-only projection reported base40HP/4attack/7defense and equipped40HP/6attack/7defense, matching the base-stat and weapon descriptions. Screenshot tavern-candidate.png captures the upper candidate card; the compact viewport requires scrolling for the lower action.

These changes do not implement the proposed fifteen-template recruitment catalog, earned tickets, weekly rotation, Novice gate or live commerce. Physical mobile/controller, multiplayer and human UAT remain open.
