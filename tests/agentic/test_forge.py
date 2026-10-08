"""Production-tool tests only. They do not certify gameplay, Studio or model quality."""
from __future__ import annotations
from pathlib import Path
import struct
import sys
import tempfile
import unittest
import zlib

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/agentic'))
import forge
import generate_primitives as primitives
import import_character_kit as intake


def task(key='a', scope='assets/a', deps=(), env='local'):
    return dict(id=key, skill='guildborne-qa', title=key, brief='Test fixture',
                environment=env, dependsOn=list(deps), writeScopes=[scope], checks=['review'])


def plan(*tasks):
    return dict(schemaVersion=1, tasks=list(tasks) or [task()])


class ForgeTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)

    def ledger(self, spec=None):
        value = forge.Ledger(self.root / 'ledger.sqlite3', self.root, spec or plan())
        self.addCleanup(value.close)
        return value

    def packet(self, spec=None):
        spec = spec or task()
        f = self.root / 'evidence.txt'
        f.write_text('Synthetic test fixture, NOT real Studio evidence.\n')
        return dict(taskId=spec['id'], environment=spec['environment'], buildCommit='a'*40,
                    checks={'review':'PASS'}, artifacts=[{'path':'evidence.txt','sha256':forge.digest(f)}])

    def test_json_rejects_duplicate_and_nonfinite(self):
        f=self.root/'a.json'
        for text in ('{"a":1,"a":2}', '{"a":NaN}', '{"a":Infinity}'):
            f.write_text(text)
            with self.assertRaises(ValueError): forge.read_json(f)

    def test_json_roundtrip(self):
        f=self.root/'nested/a.json'; forge.save_json(f, {'ไทย':'ทดสอบ'})
        self.assertEqual(forge.read_json(f), {'ไทย':'ทดสอบ'})

    def test_paths_reject_escapes(self):
        for value in ('../x','/tmp/x','C:/x','a\\b','.git/config','~x','.',''):
            with self.subTest(value=value), self.assertRaises(ValueError): forge.relative_path(value)

    def test_symlink_escape_rejected(self):
        try: (self.root/'link').symlink_to(self.root.parent, target_is_directory=True)
        except OSError: self.skipTest('Symlink privilege unavailable')
        with self.assertRaises(ValueError): forge.inside(self.root,'link/outside')

    def test_scopes_are_windows_case_insensitive(self):
        self.assertTrue(forge.overlap('Assets/Character','assets/character/body.blend'))
        self.assertFalse(forge.overlap('assets/a','assets/ab'))

    def test_plan_valid_dag(self):
        self.assertEqual(len(forge.validate_plan(plan(task(),task('b','b',['a'])))),2)

    def test_plan_rejects_bad_dependencies(self):
        for spec in (plan(task(),task()),plan(task(deps=['missing'])),plan(task(deps=['a']))):
            with self.assertRaises(ValueError): forge.validate_plan(spec)

    def test_plan_rejects_bad_checks_and_scopes(self):
        for field,value in [('checks',[]),('checks',['a','a']),('writeScopes',['../escape']),('environment','production')]:
            spec=plan(); spec['tasks'][0][field]=value
            with self.subTest(field=field), self.assertRaises(ValueError): forge.validate_plan(spec)

    def test_dependencies_require_review_acceptance(self):
        l=self.ledger(plan(task(),task('b','b',['a'])))
        self.assertEqual(l.ready(),['a'])
        token=l.claim('a','writer'); l.submit('a',token,self.packet())
        self.assertEqual(l.ready(),[])
        l.accept('a','reviewer');self.assertEqual(l.ready(),['b'])

    def test_overlapping_writes_rejected(self):
        l=self.ledger(plan(task(),task('b','assets/a/sub')))
        l.claim('a','writer')
        with self.assertRaises(ValueError): l.claim('b','other')

    def test_disjoint_local_writes_allowed(self):
        l=self.ledger(plan(task(),task('b','assets/b')))
        self.assertNotEqual(l.claim('a','writer'),l.claim('b','other'))

    def test_studio_is_exclusive(self):
        l=self.ledger(plan(task(env='studio'),task('b','b',env='studio')))
        l.claim('a','writer')
        with self.assertRaises(ValueError): l.claim('b','other')

    def test_expired_workers_do_not_get_stolen(self):
        l=self.ledger(plan(task(),task('b','assets/a')))
        token=l.claim('a','old',now=0)
        with self.assertRaises(ValueError): l.claim('b','new')
        with self.assertRaises(ValueError): l.assert_lease('a',token)
        l.release('a',token); self.assertTrue(l.claim('b','new'))

    def test_stale_token_and_release_rejected(self):
        l=self.ledger();token=l.claim('a','writer')
        with self.assertRaises(ValueError): l.heartbeat('a','wrong')
        with self.assertRaises(ValueError): l.release('a','wrong')
        l.release('a',token)
        with self.assertRaises(ValueError): l.assert_lease('a',token)

    def test_reviewer_cannot_self_accept(self):
        l=self.ledger();token=l.claim('a','writer');l.submit('a',token,self.packet())
        with self.assertRaises(ValueError): l.accept('a','writer')
        l.accept('a','reviewer')
        with self.assertRaises(ValueError): l.accept('a','reviewer')

    def test_tampering_after_submission_rejected(self):
        l=self.ledger();token=l.claim('a','writer');l.submit('a',token,self.packet())
        (self.root/'evidence.txt').write_text('Modified evidence')
        with self.assertRaises(ValueError): l.accept('a','reviewer')

    def test_plan_change_requires_new_ledger(self):
        l=self.ledger()
        changed=plan();changed['tasks'][0]['brief']='different'
        with self.assertRaises(ValueError): forge.Ledger(self.root/'ledger.sqlite3',self.root,changed)

    def test_failed_missing_or_placeholder_evidence_rejected(self):
        for field,value in [('checks',{'review':'PENDING'}),('artifacts',[]),('buildCommit','0'*40),('environment','studio')]:
            packet=self.packet();packet[field]=value
            with self.subTest(field=field), self.assertRaises(ValueError): forge.evidence_packet(self.root,task(),packet)

    def test_cross_server_requires_distinct_nonempty_jobs(self):
        spec=task(env='cross_server');p=self.packet(spec)
        for ids in ([],['',''],['same','same'],'AB', [['bad'],['bad']]):
            p['serverJobIds']=ids
            with self.subTest(ids=ids),self.assertRaises(ValueError): forge.evidence_packet(self.root,spec,p)
        p['serverJobIds']=['server-a','server-b'];forge.evidence_packet(self.root,spec,p)

    def test_physical_device_requires_model(self):
        spec=task(env='device');p=self.packet(spec)
        with self.assertRaises(ValueError): forge.evidence_packet(self.root,spec,p)
        p['deviceModel']='Synthetic fixture';forge.evidence_packet(self.root,spec,p)

    def test_competing_connections_serialize_claim(self):
        spec=plan();a=self.ledger(spec);b=forge.Ledger(self.root/'ledger.sqlite3',self.root,spec);self.addCleanup(b.close)
        a.claim('a','first')
        with self.assertRaises(ValueError): b.claim('a','second')

    def test_ttl_range(self):
        l=self.ledger()
        for ttl in (0,29,7201,float('inf'),float('nan')):
            with self.subTest(ttl=ttl), self.assertRaises(ValueError): l.claim('a','writer',ttl=ttl)

    def test_inventory_is_metadata_only(self):
        (self.root/'src').mkdir(); (self.root/'src/a.luau').write_text('--not executed')
        value=forge.inventory(self.root)
        self.assertEqual(value['files'],[{'path':'src/a.luau','bytes':14}])


class ProductionTests(unittest.TestCase):
    def test_repository_skills_and_task_plan(self):
        spec=forge.read_json(ROOT/'production/plan.json')
        self.assertEqual(len(forge.validate_plan(spec)),28)
        self.assertEqual(forge.validate_skills(ROOT,spec),21)

    def test_normalized_original_kit(self):
        data=forge.read_json(ROOT/'production/character-kit-v1/catalog.json')
        self.assertEqual(len(data['assets']),89)
        self.assertEqual(len(data['bodyPresets']),13)
        self.assertEqual(len(data['skinPalettes']),20)
        self.assertEqual(len({x[0] for x in data['assets']}),89)
        self.assertIsNone(data['robloxAssetIds'])
        self.assertFalse(data['runtimeImported'])
        self.assertEqual(data['originArchiveSha256'],intake.EXPECTED_SHA256)

    def test_wrong_archive_rejected_before_extract(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);f=root/'wrong.zip';f.write_bytes(b'not a reviewed archive')
            with self.assertRaises(ValueError):intake.import_kit(f,root)
            self.assertFalse((root/'production/character-kit-v1/original').exists())

    def test_png_structure_crc_alpha_and_sequence(self):
        data=primitives.effect_sheet('fire',16)
        self.assertEqual(data[:8],b'\x89PNG\r\n\x1a\n')
        offset=8; compressed=b''
        while offset<len(data):
            size=struct.unpack('>I',data[offset:offset+4])[0]
            kind=data[offset+4:offset+8];body=data[offset+8:offset+8+size]
            crc=struct.unpack('>I',data[offset+8+size:offset+12+size])[0]
            self.assertEqual(crc,zlib.crc32(kind+body)&0xffffffff)
            if kind==b'IDAT':compressed+=body
            offset+=size+12
        raw=zlib.decompress(compressed);width=64
        rows=[raw[y*(width*4+1)+1:(y+1)*(width*4+1)] for y in range(width)]
        for y in range(16):self.assertFalse(any(rows[y][3:16*4:4]))
        self.assertTrue(any(rows[20][16*4+3:32*4:4]))
        for y in range(48,64):self.assertFalse(any(rows[y][48*4+3:64*4:4]))
        self.assertEqual(data,primitives.effect_sheet('fire',16))

    def test_generated_manifest_truthful_and_complete(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);assets=primitives.generate(root,16)
            self.assertEqual(len(assets),6)
            for a in assets:
                self.assertEqual(a['sha256'],forge.digest(root/a['source']))
                self.assertIsNone(a['robloxAssetId'])
                self.assertEqual(a['status'],'PROCEDURAL_PREVIEW')

    def test_png_bad_inputs(self):
        for args in [(0,1,b''),(1,1,b''),(5000,1,b'')]:
            with self.assertRaises(ValueError):primitives.png(*args)
        with self.assertRaises(ValueError):primitives.effect_sheet('unknown')
        with self.assertRaises(ValueError):primitives.effect_sheet('fire',2)


if __name__=='__main__':unittest.main()
