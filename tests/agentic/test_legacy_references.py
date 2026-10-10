"""Reconcile the existing semicolon reference representation without rewriting source data."""
from pathlib import Path
import copy
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools/agentic'))
import forge
import reconcile
import asset_jobs


class LegacyReferenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.plan = forge.read_json(ROOT/'production/plan.json')
        self.kit = forge.read_json(ROOT/'production/character-kit-v1/catalog.json')
        self.aliases = forge.read_json(ROOT/'production/character-kit-v1/aliases.json')

    def reconcile(self, source, kind='asset'):
        row = {'designId':'ui.test', 'source':source, 'uatApproved':False}
        registry = {'assets':[row] if kind == 'asset' else [], 'screens':[row] if kind == 'screen' else []}
        before = copy.deepcopy(registry)
        report = reconcile.reconcile(self.root, registry, self.kit, self.plan, self.aliases)
        self.assertEqual(registry, before)
        self.assertFalse(report['entries'][0]['uatApprovedByReconciliation'])
        return report

    def write(self, relative):
        path = self.root/relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('fixture', encoding='utf-8')

    def test_semicolon_source_list_hashes_each_existing_file(self):
        self.write('assets/a.glb'); self.write('src/a.luau'); self.write('docs/a.json')
        report = self.reconcile('assets/a.glb; src/a.luau; docs/a.json')
        self.assertEqual(report['counts']['filesHashed'], 3)
        self.assertEqual(report['missingReferences'], [])
        self.assertEqual(len(report['entries'][0]['files']), 3)

    def test_missing_member_is_reported_individually(self):
        self.write('src/a.luau')
        report = self.reconcile('src/a.luau; assets/missing.glb')
        self.assertEqual(report['counts']['filesHashed'], 1)
        self.assertEqual(report['missingReferences'], [{'id':'asset:ui.test','path':'assets/missing.glb'}])

    def test_directory_reference_is_not_a_fake_file_or_recursive_approval(self):
        (self.root/'assets/set').mkdir(parents=True)
        self.write('docs/a.md')
        report = self.reconcile('assets/set/; docs/a.md')
        row = report['entries'][0]
        self.assertEqual(report['missingReferences'], [])
        self.assertEqual(report['counts']['filesHashed'], 1)
        self.assertEqual(row['directories'], [{'path':'assets/set','verifiedHere':'DIRECTORY_EXISTS_ONLY'}])
        self.assertEqual(row['action'], 'REVIEW_EXISTING_BEFORE_GENERATION')

    def test_directory_only_job_requires_rework_approval(self):
        (self.root/'assets/set').mkdir(parents=True)
        report = self.reconcile('assets/set/')
        with self.assertRaises(ValueError):
            asset_jobs.prepare(self.root, report, 'asset:ui.test')
        job = asset_jobs.prepare(self.root, report, 'asset:ui.test', allow_rework=True)
        self.assertEqual(job['existingSourceDirectories'], ['assets/set'])
        self.assertFalse(job['runtimeImported'])
        (self.root/'assets/set').rmdir()
        with self.assertRaises(ValueError):
            asset_jobs.prepare(self.root, report, 'asset:ui.test', allow_rework=True)

    def test_delimited_traversal_is_still_rejected(self):
        with self.assertRaises(ValueError):
            self.reconcile('docs/a.md; ../outside.png')
        with self.assertRaises(ValueError):
            self.reconcile('docs/a.md; assets/../outside/')

    def test_nested_reference_lists_deduplicate_paths(self):
        self.write('src/a.luau')
        report = self.reconcile({'native':['src/a.luau; src/a.luau', {'other':'src/a.luau'}]})
        self.assertEqual(report['counts']['filesHashed'], 1)
        self.assertEqual(len(report['entries'][0]['files']), 1)

    def test_existing_theme_and_trial_entries_have_explicit_work_packages(self):
        for key, package in (('launch.hall_themes.hall_elf_lv1','guild-islands'),
                             ('launch.utility_themes.theme_orc','guild-islands'),
                             ('asset.novice.trial.sentinel','monsters'),
                             ('asset.novice.trial.patient','npc-life'),
                             ('asset.novice.trial.court','city-zones')):
            self.assertEqual(reconcile.routing({'designId':key}, 'asset'), package)


if __name__ == '__main__':
    unittest.main()
