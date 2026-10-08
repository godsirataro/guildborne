"""Share the reviewed Crown Road geometry with the optional runtime course."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
source=(root/'review/NoviceRoadKit.luau').read_text(encoding='utf-8')
source=source.replace('-- Chapter 00 walkable environment prototype. No quest or combat receipts.','-- Generated from review/NoviceRoadKit.luau; optional course art, no reward authority.')
source=source.replace('SetAttribute("ReviewOnly",true)','SetAttribute("CoursePrototype",true)')
source=source.replace('Enum.ModelStreamingMode.Persistent -- Keep the small review board visible to the gallery camera.','Enum.ModelStreamingMode.Atomic')
(root/'src/server/Services/NoviceRoadArt.luau').write_text(source,encoding='utf-8')
print('NOVICE_ROAD_ART synchronized; quest observations belong to NoviceCourseWorld')
