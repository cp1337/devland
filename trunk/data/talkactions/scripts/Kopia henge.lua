

function onSay(cid, words, param)

	playerpos = getPlayerPosition(cid)
	npos = {x=playerpos.x + 1, y=playerpos.y, z=playerpos.z}
	id = getPlayerByName(param)
	outfitTime = 15000


	if isPlayer(id) == 1 then
		playerpos2 = getPlayerPosition(id)
		outfit = {lookType=getPlayerLookType(id),lookHead=getPlayerLookHead(id),lookAddons=getPlayerLookAddons(id),lookLegs=getPlayerLookLegs(id),lookBody=getPlayerLookBody(id),lookFeet=getPlayerLookFeet(id)}

		doSendMagicEffect(playerpos2,13)
		doSendMagicEffect(playerpos,12)	
		doSetCreatureOutfit(cid, outfit, outfitTime)
	else
		doPlayerSendTextMessage(cid, 21, "Sorry, this player is not online.")	
	end

end