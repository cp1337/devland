-- drag lever

function onUse(cid, item, frompos, item2, topos)

-- kamienie
gatepos = {x=1435, y=1344, z=11, stackpos=1} 
getgate = getThingfromPos(gatepos)
leverpos = {x=1406, y=1335, z=12, stackpos=1}
blockpos1 = {x=1408, y=1333, z=12, stackpos=1}
blockpos2 = {x=1408, y=1334, z=12, stackpos=1}
blockpos3 = {x=1408, y=1335, z=12, stackpos=1}
blockpos4 = {x=1408, y=1336, z=12, stackpos=1}
blockpos5 = {x=1408, y=1337, z=12, stackpos=1}
blockgate1 = getThingfromPos(blockpos1)
blockgate2 = getThingfromPos(blockpos2)
blockgate3 = getThingfromPos(blockpos3)
blockgate4 = getThingfromPos(blockpos4)
blockgate5 = getThingfromPos(blockpos5)

	if item.uid == 4025 and item.itemid == 1945 then
		doRemoveItem(getgate.uid,1)
		doCreateItem(1304,1,blockpos1)
		doCreateItem(1304,1,blockpos2) 
		doCreateItem(1304,1,blockpos3)
		doCreateItem(1304,1,blockpos4)
		doCreateItem(1304,1,blockpos5) 
		doTransformItem(item.uid,item.itemid+1)
	elseif item.uid == 4025 and item.itemid == 1946 then
		doTransformItem(item.uid,item.itemid-1)
		doCreateItem(1304,1,gatepos)
		doRemoveItem(blockgate1.uid,1)
		doRemoveItem(blockgate2.uid,1)
		doRemoveItem(blockgate3.uid,1)
		doRemoveItem(blockgate4.uid,1)
		doRemoveItem(blockgate5.uid,1)
else 
doPlayerSendCancel(cid,"Sorry, not possible.") 
end 
return 1 
end
