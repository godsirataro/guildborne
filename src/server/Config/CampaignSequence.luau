--!strict
-- Compose only explicitly selected arcs; importing ChapterTwo does not activate it.
return function(arcs:{any}):any
 local out:any={Version=1,Chapters={},Choices={},Guidance={},ObjectiveLabels={}}
 local ids={};local objectives={}
 for _,arc in ipairs(arcs)do
  assert(arc.Version==out.Version,"Incompatible campaign schema")
  for _,chapter in ipairs(arc.Chapters)do
   assert(not ids[chapter.Id],"Duplicate campaign chapter");ids[chapter.Id]=true
   table.insert(out.Chapters,chapter)
   for _,id in ipairs(chapter.Objectives)do assert(not objectives[id],"Duplicate campaign objective");objectives[id]=true end
  end
  for _,key in ipairs({"Choices","Guidance","ObjectiveLabels"})do
   for id,value in pairs(arc[key])do assert(out[key][id]==nil,"Duplicate campaign metadata");out[key][id]=value end
  end
 end
 for id in pairs(objectives)do assert(out.Guidance[id]and out.ObjectiveLabels[id],"Missing campaign copy")end
 return out
end
