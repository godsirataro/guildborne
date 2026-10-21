-- Disposable Edit-only loader. Fixed reviewed bytes, no uploaded assets.
local H=game:GetService('HttpService')
local E=game:GetService('EncodingService')
local A=game:GetService('AssetService')
local R=game:GetService('RunService')
local M={handle=nil,receipt=nil,loading=false,generation=0}
local expected={['mesh.json']='9c606cc4d964583ab7f61dc2b5b49947c5ffe007fb04bece7085c90a4687fd69',
 ['ColorMap.rgba']='89e1798d90c46dc9ab2e0ea9cd3fddd15b7376eca0d33f0bec39ba25ef402312',
 ['NormalMap.rgba']='a32b0b9bd693491fcdb0fa7fca9ecb06c4fa9cb6b17e6ecc32f41f62048012ef',
 ['RoughnessMap.rgba']='d2ebd7954f36eacda282beae2948f2cc3361879b71d582bb72caffce7b516c02',
 ['MetalnessMap.rgba']='190cf949bf34598478688f51cd8d5ae99c419a8a5b9110bf3158989c1a276417'}
local function hash(b)
 local raw=E:ComputeBufferHash(b,Enum.HashAlgorithm.Sha256)
 return (buffer.tostring(raw):gsub('.',function(c)return string.format('%02x',string.byte(c))end))
end
function M.Load(url)
 assert(R:IsStudio() and not R:IsRunning() and game.PlaceId==0 and game.GameId==0,'LOCAL_EDIT_ONLY')
 assert(not M.handle and not M.loading,'ALREADY_LOADED_OR_LOADING')
 assert(url:match('^http://127%.0%.0%.1:%d+/%x+$'),'LOOPBACK_ONLY')
 M.loading=true;M.generation+=1
 local generation=M.generation
 local function alive()
  assert(M.generation==generation,'LOAD_CANCELLED')
  assert(R:IsStudio() and not R:IsRunning() and game.PlaceId==0 and game.GameId==0,'LOCAL_EDIT_ONLY')
 end
 local originalHttp=H.HttpEnabled
 local images={}
 local receipt={images={},scope='LOCAL_1024_DERIVATIVE_PREVIEW',httpBefore=originalHttp}
 local ok,result=xpcall(function()
  H.HttpEnabled=true
  local metaText=H:GetAsync(url..'?name=meta',true);alive()
  assert(#metaText<10000,'METADATA_BUDGET')
  local meta=H:JSONDecode(metaText)
  local function fetch(row)
   alive()
   assert(type(row.name)=='string' and expected[row.name]~=nil,'UNLISTED_PAYLOAD')
   assert(expected[row.name]==row.rawSha256 and row.rawBytes<=4194304,'UNREVIEWED_PAYLOAD')
   assert(row.parts>=1 and row.parts<=20 and row.encodedBytes<=5000000,'TRANSFER_BUDGET')
   local pieces={}
   for i=0,row.parts-1 do
    local piece=H:GetAsync(url..'?name='..row.name..'&part='..i,true)
    alive();assert(#piece<=240000,'CHUNK_TOO_LARGE');table.insert(pieces,piece);task.wait();alive()
   end
   local encoded=table.concat(pieces);assert(#encoded==row.encodedBytes,'ENCODED_LENGTH')
   local compressed=E:Base64Decode(buffer.fromstring(encoded))
   assert(buffer.len(compressed)==row.compressedBytes and hash(compressed)==row.compressedSha256,'COMPRESSED_HASH')
   assert(E:GetDecompressedBufferSize(compressed,Enum.CompressionAlgorithm.Zstd)==row.rawBytes,'DECODED_BUDGET')
   local raw=E:DecompressBuffer(compressed,Enum.CompressionAlgorithm.Zstd)
   assert(buffer.len(raw)==row.rawBytes and hash(raw)==expected[row.name],'DECODED_HASH')
   return raw
  end
  assert(meta.mesh.name=='mesh.json' and #meta.images==4,'EXPECTED_SWORD_PACKET')
  local data=H:JSONDecode(buffer.tostring(fetch(meta.mesh)))
  receipt.meshSha256=meta.mesh.rawSha256
  for _,row in ipairs(meta.images) do
   assert(type(row.role)=='string' and expected[row.role..'.rgba']~=nil,'UNLISTED_ROLE')
   assert(row.name==row.role..'.rgba' and not images[row.role] and row.width==1024 and row.height==1024,'MAP_IDENTITY')
   local raw=fetch(row)
   assert(buffer.len(raw)==1024*1024*4,'PIXEL_LENGTH')
   local im=assert(A:CreateEditableImage({Size=Vector2.new(1024,1024)}),'IMAGE_ALLOCATION_FAILED')
   images[row.role]=im
   alive()
   im:WritePixelsBuffer(Vector2.zero,im.Size,raw)
   local readback=hash(im:ReadPixelsBuffer(Vector2.zero,im.Size))
   assert(readback==expected[row.name],'NATIVE_PIXEL_READBACK')
   table.insert(receipt.images,{role=row.role,width=1024,height=1024,rawSha256=readback})
  end
  H.HttpEnabled=originalHttp
  alive()
  local handle=assert(require(script.Parent.GoblinNativePreview).New(data,images,alive),'PREVIEW_CONSTRUCTION_FAILED')
  if M.generation~=generation then handle:Destroy();error('LOAD_CANCELLED') end
  M.handle=handle
  receipt.loaded=true
  return receipt
 end,debug.traceback)
 H.HttpEnabled=originalHttp
 receipt.httpAfter=H.HttpEnabled
 if not ok then
  for _,im in pairs(images) do pcall(function() im:Destroy() end) end
  receipt.loaded=false;receipt.error=tostring(result)
 end
 M.receipt=receipt
 M.loading=false
 return receipt
end
function M.Get() return assert(M.handle,'NOT_LOADED') end
function M.Destroy()
 M.generation+=1
 if M.loading then return {cancelRequested=true,pending=true} end
 if not M.handle then return {alreadyClosed=true} end
 local result=M.handle:Destroy();M.handle=nil;return result
end
return M
