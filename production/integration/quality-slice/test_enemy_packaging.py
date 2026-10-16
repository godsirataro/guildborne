"""Skeletal input rejection tests; not deformation or Studio acceptance."""
import copy
import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('quality', ROOT/'tools/import_quality_meshes.py')
quality = importlib.util.module_from_spec(spec)
spec.loader.exec_module(quality)

def valid():
    identity = [0,0,0,1,0,0,0,1,0,0,0,1]
    return {'schemaVersion':1, 'id':'review_actor',
            'vertices':[[0,0,0],[1,0,0],[0,1,0]], 'triangles':[[1,2,3]],
            'colors':[[1,0,0]], 'faceColors':[1],
            'bones':[{'name':'Root','parent':0,'bind':identity[:],'localBind':identity[:]},
                     {'name':'Child','parent':1,'bind':identity[:],'localBind':identity[:]}],
            'weights':[[[1,.25],[2,.75]],[[1,1]],[[2,1]]],
            'clips':{'Idle':{'fps':1,'seconds':1,'looped':True,
                             'frames':[[identity[:],identity[:]] for _ in range(2)]}}}

class EnemyPackagingTests(unittest.TestCase):
    def test_valid_multiple_influences_and_endpoint(self):
        report=quality.validate_enemy(valid())
        self.assertEqual((report['bones'],report['clips'],report['frames']),(2,1,2))

    def test_hierarchy_and_duplicate_names(self):
        for parent in (1,2,-1,True):
            data=valid();data['bones'][0]['parent']=parent
            with self.subTest(parent=parent),self.assertRaises(ValueError):quality.validate_enemy(data)
        data=valid();data['bones'][1]['name']='Root'
        with self.assertRaises(ValueError):quality.validate_enemy(data)

    def test_invalid_weights(self):
        for weights in ([],[[1,.9]],[[1,.5],[1,.5]],[[3,1]],[[True,1]],[[1,-.1],[2,1.1]],[[1,float('nan')]]):
            data=valid();data['weights'][0]=weights
            with self.subTest(weights=weights),self.assertRaises(ValueError):quality.validate_enemy(data)
        data=valid();data['weights'].pop()
        with self.assertRaises(ValueError):quality.validate_enemy(data)

    def test_clip_shapes_and_nonfinite(self):
        for mutation in ('missing_bone','too_many_frames','nonfinite','zero_duration','loop_flag','mirror'):
            data=valid();clip=data['clips']['Idle']
            if mutation=='missing_bone':clip['frames'][0].pop()
            elif mutation=='too_many_frames':clip['frames']*=3
            elif mutation=='nonfinite':clip['frames'][0][0][0]=float('inf')
            elif mutation=='zero_duration':clip['seconds']=0
            elif mutation=='loop_flag':clip['looped']=1
            else:clip['frames'][0][0][3]=-1
            with self.subTest(mutation=mutation),self.assertRaises(ValueError):quality.validate_enemy(data)

    def test_bind_rotation_rejected(self):
        for key in ('bind','localBind'):
            data=copy.deepcopy(valid());data['bones'][0][key][3]=2
            with self.subTest(key=key),self.assertRaises(ValueError):quality.validate_enemy(data)

if __name__=='__main__':unittest.main(verbosity=2)
