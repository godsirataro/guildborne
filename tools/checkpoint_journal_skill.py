from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest journal, skill and navigation checkpoint — 2026-10-02

Journal has All/Available/Active/Ready/Claimed filters, an original empty-state illustration and Show all reset. NPC/HUD focus resets the filter so the target is visible. Claimed item objectives remain complete after turn-in consumes their items; active objectives still use current inventory. No reward rule changed. Synthetic EN/TH240/640px checks cover28filter counts, stock changes, claimed/no-repeat-action, empty/reset, focus and busy gates. Domain335PASS including5,000market-order soak0invariant violations.

Skill tree and detail buttons now share the server learning predicates: prerequisite, tier, points, exclusive branch, learned and blocked states. Server derives and checks its own current build.160UIchecks across8states/two widths/two languages passed. Existing authoritative command tests plus two new predicate tests passed. Five class marks bind to roster, player card and skill header;20class-badge checks passed. Six district symbols bind to city map with24text/geometry checks; input/remote connections now disconnect on navigation UI destruction. All probes are synthetic and do not spend/reward/change the ordinary profile.

53native/SVG symbols now have23integrated variants and30binding candidates. The19generated PNGs,239asset design records,65screen records and28work areas are separately tracked in the updated four-sheet Excel registry. Counts do not establish completion or UAT approval. Main139runtimefiles after adding SkillAvailability,JournalViewState,ClassBadge. Last quota82%used/18%remaining. Stop new work at85%used. Local UAT NOT READY; human UAT NO; live platform PENDING; commerce DISABLED; public release NO.

'''
p=docs/'HANDOFF.md';s=p.read_text(encoding='utf-8');p.write_text(note+s if not s.startswith(note.splitlines()[0]) else s,encoding='utf-8')
for name in ['STATUS.md','WORK_CHECKLIST.md']:
 p=docs/name;s=p.read_text(encoding='utf-8').replace('330domain','335domain').replace('is330 tests','is335 tests').replace('last observed19% remaining','last observed18% remaining')
 if name=='STATUS.md':s=s.replace('Latest: live camp/Tower','Latest: journal filters/claimed-item progress, unified skill gates,6map+5class symbol bindings; live camp/Tower')
 else:s=s.replace('five-node tree; three stable learned-art slots','five-node tree with matching tree/detail/server gates; three stable learned-art slots').replace('15 Journal+3timed quests, prerequisites/goals;','15 Journal+3timed quests,5journal filters/empty reset/claimed-item completion,prerequisites/goals;')
 p.write_text(s,encoding='utf-8')
p=docs/'USAGE_STOP.md';p.write_text(p.read_text(encoding='utf-8').replace('81% used / 19% remaining','82% used / 18% remaining'),encoding='utf-8')
p=root/'assets/uat01/ui-symbols/README.md';s=p.read_text(encoding='utf-8').replace('Five empty-state variants','Six empty-state variants').replace('Inventory, Party and Market views','Inventory, Party, Market and Journal views').replace('remaining 42 symbols','remaining 30 symbols');s=s.replace('Focus, Regroup and Retreat are bound','Five class marks bind to roster/player/skill headers, and six district marks bind to CityNavigation. Focus, Regroup and Retreat are bound');p.write_text(s,encoding='utf-8')
