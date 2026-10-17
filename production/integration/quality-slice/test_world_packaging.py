"""World preview pairing rejects unrelated or stale collision geometry."""
import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'tools'))
import build_quality_preview as preview

class WorldPairingTests(unittest.TestCase):
    def test_actual_reviewed_pair(self):
        source=ROOT/'assets/production/world-slice/world-slice.mesh.json'
        name,manifest=preview.world_contract([source])
        self.assertEqual(name,'Dataset1')
        self.assertEqual(len(manifest['expectedArt']),103)

    def test_missing_duplicate_and_unrelated_pair(self):
        source=ROOT/'assets/production/world-slice/world-slice.mesh.json'
        for sources in ([],[source,source],[ROOT/'assets/production/ui-slice/manifest.json']):
            with self.subTest(sources=sources), self.assertRaises(ValueError):
                preview.world_contract(sources)

    def test_stale_generated_collision_module(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp)
            for rel in ['assets/production/world-slice/collision.json','src/server/Services/WorldQualityAssets.luau']:
                target=root/rel
                target.parent.mkdir(parents=True,exist_ok=True)
                text=(ROOT/rel).read_text()
                if rel.endswith('.luau'):
                    text=text.replace('a6fed50575aa16a4572c8904bc312af9a0de64aa6332b9d532b548fbf9463d7d','0'*64)
                target.write_text(text)
            with patch.object(preview,'ROOT',root), self.assertRaises(ValueError):
                preview.world_contract([])
