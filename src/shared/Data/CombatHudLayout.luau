--!strict
-- Pixel layout inside the safe GUI area; input authority is unchanged.
return function(width: number,height: number): any
    local compact=height<450 or (width<600 and height<570)
    local collapsed=compact and width<600
    local portrait=width<500 and not collapsed
    local short=compact and height<360
    local dense=short and not collapsed
    local spacious=width>=900 and height>=640
    local tallCards=spacious or (portrait and height>=760)
    local tallWidth=if spacious then 224 else math.min(232,width-150)
    local padWidth=if collapsed then math.max(112,width-128) elseif compact then 232 else 116
    local layout={compact=compact,collapsed=collapsed,portrait=portrait,short=short,topAligned=compact or portrait,grid=compact and not collapsed,
        columns=if dense then 3 elseif compact and not collapsed then 2 else 1,
        cardHeight=if tallCards then 68 else 44,cardStride=if tallCards then 74 else 48,
        cardWidth=if tallCards then tallWidth elseif collapsed then 96 elseif dense then 90 else 138,selectionWidth=if tallCards then tallWidth elseif collapsed then 96 elseif compact then 282 else 138,
        selectionHeight=if tallCards then 438 elseif collapsed or dense then 92 elseif compact then 140 else 284,
        padWidth=padWidth,padHeight=if compact then 108 else 232,padTop=if portrait then 116 else 64,
        buttonWidth=if compact then (padWidth-8)/2 else 116,
        healthBottom=if portrait then 112 else 8,healthHeight=if portrait then 52 else 44,
        healthScale=if portrait or collapsed then .9 else .46,ordersBottom=if portrait then 168 else 56}
    -- Shared pixel rectangles in the safe area. Short mode keeps every command;
    -- only the redundant selected-health strip folds into the actor's own HP.
    local roster={x=8,y=64,w=layout.selectionWidth,h=layout.selectionHeight}
    local pad={x=width-8-padWidth,y=if layout.topAligned then layout.padTop else (height-layout.padHeight)/2,w=padWidth,h=layout.padHeight}
    local ordersWidth=math.min(width*.9,360)
    local orders={x=(width-ordersWidth)/2,y=height-layout.ordersBottom-44,w=ordersWidth,h=44}
    if short then orders={x=pad.x,y=pad.y+pad.h+8,w=math.min(pad.w,360),h=44} end
    local map={x=width-138,y=60,w=130,h=48}
    if compact then
        local gapLeft=roster.x+roster.w+8
        local gapRight=pad.x-8
        if not collapsed and gapRight-gapLeft>=130 then
            map={x=math.floor((gapLeft+gapRight-130)/2),y=64,w=130,h=44}
        else
            map={x=8,y=roster.y+roster.h+8,w=if collapsed then 96 else 130,h=44}
        end
    end
    layout.rosterRect=roster;layout.padRect=pad;layout.mapRect=map;layout.ordersRect=orders
    -- Expanded quest card leaves the right-hand map/location column clear.
    -- Compact quest copy retains its lane between gold and the menu in the top bar.
    layout.trackerWide=width>=900 and height>=560
    local trackerLeft=math.max(width*.32,width*.3+15.2)
    local trackerRight=math.min(width*.72-12,width-116)
    layout.trackerRect=if layout.trackerWide then {x=map.x-8-300,y=70,w=300,h=96}
        else {x=trackerLeft,y=7,w=math.max(48,trackerRight-trackerLeft),h=50}
    layout.showHealth=not short or height>=280
    layout.showWorldLabels=not compact
    layout.healthRect={x=width*(1-layout.healthScale)/2,y=height-layout.healthBottom-layout.healthHeight,w=width*layout.healthScale,h=layout.healthHeight}
    return layout
end
