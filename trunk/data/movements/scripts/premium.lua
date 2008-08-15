function onStepIn(cid, item, pos) 

	local pos = {x=1513, y=1279, z=6}
	days = getPlayerPremiumDays(cid)

	if getPlayerPremiumDays(cid) < 1 then
		      doTeleportThing(cid,pos)
			doSendMagicEffect(pos,12)
			doPlayerSendCancel(cid,"Restricted area: Only premium players.")
				doPlayerSendTextMessage(cid, 21, "Your Premium days: " .. days .. "")
	else
				doPlayerSendTextMessage(cid, 21, "Your Premium days: " .. days .. "")	
	end
end