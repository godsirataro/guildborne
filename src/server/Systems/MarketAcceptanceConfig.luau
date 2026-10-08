--!strict
-- Opt-in private staging isolation; never points an acceptance run at normal saves.
return function(settings: any,environment: string?,studio: boolean,private: boolean): string?
	if not settings or not settings.Enabled then return nil end
	assert(environment=='staging' and not studio and private,'PrivateAcceptanceRequiresReservedStaging')
	assert(type(settings.RunId)=='string' and #settings.RunId>=1 and #settings.RunId<=16 and settings.RunId:match('^[%w_%-]+$'),'InvalidAcceptanceRun')
	assert(next(settings.UserIds)~=nil,'AcceptanceUsersRequired')
	return 'qa45_'..settings.RunId
end
