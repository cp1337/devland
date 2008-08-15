-- annihilator chests

function onUse(cid, item, frompos, item2, topos)

   	if item.uid == 9000 then
   		queststatus = getPlayerStorageValue(cid,5009)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,22,"You have found a Demon Armor.")
   			doPlayerAddItem(cid,2494,1)
   			setPlayerStorageValue(cid,5009,1)
   		else
   			doPlayerSendTextMessage(cid,22,"It is empty.")
   		end
   	elseif item.uid == 9001 then
   		queststatus = getPlayerStorageValue(cid,5009)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,22,"You have found a Sword of Valor.")
   			doPlayerAddItem(cid,2400,1)
   			setPlayerStorageValue(cid,5009,1)
   		else
   			doPlayerSendTextMessage(cid,22,"It is empty.")
   		end
   	elseif item.uid == 9002 then
   		queststatus = getPlayerStorageValue(cid,5009)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,22,"You have found a Stonecutter's Axe.")
   			doPlayerAddItem(cid,2431,1)
   			setPlayerStorageValue(cid,5009,1)
   		else
   			doPlayerSendTextMessage(cid,22,"It is empty.")
   		end
   	elseif item.uid == 9003 then
		queststatus = getPlayerStorageValue(cid, 5009)
		if queststatus == -1 then
  			container = doPlayerAddItem(cid, 1990, 1)
			doContainerAddItem(container, 2326, 1)
			doPlayerSendTextMessage(cid, 22, "You have found a present.")
			setPlayerStorageValue(cid,5009,1)
   		else
   			doPlayerSendTextMessage(cid,22,"It is empty.")
   		end
	else
		return 0
   	end

   	return 1
end
