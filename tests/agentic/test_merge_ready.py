"""Regression tests for merge hardening. Every subprocess here is a local fixture."""
from pathlib import Path
import copy
import json
import struct
import sys
import tempfile
import unittest
import zlib

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools/agentic'))
import forge
import run_worker
import record_check
import compose_evidence
import asset_jobs
import content_graph
import reconcile
import mcp_probe
import test_v2


class PathContractTests(unittest.TestCase):
    def test_windows_and_posix_aliases_rejected(self):
        for path in ('.GIT/config', 'a/../b', 'a//b', 'a/./b', 'a/', 'a./b', 'a /b', 'CON/file',
                     'aux.txt', 'dir/LPT1.png', '/absolute', '../outside', 'a\\b', 'a\nname'):
            with self.subTest(path=path), self.assertRaises(ValueError):
                forge.relative_path(path)

    def test_valid_canonical_path_and_casefold_scope(self):
        self.assertEqual(str(forge.relative_path('assets/ui/panel.png')), 'assets/ui/panel.png')
        self.assertTrue(forge.contains_path('src/UI', 'src/ui/file.luau'))
        self.assertFalse(forge.contains_path('src/ui/file.luau', 'src/ui'))
        self.assertFalse(forge.contains_path('src/ui', 'src/uikit/file.luau'))

    def test_worker_cannot_claim_a_parent_as_a_child_scope(self):
        self.assertEqual(run_worker.changed_outside(['src/ui'], ['src/ui/view.luau']), ['src/ui'])

    def test_in_repository_symlink_parent_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'real').mkdir()
            try:
                (root/'alias').symlink_to(root/'real', target_is_directory=True)
            except OSError:
                self.skipTest('Symlink creation requires platform privileges')
            with self.assertRaises(ValueError):
                forge.inside(root, 'alias/output.json')


class CheckCompositionTests(unittest.TestCase):
    setUp = test_v2.GitFixture.setUp
    commit = test_v2.GitFixture.commit

    def recorded(self, code='pass'):
        result = record_check.record(self.root, [sys.executable, '-c', code], approved=True)
        relative = 'build/agentic/checks/' + result['invocation']['runId'] + '/result.json'
        return result, relative

    def test_quiet_check_retains_empty_streams_but_nonempty_proof(self):
        result, _ = self.recorded()
        record_check.verify(self.root, result)
        self.assertTrue(all(a['bytes'] > 0 for a in result['artifacts']))
        receipt = forge.read_json(self.root/result['invocation']['recordPath'])
        self.assertEqual([a['bytes'] for a in receipt['streams']], [0, 0])
        self.assertFalse(result['humanApproved'])

    def test_full_record_compose_submit_review_accept_route(self):
        _, relative = self.recorded('print("local fixture acceptance check")')
        packet = compose_evidence.compose(self.root, 'a', {'checks': relative})
        ledger = forge.Ledger(self.root/'build/agentic/ledger.sqlite3', self.root, self.plan)
        try:
            token = ledger.claim('a', 'fixture-writer')
            ledger.submit('a', token, packet)
            self.assertEqual(ledger.rows()[0]['state'], 'REVIEW')
            with self.assertRaises(ValueError):
                ledger.accept('a', 'fixture-writer')
            ledger.accept('a', 'fixture-reviewer')
            self.assertEqual(ledger.rows()[0]['state'], 'ACCEPTED')
        finally:
            ledger.close()

    def test_omitted_or_unknown_check_is_rejected(self):
        _, relative = self.recorded()
        for assignments in ({}, {'other': relative}, {'checks': relative, 'extra': relative}):
            with self.assertRaises(ValueError):
                compose_evidence.compose(self.root, 'a', assignments)

    def test_failed_check_cannot_be_composed(self):
        _, relative = self.recorded('raise SystemExit(8)')
        with self.assertRaises(ValueError):
            compose_evidence.compose(self.root, 'a', {'checks': relative})

    def test_quiet_stream_modified_after_recording_is_detected(self):
        result, _ = self.recorded()
        receipt = forge.read_json(self.root/result['invocation']['recordPath'])
        (self.root/receipt['streams'][0]['path']).write_text('changed')
        with self.assertRaises(ValueError):
            record_check.verify(self.root, result)

    def test_receipt_and_invocation_must_agree(self):
        result, _ = self.recorded()
        path = self.root/result['invocation']['recordPath']
        receipt = forge.read_json(path)
        receipt['exitCode'] = 7
        forge.save_json(path, receipt)
        result['invocation']['recordSha256'] = forge.digest(path)
        result['artifacts'][0]['sha256'] = forge.digest(path)
        with self.assertRaises(ValueError):
            record_check.verify(self.root, result)

    def test_late_receipt_edit_blocks_ledger_accept(self):
        result, relative = self.recorded()
        packet = compose_evidence.compose(self.root, 'a', {'checks': relative})
        ledger = forge.Ledger(self.root/'build/agentic/ledger.sqlite3', self.root, self.plan)
        try:
            token = ledger.claim('a', 'writer')
            ledger.submit('a', token, packet)
            (self.root/result['invocation']['recordPath']).write_text('{}')
            with self.assertRaises(ValueError):
                ledger.accept('a', 'reviewer')
        finally:
            ledger.close()

    def test_missing_executable_records_failure_instead_of_losing_checkpoint(self):
        result = record_check.record(self.root, [str(self.root/'nonexistent-executable')], approved=True)
        self.assertEqual(result['status'], 'FAIL')
        self.assertEqual(result['invocation']['exitCode'], 125)

    def test_source_mutating_check_records_failure(self):
        result, _ = self.recorded('from pathlib import Path; Path("AGENTS.md").write_text("changed")')
        self.assertEqual(result['status'], 'FAIL')
        self.assertFalse(result['sourceUnchanged'])

    def test_local_commands_cannot_certify_physical_or_studio_tasks(self):
        self.plan['tasks'][0]['environment'] = 'studio'
        forge.save_json(self.root/'production/plan.json', self.plan)
        self.commit()
        _, relative = self.recorded()
        with self.assertRaises(ValueError):
            compose_evidence.compose(self.root, 'a', {'checks': relative})

    def test_cli_does_not_overwrite_existing_evidence(self):
        _, relative = self.recorded()
        args = ['--root', str(self.root), '--task', 'a', '--check', 'checks='+relative,
                '--output', 'build/agentic/evidence/local.json']
        self.assertEqual(compose_evidence.main(args), 0)
        with self.assertRaises(ValueError):
            compose_evidence.main(args)

    def test_cli_duplicate_assignment_rejected(self):
        with self.assertRaises(ValueError):
            compose_evidence.main(['--root', str(self.root), '--task', 'a', '--check', 'checks=a.json',
                                  '--check', 'checks=b.json', '--output', 'build/agentic/evidence/invalid.json'])

    def test_worker_plan_edit_never_becomes_review_candidate(self):
        def invoke(argv, prompt, root, out, timeout, heartbeat):
            script = 'import json;from pathlib import Path;p=Path("production/plan.json");v=json.loads(p.read_text());v["name"]="changed";p.write_text(json.dumps(v))'
            return run_worker.run_process([sys.executable, '-c', script], prompt, root, out, timeout, heartbeat)
        result = run_worker.run(self.root, 'a', 'fixture', self.root/'build/agentic/ledger.sqlite3',
                                authorized=True, invoke=invoke)
        self.assertEqual(result['status'], 'BLOCKED_PLAN_CHANGED')

    def test_worker_invalid_plan_records_blocked_postcheck(self):
        def invoke(argv, prompt, root, out, timeout, heartbeat):
            code = 'from pathlib import Path; Path("production/plan.json").write_text("invalid json")'
            return run_worker.run_process([sys.executable, '-c', code], prompt, root, out, timeout, heartbeat)
        result = run_worker.run(self.root, 'a', 'fixture', self.root/'build/agentic/ledger.sqlite3',
                                authorized=True, invoke=invoke)
        self.assertEqual(result['status'], 'BLOCKED_POSTCHECK_FAILED')
        self.assertTrue(result['requiresIndependentReview'])

    def test_keyboard_interrupt_records_attempt_and_keeps_ownership(self):
        def interrupted(*args):
            raise KeyboardInterrupt('fixture interruption')
        with self.assertRaises(KeyboardInterrupt):
            run_worker.run(self.root, 'a', 'fixture', self.root/'build/agentic/ledger.sqlite3',
                           authorized=True, invoke=interrupted)
        saved = list((self.root/'build/agentic/runs').glob('*/run.json'))
        self.assertEqual(len(saved), 1)
        record = forge.read_json(saved[0])
        self.assertEqual(record['status'], 'INTERRUPTED_REQUIRES_REVIEW')
        self.assertEqual(len(record['attempts']), 1)


def chunk(kind, data):
    return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind+data)&0xffffffff)


def png(raw=b'\x00\x0a\x14\x1e\xff', extra=(), width=1, height=1, payload=None):
    header = chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0))
    return b'\x89PNG\r\n\x1a\n' + header + b''.join(extra) + chunk(b'IDAT', zlib.compress(raw) if payload is None else payload) + chunk(b'IEND', b'')


class PixelValidationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def inspect(self, data):
        path = self.root/'candidate.png'
        path.write_bytes(data)
        return asset_jobs.inspect_png(path)

    def test_rgba_channel_does_not_imply_transparency(self):
        result = self.inspect(png())
        self.assertTrue(result['hasAlphaChannel'])
        self.assertFalse(result['hasTransparentPixels'])
        self.assertEqual(result['visiblePixels'], 1)

    def test_all_five_png_filters_decode(self):
        # First pixel, first row has zero neighbors. All PNG predictors are zero.
        for filtering in range(5):
            result = self.inspect(png(bytes([filtering, 10, 20, 30, 128])))
            self.assertEqual(result['alphaMin'], 128)
            self.assertEqual(result['alphaMax'], 128)

    def test_paeth_left_and_previous_row_are_decoded(self):
        # Two identical rows/pixels with alpha 128. Sub encodes second pixel zero;
        # Up encodes the second row as zeros.
        first = bytes([1, 10, 20, 30, 128, 0, 0, 0, 0])
        second = bytes([2, 0, 0, 0, 0, 0, 0, 0, 0])
        result = self.inspect(png(first+second, width=2, height=2))
        self.assertEqual((result['alphaMin'], result['alphaMax'], result['visiblePixels']), (128, 128, 4))
        paeth = bytes([4, 10, 20, 30, 128, 0, 0, 0, 0]) + bytes([4, 0, 0, 0, 0, 0, 0, 0, 0])
        self.assertEqual(self.inspect(png(paeth, width=2, height=2))['alphaMin'], 128)

    def test_fully_transparent_candidate_cannot_be_submitted(self):
        (self.root/'blank.png').write_bytes(png(b'\0\0\0\0\0'))
        with self.assertRaises(ValueError):
            asset_jobs.inspect_candidate(self.root, {'identity':'asset:test','state':'AWAITING_VERIFIED_PROVIDER'},
                                         'blank.png', {'origin':'fixture','tool':'fixture','rights':'project'})

    def test_invalid_pixels_fail_even_with_valid_chunk_crc(self):
        for data in (png(payload=b'not zlib'), png(b'\x05\0\0\0\xff'),
                     png(b'\0' * 10000), png(b'\0'), png(payload=zlib.compress(b'\0\0\0\0\xff')+b'trailing')):
            with self.assertRaises(ValueError):
                self.inspect(data)

    def test_no_idat_is_not_a_valid_image(self):
        data = png()
        with self.assertRaises(ValueError):
            self.inspect(data[:33] + chunk(b'IEND', b''))

    def test_duplicate_header_and_unknown_critical_chunk_fail(self):
        for extra in ((chunk(b'IHDR', struct.pack('>IIBBBBB',1,1,8,6,0,0,0)),), (chunk(b'FAKE', b'x'),)):
            with self.assertRaises(ValueError):
                self.inspect(png(extra=extra))

    def test_noncontiguous_idat_fails(self):
        data = png()
        data = data[:33] + chunk(b'IDAT', b'') + chunk(b'tEXt', b'a\0b') + data[33:]
        with self.assertRaises(ValueError):
            self.inspect(data)


class DiscoveryHardeningTests(unittest.TestCase):
    def client(self, script):
        client = mcp_probe.StdioClient([sys.executable, '-u', '-c', script], timeout=1)
        self.addCleanup(client.close)
        return client

    def test_stable_2025_11_25_negotiation(self):
        client = self.client(test_v2.MCP_FIXTURE.replace('2024-11-05', '2025-11-25'))
        self.assertEqual(client.discover()['protocolVersion'], '2025-11-25')

    def test_undiscovered_read_tool_is_rejected(self):
        client = self.client(test_v2.MCP_FIXTURE)
        with self.assertRaises(ValueError):
            client.call_read('get_studio_state')

    def test_malformed_hello_is_a_controlled_error(self):
        client = self.client(test_v2.MCP_FIXTURE.replace('result={"protocolVersion":"2024-11-05","serverInfo":{"name":"FIXTURE_NOT_ROBLOX"}}', 'result=[]'))
        with self.assertRaises(ValueError):
            client.discover()

    def test_malformed_tool_entries_are_controlled_errors(self):
        original = '{"name":"list_roblox_studios","inputSchema":{"type":"object"}}'
        for substitute in ('"not an object"', '{"name":""}', '{"name":"reader"}'):
            client = self.client(test_v2.MCP_FIXTURE.replace(original, substitute))
            with self.assertRaises(ValueError):
                client.discover()
            client.close()

    def test_nonstring_cursor_fails(self):
        client = self.client(test_v2.MCP_FIXTURE.replace('"nextCursor":"next"', '"nextCursor":42'))
        with self.assertRaises(ValueError):
            client.discover()

    def test_close_is_idempotent(self):
        client = self.client(test_v2.MCP_FIXTURE)
        client.discover()
        client.close()
        client.close()
        self.assertIsNotNone(client.process.poll())

    def test_bad_timeout_does_not_spawn(self):
        for value in (True, float('nan'), float('inf'), 0):
            with self.assertRaises(ValueError):
                mcp_probe.StdioClient([sys.executable, '-c', 'pass'], timeout=value)


class ContentAndRoutingTests(unittest.TestCase):
    def test_duplicate_reward_receipts_are_rejected(self):
        with self.assertRaises(ValueError):
            content_graph.validate([{'id':x,'reward':{'gold':1},'rewardReceiptKey':'same'} for x in ('a','b')])

    def test_reward_receipt_needs_nonempty_string(self):
        for key in (' ', 12, True):
            with self.assertRaises(ValueError):
                content_graph.validate([{'id':'a','reward':{'gold':1},'rewardReceiptKey':key}])

    def test_main_flags_are_not_truthy_strings(self):
        with self.assertRaises(ValueError):
            content_graph.validate([{'id':'a','main':'false'}])

    def test_dedicated_work_packages_receive_their_own_assets(self):
        for identity, target in (('guild.island.plot','guild-islands'), ('guild.war.arena','guild-war-territory'),
                                 ('city.host.dialogue','npc-life')):
            self.assertEqual(reconcile.routing({'designId':identity}, 'asset'), target)
        self.assertEqual(reconcile.routing({'designId':'guild.island.panel'}, 'screen'), 'ux-system')


if __name__ == '__main__':
    unittest.main()
