--!strict
-- QA-only CLIENT helper; excluded from runtime. Fresh Studio Memory profiles only.
assert(game:GetService('RunService'):IsStudio())
local r=game.ReplicatedStorage:WaitForChild('GuildborneRemotes')
local H=game:GetService('HttpService')
_G.P4={view=nil,market=nil,ready=false,error=nil,log={}}
local Q=_G.P4
r.State.OnClientEvent:Connect(function(v) Q.view=v end)
r.Market.OnClientEvent:Connect(function(v) Q.market=v end)
function Q.command(action,args,expected)
 task.wait(.8)
 local id=H:GenerateGUID(false)
 r.Command:FireServer({version=1,requestId=id,revision=Q.view and Q.view.revision or 0,action=action,args=args or {}})
 local deadline=os.clock()+20
 repeat task.wait(.05) until (Q.view and Q.view.requestId==id) or os.clock()>deadline
 assert(Q.view and Q.view.requestId==id,'No command response '..action)
 if expected then assert(Q.view.code==expected,action..' '..tostring(Q.view.code)) end
 table.insert(Q.log,{action=action,code=Q.view.code,gold=Q.view.data.gold})
 return Q.view
end
function Q.send(action,order,id,item)
 task.wait(2.1)
 local request=H:GenerateGUID(false)
 r.Market:FireServer({requestId=request,action=action,itemId=item or 'iron_ore',period='1D',order=order,orderId=id})
 local deadline=os.clock()+20
 repeat task.wait(.05) until (Q.market and Q.market.requestId==request) or os.clock()>deadline
 assert(Q.market and Q.market.requestId==request,'No market response')
 assert(Q.market.code=='OK','Market '..tostring(Q.market.code))
 table.insert(Q.log,{action='Market'..action,code=Q.market.code,gold=Q.market.gold,owned=Q.market.owned})
 return Q.market
end
function Q.order(side,q,price,kind) return {itemId='iron_ore',side=side,quantity=q,price=price,kind=kind or 'LIMIT'} end
function Q.setup()
 local ok,err=pcall(function()
  Q.command('GetState')
  assert(Q.view.data.gold==0,'Fresh memory profile required')
  Q.command('SetLanguage',{language='en'},'OK')
  Q.command('SelectPlayerClass',{classId='Warrior'},'OK')
  Q.command('BeginTutorial',{},'OK');Q.command('Recruit',{classId='Warrior'},'OK')
  Q.command('UpdateParty',{adventurerIds={'a:Warrior'}},'OK')
  for _,quest in ipairs({'trail_watch','timber_escort','quarry_patrol'}) do
   Q.command('StartQuest',{questId=quest},'OK');local run=Q.view.data.quests.active
   task.wait(math.max(0,run.completeAt-Q.view.serverTime)+1)
   Q.command('CompleteQuest',{runId=run.runId},'OK')
  end
  for _,class in ipairs({'Archer','Priest','Knight','Mage'}) do Q.command('Recruit',{classId=class},'OK') end
  Q.command('EquipItem',{instanceId='q:3:1',adventurerId='a:Warrior'},'OK')
  Q.command('UpdateParty',{adventurerIds={'a:Warrior','a:Knight','a:Archer','a:Mage','a:Priest'}},'OK')
  Q.send('Read');Q.ready=true
  print('PHASE4 BASELINE READY',game.Players.LocalPlayer.UserId,H:JSONEncode(Q.log))
 end)
 if not ok then Q.error=tostring(err);warn('PHASE4 BASELINE FAILED',err) end
end
task.spawn(Q.setup)
