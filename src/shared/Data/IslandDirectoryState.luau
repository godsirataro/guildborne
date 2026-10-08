--!strict
-- Presentation filtering only; server visit tickets remain the access authority.
return function(entries:{any},viewerId:string,query:string,mode:string):{any}
 local rows={};local filter=string.lower(query:match("^%s*(.-)%s*$")or "")
 for _,entry in ipairs(entries)do
  local own=entry.ownerId==viewerId
  local haystack=string.lower(entry.displayName.." "..entry.name.." "..entry.ownerId)
  local modeMatches=mode=="All"or (mode=="Mine"and own)or (mode=="Public"and entry.mode=="Public")or (mode=="Friends"and entry.mode=="Friends")
  if modeMatches and (filter==""or string.find(haystack,filter,1,true))then
   table.insert(rows,{entry=entry,own=own,full=not own and entry.visitors>=entry.capacity})
  end
 end
 table.sort(rows,function(a,b)
  if a.own~=b.own then return a.own end
  if a.full~=b.full then return not a.full end
  local an,bn=string.lower(a.entry.displayName),string.lower(b.entry.displayName)
  if an~=bn then return an<bn end
  return a.entry.ownerId<b.entry.ownerId
 end)
 return rows
end
