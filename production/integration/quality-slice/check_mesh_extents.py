"""Regression for the actual native mesh-size failure; no Studio acceptance."""
from copy import deepcopy
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/'tools'))
from import_quality_meshes import validate

base={'schemaVersion':1,'meshes':[{'id':'test','vertices':[[0,0,0],[100,0,0],[0,1,1]],'triangles':[[1,2,3]],'colors':[[1,1,1]],'faceColors':[1]}],
      'placements':[{'name':'fixture','meshId':'test','cframe':[0,0,0,1,0,0,0,1,0,0,0,1]}]}
def reject(data,expected):
    try: validate(data)
    except ValueError as error:
        assert expected in str(error),str(error)
    else: raise AssertionError('Oversized geometry accepted')
validate(base)
for axis in range(3):
    data=deepcopy(base);data['meshes'][0]['vertices'][1][axis]=2048.01
    reject(data,'native extents')
data=deepcopy(base);data['meshes'][0]['vertices'][1][0]=2048;validate(data)
data=deepcopy(base)
for vertex in data['meshes'][0]['vertices']: vertex[0]+=7000
validate(data) # extents, not absolute world coordinates
data=deepcopy(base);data['placements'][0]['scale']=[21,1,1]
reject(data,'scaled native extents')
data=deepcopy(base);data['meshes'][0]['vertices'][1][0]=2049;data['placements'][0]['scale']=[.1,.1,.1]
reject(data,'native extents') # resource is instantiated before placement scale
print('PASS 8 mesh extent regression cases')
