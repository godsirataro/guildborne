local factory=require('../../../../src/client/UI/HumanPartyView')
local L=require('../../../../src/shared/Config/Localization')
local buttons,labels,sent={},{},{}
local language='en'
local ui={scroll={},T=function(k,v)return L.translate(language,k,v)end,
card=function(_,title)return {title=title}end,text=function(_,v)local l={Text=v};table.insert(labels,l);return l end,
button=function(_,title,enabled,cb)local b={title=title,enabled=enabled,cb=cb};table.insert(buttons,b);return b end,
act=function(a,args)table.insert(sent,{action=a,args=args})end,render=function()end,navigate=function()end}
local draw=factory(ui)
local state={available=true,revision=7,capacity=6,localUserId='1',partyId='p',leaderUserId='1',members={{userId='1',displayName='Me',username='me',heroCount=5,connectionState='Connected',ready=false},{userId='2',displayName='<b>Name</b>',username='other',heroCount=5,connectionState='Connected',ready=false}},directory={},incomingInvites={},outgoingInvites={}}
local snapshot={status='Active',serverTime=100,humanParty=state}
local function render()buttons={};labels={};draw(snapshot,false)end
local function button(prefix)for _,b in ipairs(buttons)do if b.Name and b.Name:sub(1,#prefix)==prefix then return b end end;error(prefix)end
render();button('HumanPartySetReady').cb();assert(sent[1].args.ready==true and sent[1].args.partyRevision==7)
local raw=false;for _,l in ipairs(labels)do if l.Text=='<b>Name</b> (@other)'then assert(l.RichText==false);raw=true end end;assert(raw)
button('HumanPartyKick').cb();assert(#sent==1);render();button('HumanPartyKick').cb();assert(#sent==2 and sent[2].args.targetUserId=='2')
render();button('HumanPartyTransferLeader').cb();state.revision=8;render();button('HumanPartyTransferLeader').cb();assert(#sent==2)
language='th';render();assert(button('HumanPartySetReady').title=='แจ้งว่าพร้อม');assert(button('HumanPartyKick').title=='นำออกจากปาร์ตี้')
state.partyId=nil;state.leaderUserId=nil;state.members={};state.incomingInvites={{inviteId='i',fromUserId='2',targetUserId='1',expiresAt=160}};state.directory={{userId='2',displayName='Other',username='other',heroCount=1,available=true}};state.revision=9
render();assert(button('HumanPartyAccept').enabled);button('HumanPartyAccept').cb();assert(sent[3].args.inviteId=='i' and sent[3].args.partyRevision==9)
snapshot.serverTime=161;render();assert(not button('HumanPartyAccept').enabled)
print('PASS HumanParty UI fixture: ready revision, plain identity, confirmation, stale confirmation reset, Thai labels, invitation payload and expiry')
snapshot.status='Degraded';snapshot.serverTime=100;state.revision=10;state.partyId='p';state.leaderUserId='1';state.members={{userId='1',displayName='Me',username='me',heroCount=5,connectionState='Connected',ready=false},{userId='3',displayName='Member',username='member',heroCount=2,connectionState='Connected',ready=false}}
render()
for _,a in ipairs({'HumanPartyLeave','HumanPartyDisband','HumanPartyKick','HumanPartyDecline'})do assert(button(a).enabled,a..' must support recovery')end
for _,a in ipairs({'HumanPartyInvite','HumanPartyAccept','HumanPartySetReady','HumanPartyTransferLeader'})do assert(not button(a).enabled,a..' must stay disabled')end
buttons={};draw(snapshot,true)
for _,b in ipairs(buttons)do if b.Name and b.Name:sub(1,10)=='HumanParty' then assert(not b.enabled,'pending must block mutations')end end
snapshot.status='Saving';render();assert(button('HumanPartyLeave').enabled and not button('HumanPartySetReady').enabled)
print('PASS recovery fixture: Saving/Degraded allow Leave Decline Disband Kick only; controller busy blocks all mutations')
