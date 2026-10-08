--!strict
-- Existing v1 namespace is retained in-place: schema v2 fences v1 workers.
return function(environment: string,studio: boolean,privateServer: boolean,c: any): string?
	if environment~='staging' and environment~='prod' then return nil end
	if studio and environment=='prod' then return nil end
	if not studio and not privateServer and not c.PublicEnabled then return nil end
	if privateServer and not c.PrivateEnabled then return nil end
	return environment
end
