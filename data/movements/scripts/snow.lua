function decayGround(params)
	pos = {x=params.pos.x, y=params.pos.y, z=params.pos.z, stackpos = 0}
	item = getThingfromPos(pos)
	doTransformItem(item.uid, params.itemid)
end

function onStepOut(cid, item, pos)	
	if isPlayer(cid) == 1 then
	    local delaySeconds = 10 --the delay in seconds before the ground changes back to normal snow	    
	    if(item.itemid == 670) then
	        doTransformItem(item.uid, 6594)
          else  		 
	        doTransformItem(item.uid, item.itemid+15)
	    end
	    params = {pos = pos, itemid = item.itemid}
	    addEvent(decayGround, delaySeconds*1000, params)
	end
end