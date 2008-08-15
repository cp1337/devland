--keys--

function onUse(cid, item, frompos, item2, topos)

	if item2.itemid == 1988 or item2.itemid == 1987 then
			owner = getPlayerGUID(cid) 
			if GetItemOwner(item2.uid) == true then
			    doPlayerSendCancel(cid,"Sorry, but this loot already belong to someone...")
		      else	
			    doSetItemOwner(cid,item2.uid)
			    doPlayerSendCancel(cid,"Ok, not only You can opent his container.")
			end
	end

	return 1
	
end