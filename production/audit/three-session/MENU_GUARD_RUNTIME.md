# Menu adapter guard runtime — 2026-10-17

S14 c0293f48bfe3d1b45d35d1ff1b15182eab025c83 independently reviewed and integrated as0bb0fb5. Shared v4 ledger showed gameplay-ui-quality released before integration. Current GUI harness passed43cases. The worker's full899baseline applies to its follow-up source; controller's previous combined899baseline predates this guard and is not relabeled.

Earned Memory Studioa6d25956 received uniquely named client-only review4 CityNavigation/PlayerCombatController and GameplayMenuGate; it reused reviewed3 Chrome/QuestRoute/WaypointBeacon. Existing GUI destruction disconnected old controllers before replacement. Actual server/profile/progression logic remained unchanged.

With Management visible, a temporary server listener observed real CombatIntent.OnServerEvent events for the test player without intercepting or modifying them. Initial count0. Ordinary N,F,Q,R,G,T input left Management true, Map false and combat health/buttons/selection false. Server count stayed0. Closing Management through the actual Guild menu toggle and pressing F produced exactly one observed Basic intent, proving the observer was live and the gate reopened. N then opened Map. A second N closed it; Management false,Map false and all three combat HUD groups visible. This verifies keyboard negative/positive controls in the previously affected independently loaded adapter environment, not physical input devices or every touch/gamepad path.

Disconnected and destroyed ControllerMenuDispatchProbe; server readback confirmed it absent. No signals were fabricated, direct remotes fired, or currency/rewards/profile/positions written. The single ordinary Basic input is not a successful-hit or reward claim.

Fresh whole-build behavior before this follow-up already hid combat correctly; see COMPOSITION_PARTY_RUNTIME.md. This guard is resilience to independently loaded presentation adapters, not proof of a pre-existing clean-build regression. Fresh whole-build follow-up, other menu owners, touch/gamepad and long-session stale-flag behavior remain separate gates.
