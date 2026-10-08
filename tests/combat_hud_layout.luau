--!strict
local layout=require("../src/shared/Data/CombatHudLayout")
return function(test: any,eq: any)
    test("combat HUD separates selection actions health and orders across safe areas",function()
        local cases=0
        for _,w in ipairs({320,360,390,480,599,600,640,740,1024,1366}) do
            for _,h in ipairs({280,300,320,340,449,450,500,569,570,640,844}) do
                local l=layout(w,h)
                local selection={x=8,y=64,w=l.selectionWidth,h=l.selectionHeight}
                local buttons={x=w-8-l.padWidth,y=if l.topAligned then 64 else h*.5-l.padHeight*.5,w=l.padWidth,h=l.padHeight}
                local ow=math.min(w*.9,360)
                local orders={x=(w-ow)/2,y=h-l.ordersBottom-44,w=ow,h=44}
                local health={x=w*(1-l.healthScale)/2,y=h-l.healthBottom-l.healthHeight,w=w*l.healthScale,h=l.healthHeight}
                local regions={selection,buttons,orders,health}
                for i,a in ipairs(regions) do
                    assert(a.x>=0 and a.y>=58 and a.x+a.w<=w and a.y+a.h<=h,"Outside safe area "..w.."x"..h)
                    for j,b in ipairs(regions) do if i<j then
                        assert(a.x+a.w<=b.x or b.x+b.w<=a.x or a.y+a.h<=b.y or b.y+b.h<=a.y,"Overlap "..w.."x"..h.." "..i.."/"..j)
                    end end
                end
                assert(l.cardWidth>=44 and l.buttonWidth>=44)
                if not l.collapsed then assert(math.ceil(6/l.columns)*48-4<=l.selectionHeight) end
                cases+=1
            end
        end
        eq(cases,110)
    end)
end
