

function onSay(cid, words, param)

	playerpos = getPlayerPosition(cid)
	npos = {x=playerpos.x + 1, y=playerpos.y, z=playerpos.z}

	item = getPlayerSlotItem(cid,5)
	item2 = getPlayerSlotItem(cid,6)
	shield = item.itemid
	shield2 = item2.itemid
	chargeshield = item.uid
	chargeshield2 = item2.uid


     if shield == 2529 or shield2 == 2529 then

	   if getItemCharges(chargeshield) >= 49 then	
		doSendAnimatedText(playerpos, "AvaroPast", 120)
		doPlayerSummonCreature(cid, "Wyvern", npos)
		removeItemCharges(chargeshield, 49)
	   else
		doSendMagicEffect(playerpos,2)
		doPlayerSendTextMessage(cid, 21, "Sorry, black shield have not enough charges.")	
	   end

     end

end