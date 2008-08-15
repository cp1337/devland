function onStepIn(cid, item, pos) 
	local depotid = item.actionid - 100
	local depot = getPlayerDepotItems(cid, depotid)      
      	local reqlevel = 2
	local pos = {x=1498, y=1320, z=6}

	if item.actionid == 200 then
		if getPlayerLevel(cid) < reqlevel then
		        doTeleportThing(cid,pos)
			doSendMagicEffect(pos,12)
		else
			doTransformItem(item.uid, item.itemid +	1)
		end
	end

	if item.actionid > 100 and item.actionid < 120 then
		if(item.itemid == 426) then
			doTransformItem(item.uid, item.itemid -	1)
		else
			doTransformItem(item.uid, item.itemid +	1)
		end

		if(depot == 1) then
			doPlayerSendCancel(cid, "Your depot contains 1 item.")
		elseif(depot == -1) then
			doPlayerSendCancel(cid, "FATAL ERROR: DEPOTID DOES NOT EXIST ON THIS CHARACTER! (DEPOTID: " .. depotid .. ")")
		elseif(depot > 1) then
			doPlayerSendCancel(cid, "Your depot contains " .. depot .. " items.")
		end
	end
	
	return 1
end


function onStepOut(cid, item, pos)
	if item.itemid == 417 or item.itemid == 447 or item.itemid == 3217 then
		doTransformItem(item.uid, item.itemid-1)
	elseif item.itemid == 425 then
		doTransformItem(item.uid, item.itemid+1)
	end
end