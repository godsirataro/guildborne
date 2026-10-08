from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest market response and empty-state checkpoint — 2026-10-02

Fixed MarketView request races: old timeout/reply cannot unlock or overwrite a newer request; current late response can recover after timeout. Missing/mismatched item/period/page snapshots hide stale prices. Pending navigation/buttons/input are disabled. Safe requestId now echoed on InvalidRequest. No automatic mutation retry. RequestWindow pure regressions+entire domain suite330PASS including5000orders. Studio cloned UI/isolate RemoteEvents:2Read requests, old response rejected, wrong-item prices hidden, timeout recovers, late timber price22correct. No real transactions or profile writes.

Eight original empty-state SVG/native symbols bring total50. Shared EmptyState provides responsive EN/TH heading/detail and no actions. Five variants integrated: emptyinventory,emptyparty,nosearchresults,nomarketorders,offlineunavailable; quest/guild/locked candidates remain unbound. Inventory empty branch passed. Market search FocusLost/reset and MyOrders pointer flows passed against synthetic data. MCP text input did not modify search; programmatic CaptureFocus/Text/ReleaseFocus used, so no keyboard acceptance claim.50symbols×3sizes1209primitivechecks;8emptycards×2widths×2languages32layoutcases no clipping. Screenshot empty-states-thai.png. Fixture cleanup completed and owned Play stopped.

Last quota80%used/20%remaining; continue toward15%.134runtimefiles; final build/strict/compile/repository log validation-empty-state-types.txt. Main release gates unchanged: local UAT not ready, cloud/livecommerce/human UAT pending. Source-ready art is not complete gameplay.

'''
p=docs/'HANDOFF.md';p.write_text(note+p.read_text(encoding='utf-8'),encoding='utf-8')
for name in ('STATUS.md','WORK_CHECKLIST.md'):
 p=docs/name;s=p.read_text(encoding='utf-8').replace('326domain tests','330domain tests').replace('validation is326 tests','validation is330 tests');p.write_text(s,encoding='utf-8')
p=root/'assets/uat01/ui-symbols/README.md';s=p.read_text(encoding='utf-8').replace('42 original','50 original').replace('twelve guild emblem components.','twelve guild emblem components and eight empty states.').replace('The remaining 39 symbols are candidates','Five empty-state variants also appear in Inventory, Party and Market views. The remaining 42 symbols are candidates').replace('42 symbols at 18/24/48px, 1,011','50 symbols at 18/24/48px, 1,209').replace('and `docs/uat01/ui-symbols.png`','and `docs/uat01/ui-symbols.png` (original42-symbol contact sheet); eight state samples appear in `docs/uat01/empty-states-thai.png`');p.write_text(s,encoding='utf-8')
for p in (root/'assets/uat01/GALLERY.md',docs/'ASSET_MANIFEST.md'):
 s=p.read_text(encoding='utf-8').replace('42 original SVG/native UI symbols','50 original SVG/native UI symbols');p.write_text(s,encoding='utf-8')
