--!strict
-- One saved starter choice. Respecialization belongs to a later progression phase.
return function(content: any)
	return function(data: any, args: any, emit: any): string?
		local def = content.Character.Classes[args.classId]
		if not def then return "InvalidClass" end
		local c = data.character
		if c.classId then return "ClassAlreadySelected" end
		c.classId = args.classId; c.classPathId = def.PathId; c.skillId = def.SkillId
		emit("player_class_selected", { classId = c.classId })
		return nil
	end
end
