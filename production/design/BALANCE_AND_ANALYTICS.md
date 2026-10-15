# Balance and analytics
Status: LOCAL CONTRACT/TRACKER SLICE AUTHORIZED; observed results belong in evidence.

Reuse AnalyticsAdapter and the committed event pipeline. Keep audit/business events distinct from sanitized product metrics. Allowlist bounded fields; never export player/hero/encounter/receipt IDs, names, free text or credentials in metric payloads. Failures must not change combat or saved outcomes. External providers remain disabled.

Track independent per-session milestones: session ready, actual effective player combat, accepted owned-hero command, committed combat reward, class selection, Guild founding, recruitment and chapter claim. Rejoining advanced progress must not invent earlier milestone completions. Input acceptance is not hit confirmation; presentation events are not gameplay authority. Best-effort session observations are not exactly-once durable analytics.

Measure first-action/command latency and outcome rates only after real playtests; D1/D7 require an actual eligible cohort and elapsed days. No fabricated funnel percentages or competitor benchmark promise. Define population, sample size, build and missing data for each result.

Economy model inventories existing gold sources/sinks, materials, craft costs and repeatable rewards. Evaluate solo and shared-owner progression before changing rates. Current legacy earned XP remains intact. Exact shared XP, item remainder fairness and optional personal boost effects need separate approved balance tables. No purchases or telemetry deployment is enabled here.
