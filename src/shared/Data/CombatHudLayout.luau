--!strict
-- Pixel layout inside the safe GUI area; input authority is unchanged.
return function(width: number,height: number): any
    local compact=height<450 or (width<600 and height<570)
    local collapsed=compact and width<600
    local portrait=width<500 and not collapsed
    local dense=compact and not collapsed and height<320
    local padWidth=if collapsed then math.max(112,width-128) elseif compact then 232 else 116
    return {compact=compact,collapsed=collapsed,portrait=portrait,topAligned=compact or portrait,grid=compact and not collapsed,
        columns=if dense then 3 elseif compact and not collapsed then 2 else 1,
        cardWidth=if collapsed then 96 elseif dense then 90 else 138,selectionWidth=if collapsed then 96 elseif compact then 282 else 138,
        selectionHeight=if collapsed or dense then 92 elseif compact then 140 else 284,
        padWidth=padWidth,padHeight=if compact then 108 else 232,
        buttonWidth=if compact then (padWidth-8)/2 else 116,
        healthBottom=if portrait then 112 else 8,healthHeight=if portrait then 52 else 44,
        healthScale=if portrait or collapsed then .9 else .46,ordersBottom=if portrait then 168 else 56}
end
