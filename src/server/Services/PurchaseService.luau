--!strict
-- Disabled until the experience owner configures a real Elixir Developer Product.
return function(content: any,data: any,network: any)
	if content.Elixir.DeveloperProductId<=0 then return end
	game:GetService("MarketplaceService").ProcessReceipt=function(info)
		if info.ProductId~=content.Elixir.DeveloperProductId then return Enum.ProductPurchaseDecision.NotProcessedYet end
		local session=data.Sessions[info.PlayerId]
		if session and session.state=="Degraded" then data.Refresh(info.PlayerId) end
		local code=data.CommitElixir(info.PlayerId,info.PurchaseId,info.ProductId)
		if code=="OK" or code=="AlreadyCommitted" then
			local player=game.Players:GetPlayerByUserId(info.PlayerId);if player then network.Send(player) end
			data.FlushAudit(info.PlayerId);return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end
