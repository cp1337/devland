function onUse(cid, item, frompos, item2, topos)
    
	if item2.itemid == 2782 then
		doTransformItem(item2.uid,2781)
	elseif item2.itemid == 3985 then
		doTransformItem(item2.uid,3984)
	else 
		return 0
	end
	return 1
end