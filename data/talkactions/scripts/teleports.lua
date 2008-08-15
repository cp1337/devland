

function onSay(cid, words, param)

	playerpos = getPlayerPosition(cid)
	npos = {x=playerpos.x, y=playerpos.y , z=playerpos.z - 1}
	npos2 = {x=playerpos.x, y=playerpos.y , z=playerpos.z + 1}

	if words == "up!" then
		doTeleportThing(cid,npos)
		doSendMagicEffect(npos,12)	
	elseif words == "down!" then
		doTeleportThing(cid,npos2)
		doSendMagicEffect(npos2,12)	
	end

end