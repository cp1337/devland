function onUse(cid, item, frompos, item2, topos)
	pos = getPlayerPosition(cid)
	
	if item2.itemid == 0 then
		return 0
	end
 
	doTransformItem(item2.uid,384)	
	
	return 1
end
