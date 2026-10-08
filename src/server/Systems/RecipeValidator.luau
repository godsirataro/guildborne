--!strict
return function(content: any, rules: any, util: any): boolean
	assert(#rules.RecipeOrder==10 and util.count(rules.Recipes)==10,"Recipe catalog count")
	local seen={}
	for _,id in ipairs(rules.RecipeOrder) do
		local r=rules.Recipes[id]
		assert(r and not seen[id],"Recipe order reference");seen[id]=true
		local output=content.Items[r.Item];assert(output,"Recipe output reference")
		assert(util.integer(r.HallLevel or 1,1,20),"Recipe Hall gate")
		assert((r.HallLevel or 1)>=(output.HallLevel or 1),"Recipe bypasses item Hall gate")
		assert(util.count(r.Cost)>0,"Recipe cost required")
		for item,quantity in pairs(r.Cost) do
			assert(content.Items[item] and content.Items[item].Kind=="Material","Recipe material reference")
			assert(util.integer(quantity,1,content.Limits.Stack),"Recipe quantity")
			assert(item~=r.Item,"Recipe must not consume its output")
		end
	end
	return true
end
