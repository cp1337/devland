function onStepIn(cid, item, pos) 

	local pos = {x=452, y=474, z=8}
	local voc = {1,2,5,6}

	if item.uid == 3004 then
		if isInArray(voc, getPlayerVocation(cid)) == FALSE then
			doTeleportThing(cid,pos)
			doSendMagicEffect(pos,12)

			if getPlayerVocation(cid) == 3 or getPlayerVocation(cid) == 7 then
				doPlayerSendTextMessage(cid, 21, "Sorry, Paladins can\'t enter to this area.")
			else
				doPlayerSendTextMessage(cid, 21, "Sorry, Knights can\'t enter to this area.")
			end
		end
	end
end