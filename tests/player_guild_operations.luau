--!strict
local Schema=require("../src/server/Systems/PlayerGuildSchema")
return function(test:any,eq:any)
	test("player guild journal schema validates every coordinator phase and logical key",function()
		for _,state in ipairs({"Joining","Completed","Cancelling","Cancelled"})do
			local op={userId="2",guildId="guild",id="op",generation=1,token="invite",state=state}
			eq(Schema.operation(op,"2:op"),true);eq(Schema.operation(op,"3:op"),false)
		end
		for _,state in ipairs({"Creating","Created"})do
			eq(Schema.operation({userId="2",guildId="guild",id="op",generation=1,capacity=50,state=state},"2:op"),true)
		end
		for _,state in ipairs({"Removing","Removed"})do
			eq(Schema.operation({actorId="1",actorGeneration=1,targetId="2",targetGeneration=3,guildId="guild",id="op",state=state},"remove:5:guild:op"),true)
		end
	end)
	test("player guild removal keys distinguish delimiter-bearing guild and operation IDs",function()
		local one={actorId="1",actorGeneration=1,targetId="2",targetGeneration=1,guildId="a:b",id="c",state="Removing"}
		local two={actorId="1",actorGeneration=1,targetId="2",targetGeneration=1,guildId="a",id="b:c",state="Removing"}
		eq(Schema.operation(one,"remove:3:a:b:c"),true);eq(Schema.operation(two,"remove:1:a:b:c"),true)
		eq(Schema.operation(one,"remove:1:a:b:c"),false);eq(Schema.operation(two,"remove:3:a:b:c"),false)
	end)
	test("player guild journal schema rejects unknown phases malformed proof and overflows",function()
		local op:any={userId="2",guildId="guild",id="op",generation=1,token="invite",state="Joining"}
		op.state="Done";eq(Schema.operation(op),false);op.state="Joining"
		for _,n in ipairs({0,-1,1.5,2147483648,math.huge,0/0})do op.generation=n;eq(Schema.operation(op),false)end
		op.generation=1;op.token="";eq(Schema.operation(op),false)
		op.state="Creating";op.capacity=51;eq(Schema.operation(op),false)
		eq(Schema.operation({state="Removing",guildId="guild",id="op",actorId="01",targetId="2",actorGeneration=1,targetGeneration=1}),false)
	end)
end
