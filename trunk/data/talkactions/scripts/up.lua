

function onSay(cid, words, param)

	playerpos = getPlayerPosition(cid)
	npos2 = {x=playerpos.x, y=playerpos.y , z=playerpos.z + 1}
if getPlayerAccess(cid) >= 3 then
		playerpos2 = getPlayerPosition(id)
		doTeleportThing(cid,npos2)
		doSendMagicEffect(npos2,12)
end

end