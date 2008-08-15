function onStepIn(cid, item, pos) 

	local pos = {x=1514, y=1277, z=6}

	if item.uid == 1644 then
		if isPremium(cid) == 0 then
			doTeleportThing(cid,pos)
			doSendMagicEffect(pos,12)
			doPlayerSendTextMessage(cid, 21, "Sorry, You need have premium to enter this area.")
		end
	end
end