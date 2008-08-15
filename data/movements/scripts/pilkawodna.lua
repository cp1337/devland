function onAddItem(moveitem, tileitem, pos)
	if moveitem.itemid == 7956 then
		doTransformItem(moveitem.uid, 7711)
	elseif moveitem.itemid == 7711 then
		doSendMagicEffect(pos, 1)
	else
	   	doRemoveItem(moveitem.uid,1)
		doSendMagicEffect(pos, 1)
	end
	return 1
end