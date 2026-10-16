"""Boundary tests for local preview data; not Studio or visual acceptance."""
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('quality',ROOT/'tools/import_quality_meshes.py')
quality=importlib.util.module_from_spec(spec);spec.loader.exec_module(quality)

def valid():
    return {'schemaVersion':1,'meshes':[{'id':'triangle','vertices':[[0,0,0],[1,0,0],[0,1,0]],'triangles':[[1,2,3]],'colors':[[1,0,0]],'faceColors':[1]}],
            'placements':[{'meshId':'triangle','name':'placement','cframe':[0,0,0,1,0,0,0,1,0,0,0,1]}]}

class PackagingTests(unittest.TestCase):
    def test_valid_reused_geometry(self):
        data=valid();placement=copy.deepcopy(data['placements'][0]);placement['name']='second';data['placements'].append(placement)
        self.assertEqual(quality.validate(data),dict(meshes=1,vertices=3,triangles=1,placements=2))

    def test_bad_triangle_and_unknown_mesh_rejected(self):
        for key in ['triangle','reference','color']:
            data=valid()
            if key=='triangle': data['meshes'][0]['triangles']=[[1,2,99]]
            elif key=='reference': data['placements'][0]['meshId']='absent'
            else: data['meshes'][0]['faceColors']=[2]
            with self.subTest(key=key), self.assertRaises(ValueError): quality.validate(data)

    def test_nonfinite_and_invalid_transform_rejected(self):
        for key in ['nan','scale','rotation','mirror']:
            data=valid()
            if key=='nan': data['meshes'][0]['vertices'][0][0]=float('nan')
            elif key=='scale': data['placements'][0]['scale']=[1,0,1]
            elif key=='rotation': data['placements'][0]['cframe'][4]=0.5
            else: data['placements'][0]['cframe'][3]=-1
            with self.subTest(key=key), self.assertRaises(ValueError): quality.validate(data)

    def test_duplicate_json_keys_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            source=Path(temp)/'data.json';source.write_text('{"schemaVersion":1,"schemaVersion":1}')
            with self.assertRaises(ValueError): quality.load(source)

    def test_lua_long_string_escape_cannot_inject_code(self):
        with tempfile.TemporaryDirectory() as temp:
            quality.package_data({'label':']==] error("injected") --'},temp)
            chunk=(Path(temp)/'Chunk1.luau').read_text()
            self.assertTrue(chunk.startswith('return [===['))
            self.assertTrue(chunk.endswith(']===]\n'))

    def test_image_pixels_exact_and_path_escape_rejected(self):
        from PIL import Image
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);art=root/'assets/production/ui-slice';art.mkdir(parents=True)
            source=art/'pixels.png';image=Image.new('RGBA',(2,1));image.putdata([(1,2,3,4),(255,0,100,128)]);image.save(source)
            manifest=root/'manifest.json';manifest.write_text(json.dumps({'images':[{'key':'test','path':'assets/production/ui-slice/pixels.png'}]}))
            report=quality.package_images(manifest,root,root/'output')
            self.assertEqual(report['pixels'],2)
            chunk=(root/'output/Chunk1.luau').read_text()
            data=json.loads(chunk[len('return [==['):-len(']==]\n')])
            self.assertEqual(data['images'][0]['runs'],[[1,67305985],[1,2154037503]])
            manifest.write_text(json.dumps({'images':[{'key':'test','path':'../../../outside.png'}]}))
            with self.assertRaises(ValueError): quality.package_images(manifest,root,root/'output')

if __name__=='__main__': unittest.main(verbosity=2)
