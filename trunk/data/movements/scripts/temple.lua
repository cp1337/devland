function onStepIn(cid, item, pos) 

	local pos = {x=477, y=450, z=7}
	local pos2 = {x=508, y=454, z=7}

	if item.actionid == 301 then
		if getPlayerVocation(cid) == 4 or getPlayerVocation(cid) == 8 then
		        doTeleportThing(cid,pos)
			doSendMagicEffect(pos,12)
			doPlayerSetTown(cid,2)
		else
			doTeleportThing(cid,pos2)
			doSendMagicEffect(pos2,12)
			doPlayerSetTown(cid,2)
		end
	end
end