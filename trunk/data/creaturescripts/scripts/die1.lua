
function onDiePlayer(cid, corpse)


		doPlayerSay(cid, "I'll back!", 1)


		if doPlayerRemoveItem(cid,2173, 1) == 0 then
		
		else
			local pos = getCreaturePosition(cid)
			doCreateItem(2148, 1, pos)
		end


		if getPlayerLevel(cid) >= 150 then
			item = doAddContainerItem(corpse, 2353, 1)
			doSetItemSpecialDescription(item,"This is the heart of "..getPlayerName(cid).." Who was killed at Level "..getPlayerLevel(cid)..".")
		else
			item2 = doAddContainerItem(corpse, 2231, 1)
			doSetItemSpecialDescription(item2,"This is the Bone of "..getPlayerName(cid).." Who was killed at Level "..getPlayerLevel(cid)..".")
		end
end