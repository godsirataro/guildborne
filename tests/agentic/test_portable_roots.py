"""Relative and Windows short-root regressions without weakening canonical asset paths."""
from contextlib import contextmanager
import os
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools/agentic'))
import forge
import generate_primitives
import record_check
import run_worker
import reconcile
import test_v2


@contextmanager
def within(path):
    original = Path.cwd()
    try:
        os.chdir(path)
        yield
    finally:
        os.chdir(original)


class PortableRootTests(unittest.TestCase):
    setUp = test_v2.GitFixture.setUp
    commit = test_v2.GitFixture.commit

    def test_relative_root_quiet_check_keeps_portable_receipt_paths(self):
        with within(self.root):
            result = record_check.record(Path('.'), [sys.executable, '-c', 'pass'], approved=True)
            record_check.verify(Path('.'), result)
        self.assertEqual(result['status'], 'COMMAND_PASS_NOT_TASK_ACCEPTANCE')
        for artifact in result['artifacts']:
            self.assertNotIn('\\', artifact['path'])
            self.assertTrue((self.root/artifact['path']).is_file())

    def test_relative_root_worker_keeps_checkpoint_under_the_correct_checkout(self):
        def invoke(argv, prompt, root, out, timeout, heartbeat):
            self.assertEqual(root, self.root.resolve())
            return run_worker.run_process([sys.executable, '-c', 'print("fixture")'],
                                          prompt, root, out, timeout, heartbeat)
        with within(self.root):
            result = run_worker.run(Path('.'), 'a', 'fixture', Path('build/agentic/relative.sqlite3'),
                                    authorized=True, invoke=invoke)
        self.assertEqual(result['status'], 'REVIEW_CANDIDATE_NOT_ACCEPTED')
        relative = result['attempts'][0]['path']
        self.assertNotIn('\\', relative)
        self.assertTrue((self.root/relative/'events.jsonl').is_file())

    def test_relative_root_primitives_manifest_has_existing_canonical_paths(self):
        with within(self.root):
            assets = generate_primitives.generate(Path('.'), 16)
        self.assertEqual(len(assets), 6)
        for item in assets:
            self.assertNotIn('\\', item['source'])
            self.assertEqual(forge.digest(self.root/item['source']), item['sha256'])

    def test_source_reference_backslashes_rejected_instead_of_silently_ignored(self):
        registry = {'assets': [{'designId':'ui.frame', 'source':{'image':r'assets\bad.png'}}], 'screens':[]}
        plan = forge.read_json(ROOT/'production/plan.json')
        kit = forge.read_json(ROOT/'production/character-kit-v1/catalog.json')
        aliases = forge.read_json(ROOT/'production/character-kit-v1/aliases.json')
        with self.assertRaises(ValueError):
            reconcile.reconcile(self.root, registry, kit, plan, aliases)


if __name__ == '__main__':
    unittest.main()
