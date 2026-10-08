# Resource gathering feedback

Local resource prompts now show the resource name and a server-snapshot-based countdown while gathering is on cooldown. The ordinary label and Gather prompt return when the countdown expires. Loading/recovery, blocking menus, foreign guild nodes and unowned guild nodes disable the local prompt. The server remains authoritative for gathering, cooldowns and inventory.

The controller handles late-added and removed nodes and restores original prompt/label states during cleanup. Unknown resource IDs are untouched; originally disabled prompts stay disabled. English and Thai labels share the existing localization system.

Native isolated checks passed for loading/recovery, ownership, unknown nodes, originally disabled prompts, countdown expiry, bilingual text, late nodes, removal and idempotent cleanup. The actual fresh memory-only client gathered timber through keyboard input: a six-second combined label appeared, the base label was hidden and the prompt disabled; both were restored after expiry. Debug movement only shortened the approach. See validation-resource-markers-native.json and resource-cooldown.png.

Physical mobile, multiplayer and full menu/input acceptance remain open. No production profile, remote asset ID or reward rule changed.
