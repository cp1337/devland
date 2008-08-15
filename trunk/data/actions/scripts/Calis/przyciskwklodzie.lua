-- Przycisk w Klodzie

function onUse(cid, item, frompos, item2, topos)

stonepos1 = {x=430, y=699, z=11, stackpos=1}
stonepos2 = {x=431, y=699, z=11, stackpos=1}
stone1 = getThingfromPos(blockpos1)
stone2 = getThingfromPos(blockpos2)



	if item.itemid == 4188 then
		doRemoveItem(getgate.uid,1)
		doCreateItem(1305,1,stonepos1)
		doCreateItem(1306,1,stonepos2) 
		doTransformItem(item.uid,item.itemid+1)
	elseif item.itemid == 4189 then
		doTransformItem(item.uid,item.itemid-1)
		doRemoveItem(stone1.uid,1)
		doRemoveItem(stone.uid,1)
	else 
		doPlayerSendCancel(cid,"Sorry, not possible.") 
	end 
	return 1 
end
