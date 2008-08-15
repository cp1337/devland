function onUse(cid, item, frompos, item2, topos)
		npos = {x=frompos.x,  y=frompos.y,  z=frompos.z + 1}
		doTeleportThing(cid, npos)
end

