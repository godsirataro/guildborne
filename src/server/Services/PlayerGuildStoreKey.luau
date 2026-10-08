--!strict
-- Local key derivation only; never opens a DataStore. Full logical identity stays
-- in the validated record envelope, so a key collision cannot overwrite a record.
local Encoding=game:GetService("EncodingService")
return function(kind:string,logicalKey:string):string
	assert(kind=="Slot"or kind=="Guild"or kind=="Operation","InvalidKind")
	assert(type(logicalKey)=="string"and #logicalKey>0 and #logicalKey<=160 and logicalKey:match("^[%w_:%-]+$"),"InvalidLogicalKey")
	local hash=Encoding:ComputeStringHash(kind..":"..logicalKey,Enum.HashAlgorithm.Sha256)
	local encoded=buffer.tostring(Encoding:Base64Encode(buffer.fromstring(hash)))
	encoded=encoded:gsub("%+","-"):gsub("/","_"):gsub("=","")
	local key="g1:"..encoded;assert(#key==46,"InvalidDigestLength");return key
end
