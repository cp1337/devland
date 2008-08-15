
function onUse(cid, item, frompos, item2, topos)

   	if item.uid == 3001 then
   		queststatus = getPlayerStorageValue(cid,3001)
   		if queststatus == -1 then
			key = doPlayerAddItem(cid, 2092, 1)
			doSetItemActionId(key, 303)
   			doPlayerSendTextMessage(cid,22,"Strange, i found key in this grave.")
   			setPlayerStorageValue(cid,3001,1)
   		else
   			doPlayerSendTextMessage(cid,22,"It is empty.")
   	        end
	end
end