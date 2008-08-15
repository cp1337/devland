function onStepIn(cid, item, pos) 

	npos = {x=pos.x,  y=pos.y,  z=pos.z + 1}
	doTransformItem(item.uid, item.itemid +	1)
end