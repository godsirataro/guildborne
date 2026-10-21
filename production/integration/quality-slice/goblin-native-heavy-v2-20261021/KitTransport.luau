-- Disposable Edit-only loader. Fixed reviewed bytes, no uploaded assets.
local H=game:GetService('HttpService')
local E=game:GetService('EncodingService')
local A=game:GetService('AssetService')
local R=game:GetService('RunService')
local M={handle=nil,receipt=nil,loading=false,generation=0}
local expected={["heavy.json"]="81294760b88294746964a265f001278fd76dc11f058b338791728f3a8428634e",["scout.json"]="67eb6855ba9bd5219a24519f9856761bc3d33f87c5fc6e66ca6c56491f7a135c",["ritual.json"]="e2e81e6b48786cfb12f05234ddb97598080f9a0cdb77d5febe80c2c0a1432a45",["ColorMap.rgba"]="f9427d74ace6fa00f9c994cf839dc2dfdb1a3a16784c3734d087a8a4cec1ce3b",["RoughnessMap.rgba"]="9f68a6bd29f8d5678baa236a2b7301382bdba92e5d7425e15c6c5d4afaa40f77",["MetalnessMap.rgba"]="0baa5fc22fd4f6cb647d84b3968f7b7fb691bf373abb06cbc2172e12c502314a"}
local function hash(b)
 local raw=E:ComputeBufferHash(b,Enum.HashAlgorithm.Sha256)
 return (buffer.tostring(raw):gsub('.',function(c)return string.format('%02x',string.byte(c))end))
end
function M.Load(url,kind)
 assert(kind=="heavy" or kind=="scout" or kind=="ritual","UNREVIEWED_KIT")
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
 local receipt={images={},scope='LOCAL_R6_KIT_PALETTE_PREVIEW',kind=kind,httpBefore=originalHttp}
 local ok,result=xpcall(function()
  H.HttpEnabled=true
  local metaText=H:GetAsync(url..'?name=meta&kind='..kind,true);alive()
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
  assert(meta.mesh.name==kind..'.json' and #meta.images==3,'EXPECTED_KIT_PACKET')
  local data=H:JSONDecode(buffer.tostring(fetch(meta.mesh)))
  receipt.meshSha256=meta.mesh.rawSha256
  for _,row in ipairs(meta.images) do
   assert(type(row.role)=='string' and expected[row.role..'.rgba']~=nil,'UNLISTED_ROLE')
   assert(row.name==row.role..'.rgba' and not images[row.role] and row.width==128 and row.height==16,'MAP_IDENTITY')
   local raw=fetch(row)
   assert(buffer.len(raw)==128*16*4,'PIXEL_LENGTH')
   local im=assert(A:CreateEditableImage({Size=Vector2.new(128,16)}),'IMAGE_ALLOCATION_FAILED')
   images[row.role]=im
   alive()
   im:WritePixelsBuffer(Vector2.zero,im.Size,raw)
   local readback=hash(im:ReadPixelsBuffer(Vector2.zero,im.Size))
   assert(readback==expected[row.name],'NATIVE_PIXEL_READBACK')
   table.insert(receipt.images,{role=row.role,width=128,height=16,rawSha256=readback})
  end
  H.HttpEnabled=originalHttp
  alive()
  local sword=require(script.Parent.ReviewTransport).Get()
  local handle=assert(require(script.Parent.HeavyKitPreview).New(data,images,sword.model,sword.rig,alive),'PREVIEW_CONSTRUCTION_FAILED')
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
