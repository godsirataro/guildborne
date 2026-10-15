--!strict
return function(test:any,eq:any)
 local P=require("../src/shared/Network/Protocol")
 local function valid(action:string,args:any):boolean
  return P.validate({version=1,requestId="party-test",revision=0,action=action,args=args})
 end
 test("Human Party wire contract is separate from five NPC companions",function()
  eq(P.MaxPartySize,5)
  eq(valid("HumanPartyInvite",{targetUserId="1234567890",partyRevision=0}),true)
  eq(valid("HumanPartyInvite",{targetUserId="-1",partyRevision=0}),true)
  eq(valid("UpdateParty",{adventurerIds={"a","b","c","d","e","f"}}),false)
 end)
 test("Human Party wire rejects authority fields and malformed revision",function()
  eq(valid("HumanPartyAccept",{inviteId="inv-1",partyRevision=1,leaderUserId="1"}),false)
  for _,rev in ipairs({-1,0.5,math.huge,0/0,1000000001})do
   eq(valid("HumanPartyLeave",{partyRevision=rev}),false)
  end
  eq(valid("HumanPartyKick",{targetUserId=123,partyRevision=0}),false)
  eq(valid("HumanPartyAccept",{partyRevision=0}),false)
 end)
 test("Human Party readiness accepts only explicit booleans",function()
  eq(valid("HumanPartySetReady",{ready=true,partyRevision=0}),true)
  eq(valid("HumanPartySetReady",{ready=false,partyRevision=0}),true)
  eq(valid("HumanPartySetReady",{ready=1,partyRevision=0}),false)
  eq(valid("HumanPartySetReady",{ready="true",partyRevision=0}),false)
  eq(valid("HumanPartySetReady",{partyRevision=0}),false)
 end)
end
