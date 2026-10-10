"""V2 adversarial tests. IPC workers are fixtures, never real Studio/Codex proof."""
from pathlib import Path
import copy
import json
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/agentic'))
import forge
import git_evidence as ge
import reconcile as rec
import content_graph as graph
import character_contract as char
import mcp_probe as mcp
import run_worker as worker
import record_check
import asset_jobs
import blender_job
import generate_primitives


def sample_task(env='local'):
    return {'id':'a','skill':'test-worker','environment':env,'dependsOn':[],
            'writeScopes':['work'],'checks':['checks'],'title':'Fixture','brief':'Fixture only'}


class GitFixture(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        (self.root/'production').mkdir();(self.root/'.agents/skills/test-worker').mkdir(parents=True)
        (self.root/'.agents/skills/test-worker/SKILL.md').write_text('---\nname: test-worker\ndescription: Fixture only\n---\nNo models called.\n')
        self.plan={'schemaVersion':1,'tasks':[sample_task()]}
        forge.save_json(self.root/'production/plan.json',self.plan)
        (self.root/'.gitignore').write_text('build/\n')
        (self.root/'AGENTS.md').write_text('Fixture.')
        (self.root/'production/LATEST_GOALS.md').write_text('Fixture.')
        subprocess.run(['git','init','-q',str(self.root)],check=True)
        self.commit()
        self.sha=ge.head(self.root)

    def commit(self):
        subprocess.run(['git','-C',str(self.root),'add','.'],check=True)
        subprocess.run(['git','-C',str(self.root),'-c','user.name=Fixture','-c','user.email=fixture@example.invalid',
                        'commit','-qm','fixture'],check=True)

    def packet(self):
        p=self.root/'build/agentic/check.txt';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('Fixture invocation, not Studio.\n')
        return {'taskId':'a','environment':'local','buildCommit':self.sha,
                'sourceTree':ge.validate_commit(self.root,self.sha),'checks':{'checks':'PASS'},
                'planSha256':ge.plan_hash(self.plan),
                'invocation':{'tool':'fixture','runId':'fixture-1','buildCommit':self.sha,'exitCode':0,'logs':['build/agentic/check.txt']},
                'artifacts':[{'path':'build/agentic/check.txt','sha256':forge.digest(p)}]}

    def test_unknown_commit_rejected(self):
        p=self.packet();p['buildCommit']='f'*40
        with self.assertRaises(ValueError):forge.evidence_packet(self.root,sample_task(),p)

    def test_tree_is_not_commit(self):
        with self.assertRaises(ValueError):ge.validate_commit(self.root,ge.validate_commit(self.root,self.sha))

    def test_other_real_commit_is_not_current_build(self):
        (self.root/'file.md').write_text('next');self.commit()
        with self.assertRaises(ValueError):ge.validate_commit(self.root,self.sha)

    def test_dirty_tracked_source_rejected(self):
        p=self.packet();(self.root/'AGENTS.md').write_text('changed')
        with self.assertRaises(ValueError):forge.evidence_packet(self.root,sample_task(),p)

    def test_untracked_source_rejected(self):
        (self.root/'other.lua').write_text('return 1')
        with self.assertRaises(ValueError):ge.clean_source(self.root)

    def test_wrong_source_tree_rejected(self):
        p=self.packet();p['sourceTree']='f'*40
        with self.assertRaises(ValueError):forge.evidence_packet(self.root,sample_task(),p)

    def test_invocation_requires_exact_build_logs_and_exit(self):
        for field,value in [('exitCode',False),('exitCode',1),('buildCommit','f'*40),('logs',[]),('logs',['missing.txt']),('runId','../escape')]:
            p=self.packet();p['invocation'][field]=value
            with self.subTest(field=field,value=value),self.assertRaises(ValueError):forge.evidence_packet(self.root,sample_task(),p)

    def test_plan_fingerprint_rejected(self):
        ledger=forge.Ledger(self.root/'build/agentic/ledger.sqlite3',self.root,self.plan)
        try:
            token=ledger.claim('a','writer');p=self.packet();p['planSha256']='f'*64
            with self.assertRaises(ValueError):ledger.submit('a',token,p)
        finally:ledger.close()

    def test_record_check_captures_actual_success(self):
        value=record_check.record(self.root,[sys.executable,'-c','print("fixture check")'],approved=True)
        self.assertEqual(value['status'],'COMMAND_PASS_NOT_TASK_ACCEPTANCE')
        self.assertEqual(value['buildCommit'],self.sha);self.assertFalse(value['humanApproved'])
        for a in value['artifacts']:self.assertEqual(a['sha256'],forge.digest(self.root/a['path']))

    def test_record_check_failure_never_passes(self):
        value=record_check.record(self.root,[sys.executable,'-c','raise SystemExit(7)'],approved=True)
        self.assertEqual(value['status'],'FAIL');self.assertEqual(value['invocation']['exitCode'],7)

    def test_record_check_requires_approval(self):
        with self.assertRaises(ValueError):record_check.record(self.root,[sys.executable,'-c','print(1)'])

    def test_worker_no_approval_or_missing_capability(self):
        with self.assertRaises(ValueError):worker.run(self.root,'a','not-used',self.root/'build/agentic/ledger.sqlite3')
        self.plan['tasks'][0]['environment']='studio';forge.save_json(self.root/'production/plan.json',self.plan);self.commit()
        with self.assertRaisesRegex(ValueError,'local-code-only'):
            worker.run(self.root,'a','not-used',self.root/'build/agentic/ledger.sqlite3',authorized=True)

    def invoke(self,code):
        def call(argv,prompt,root,out,timeout,heartbeat):
            self.assertIn('--sandbox',argv);self.assertNotIn('--dangerously-bypass-approvals-and-sandbox',argv)
            return worker.run_process([sys.executable,'-c',code],prompt,root,out,timeout,heartbeat)
        return call

    def test_real_fixture_process_and_review_only_result(self):
        result=worker.run(self.root,'a','codex-fixture',self.root/'build/agentic/ledger.sqlite3',authorized=True,
            invoke=self.invoke('import sys; assert "Fixture only" in sys.stdin.read(); print("fixture")'))
        self.assertEqual(result['status'],'REVIEW_CANDIDATE_NOT_ACCEPTED')
        self.assertTrue((self.root/'build/agentic/runs'/result['runId']/'lease.json').exists())
        ledger=forge.Ledger(self.root/'build/agentic/ledger.sqlite3',self.root,self.plan)
        try:self.assertEqual(ledger.rows()[0]['state'],'ACTIVE')
        finally:ledger.close()

    def test_worker_detects_out_of_scope_edit(self):
        result=worker.run(self.root,'a','fixture',self.root/'build/agentic/ledger.sqlite3',authorized=True,
            invoke=self.invoke('from pathlib import Path; Path("AGENTS.md").write_text("changed")'))
        self.assertEqual(result['status'],'BLOCKED_SCOPE_VIOLATION')

    def test_worker_bounded_retries_and_explicit_resume(self):
        path=self.root/'build/agentic/ledger.sqlite3'
        result=worker.run(self.root,'a','fixture',path,authorized=True,attempts=2,invoke=self.invoke('raise SystemExit(1)'))
        self.assertEqual(result['status'],'FAILED_RETRY_LIMIT');self.assertEqual(len(result['attempts']),2)
        with self.assertRaises(ValueError):worker.run(self.root,'a','fixture',path,authorized=True,resume_run=result['runId'])
        again=worker.run(self.root,'a','fixture',path,authorized=True,resume_run=result['runId'],confirmed_stopped=True,
                         invoke=self.invoke('print("resumed fixture")'))
        self.assertEqual(len(again['attempts']),3);self.assertEqual(again['status'],'REVIEW_CANDIDATE_NOT_ACCEPTED')

    def test_worker_timeout_stops_owned_process(self):
        with self.assertRaises(TimeoutError):worker.run_process([sys.executable,'-c','import time;time.sleep(10)'],
            'fixture',self.root,self.root/'build/agentic/time',.1,lambda:None)


class ReconciliationTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
        self.plan=forge.read_json(ROOT/'production/plan.json');self.kit=forge.read_json(ROOT/'production/character-kit-v1/catalog.json')
        self.aliases=forge.read_json(ROOT/'production/character-kit-v1/aliases.json')

    def test_existing_sources_and_screen_candidates_are_hashed_not_regenerated(self):
        p=self.root/'src/client/UI/Test.luau';p.parent.mkdir(parents=True);p.write_text('return {}')
        reg={'assets':[{'designId':'ui.brand.logo','group':'brand','source':{'native':p.relative_to(self.root).as_posix()},'uatApproved':False}],
             'screens':[{'designId':'screen.test','scope':'UAT01','implementationCandidate':p.relative_to(self.root).as_posix()}]}
        before=copy.deepcopy(reg);r=rec.reconcile(self.root,reg,self.kit,self.plan,self.aliases)
        self.assertEqual(r['counts']['filesHashed'],1);self.assertEqual(reg,before)
        for row in r['entries'][:2]:
            self.assertFalse(row['uatApprovedByReconciliation']);self.assertEqual(row['action'],'REVIEW_EXISTING_BEFORE_GENERATION')
        self.assertTrue(r['sharedContentCandidates'])

    def test_missing_paths_and_native_null_ids_remain_explicit(self):
        r=rec.reconcile(self.root,{'assets':[{'designId':'ui.frame','source':{'image':'assets/missing.png'},'robloxAssetId':None}],
            'screens':[]},self.kit,self.plan,self.aliases)
        self.assertEqual(r['counts']['missingReferences'],1);self.assertIsNone(r['entries'][0]['robloxAssetId'])

    def test_registry_duplicate_and_traversal_rejected(self):
        for assets in [[{'designId':'x'},{'designId':'X'}],[{'designId':'x','source':{'image':'../outside.png'}}]]:
            with self.assertRaises(ValueError):rec.reconcile(self.root,{'assets':assets,'screens':[]},self.kit,self.plan,self.aliases)

    def test_all_existing_registry_rows_are_preserved(self):
        source=ROOT/'docs/uat01/intake/registry-reconciled.json'
        if not source.exists():self.skipTest('Full repository checkout required')
        reg=forge.read_json(source);before=forge.digest(source)
        r=rec.reconcile(ROOT,reg,self.kit,self.plan,self.aliases)
        self.assertEqual(r['counts']['assets'],len(reg['assets']));self.assertEqual(r['counts']['screens'],len(reg['screens']))
        self.assertEqual(len(r['entries']),len(reg['assets'])+len(reg['screens'])+89)
        self.assertEqual(forge.digest(source),before)

    def test_inventory_new_extensions_and_hashes(self):
        p=self.root/'assets';p.mkdir()
        for ext in ['svg','gltf','csv','xlsx','webp']:(p/('file.'+ext)).write_bytes(b'fixture bytes')
        r=forge.inventory(self.root,hash_files=True);self.assertEqual(len(r['files']),5)
        self.assertTrue(all(len(x['sha256'])==64 for x in r['files']))

    def test_character_catalog_and_aliases(self):
        assets,presets=char.validate(self.kit,self.aliases)
        self.assertEqual(len(assets),89);self.assertEqual(len(presets),13);self.assertEqual(len(char.PARTS),15)
        self.assertEqual(self.aliases['HEAD_HUMAN_01'],'CHR_HEAD_HUMAN_01')
        self.assertTrue(all(not r['compatible'] and r['evidence'] is None for r in char.fit_matrix(self.kit)))

    def test_unknown_character_alias_and_bad_skin_rejected(self):
        with self.assertRaises(ValueError):char.validate(self.kit,{'unknown':'MISSING'})
        bad=copy.deepcopy(self.kit);bad['skinPalettes'][0]['colorHex']='red'
        with self.assertRaises(ValueError):char.validate(bad,self.aliases)


class GraphTests(unittest.TestCase):
    def test_valid_quest_and_skill_graph(self):
        self.assertEqual(graph.validate([{'id':'a'},{'id':'b','requires':['a']}])['order'],['a','b'])
        self.assertEqual(graph.validate([{'id':'a','cost':1},{'id':'b','cost':2,'requires':['a']}],kind='skill')['nodes'],2)

    def test_missing_cycle_duplicate_and_bad_level_rejected(self):
        for nodes in [[{'id':'a','requires':['b']}],[{'id':'a','requires':['a']}],[{'id':'a'},{'id':'a'}],[{'id':'a','level':True}]]:
            with self.assertRaises(ValueError):graph.validate(nodes)

    def test_transitive_main_paywall_rejected(self):
        with self.assertRaises(ValueError):graph.validate([{'id':'a','requiresPayment':True},{'id':'b','main':True,'requires':['a']}])

    def test_hall_permit_direct_and_transitive_deadlock(self):
        for nodes in [[{'id':'a','unlocksHall':1,'level':11}],
                      [{'id':'a','level':35},{'id':'b','requires':['a'],'unlocksHall':4}]]:
            with self.assertRaises(ValueError):graph.validate(nodes)
        graph.validate([{'id':'hall4','unlocksHall':4,'level':30,'hall':3}])

    def test_skill_mutual_exclusion_and_receipt(self):
        with self.assertRaises(ValueError):graph.validate([{'id':'a','cost':1,'exclusiveGroup':'g'},
          {'id':'b','cost':1,'exclusiveGroup':'g'},{'id':'c','cost':1,'requires':['a','b']}],kind='skill')
        with self.assertRaises(ValueError):graph.validate([{'id':'a','reward':{'gold':1}}])


class AssetJobTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
        self.row={'id':'asset:ui.test','designId':'ui.test','kind':'asset','workPackage':'brand-art','files':[]}
        self.report={'entries':[self.row]}

    def test_provider_not_silently_called_or_ids_assigned(self):
        job=asset_jobs.prepare(self.root,self.report,'asset:ui.test')
        self.assertIsNone(job['provider']);self.assertFalse(job['runtimeImported'])
        self.assertEqual(job['state'],'AWAITING_VERIFIED_PROVIDER')

    def test_existing_asset_requires_review_and_rework_consent(self):
        p=self.root/'test.png';p.write_bytes(generate_primitives.effect_sheet('fire',16))
        self.row['files']=[{'path':'test.png','sha256':forge.digest(p)}]
        with self.assertRaises(ValueError):asset_jobs.prepare(self.root,self.report,'asset:ui.test')
        asset_jobs.prepare(self.root,self.report,'asset:ui.test',allow_rework=True)
        p.write_bytes(b'changed')
        with self.assertRaises(ValueError):asset_jobs.prepare(self.root,self.report,'asset:ui.test',allow_rework=True)

    def test_interactive_screen_is_not_an_image_job(self):
        self.row['kind']='screen'
        with self.assertRaises(ValueError):asset_jobs.prepare(self.root,self.report,'asset:ui.test')

    def test_png_candidate_records_provenance_without_uat_approval(self):
        p=self.root/'fire.png';p.write_bytes(generate_primitives.effect_sheet('fire',16))
        job=asset_jobs.prepare(self.root,self.report,'asset:ui.test')
        result=asset_jobs.inspect_candidate(self.root,job,'fire.png',{'origin':'procedural','tool':'fixture','rights':'project-authored'})
        self.assertTrue(result['image']['hasAlphaChannel']);self.assertFalse(result['uatApproved'])
        self.assertIsNone(result['robloxAssetId']);self.assertFalse(result['rightsVerified'])
        with self.assertRaises(ValueError):asset_jobs.inspect_candidate(self.root,job,'fire.png',{})

    def test_corrupt_png_never_accepted(self):
        p=self.root/'bad.png';p.write_bytes(generate_primitives.effect_sheet('fire',16)[:-8])
        with self.assertRaises(ValueError):asset_jobs.inspect_png(p)

    def test_blender_source_and_approval_required(self):
        with self.assertRaises(ValueError):blender_job.audit(self.root,'fixture','x.blend','0'*64,'Body')
        with self.assertRaises(ValueError):blender_job.audit(self.root,'fixture','x.blend','0'*64,'Body',approved=True)
        cmd=blender_job.command('blender',Path('source.blend'),Path('audit.py'),'Body',Path('report.json'))
        self.assertLess(cmd.index('--disable-autoexec'),cmd.index('source.blend'))
        self.assertNotIn('--enable-autoexec',cmd)


MCP_FIXTURE='''import sys,json
for line in sys.stdin:
 r=json.loads(line)
 if "id" not in r: continue
 m=r.get("method")
 if m=="initialize": result={"protocolVersion":"2024-11-05","serverInfo":{"name":"FIXTURE_NOT_ROBLOX"}}
 elif m=="tools/list":
  result={"tools":[{"name":"get_studio_state","inputSchema":{"type":"object"}}]} if r["params"].get("cursor") else {"tools":[{"name":"list_roblox_studios","inputSchema":{"type":"object"}}],"nextCursor":"next"}
 elif m=="tools/call": result={"content":[{"type":"text","text":"fixture"}]}
 else: result={}
 print(json.dumps({"jsonrpc":"2.0","id":r["id"],"result":result}),flush=True)
'''


class MCPTests(unittest.TestCase):
    def test_actual_stdio_handshake_pagination_read_and_cleanup(self):
        c=mcp.StdioClient([sys.executable,'-u','-c',MCP_FIXTURE])
        try:
            r=c.discover();self.assertEqual(len(r['tools']),2);self.assertEqual(r['serverInfo']['name'],'FIXTURE_NOT_ROBLOX')
            self.assertIn('content',c.call_read('get_studio_state'))
            with self.assertRaises(ValueError):c.call_read('execute_luau')
        finally:c.close()
        self.assertIsNotNone(c.process.poll())

    def test_process_eof_not_reported_connected(self):
        c=mcp.StdioClient([sys.executable,'-c','pass'])
        try:
            with self.assertRaises(ValueError):c.discover()
        finally:c.close()

    def test_invalid_stdio_and_unknown_version_rejected(self):
        for source in ['print("not JSON",flush=True)',MCP_FIXTURE.replace('2024-11-05','2099-01-01')]:
            c=mcp.StdioClient([sys.executable,'-u','-c',source])
            try:
                with self.assertRaises(ValueError):c.discover()
            finally:c.close()


if __name__=='__main__':unittest.main()
