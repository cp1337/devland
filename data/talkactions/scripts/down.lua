

function onSay(cid, words, param)
if getPlayerAccess(cid) >= 3 then
	playerpos = getPlayerPosition(cid)
	npos = {x=playerpos.x, y=playerpos.y , z=playerpos.z - 1}

	playerpos2 = getPlayerPosition(id)
	doTeleportThing(cid,npos)
	doSendMagicEffect(npos,12)		
end
end