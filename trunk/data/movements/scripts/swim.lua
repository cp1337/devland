function onStepIn(cid, item, pos)

beachpos = {x=pos.x, y=pos.y, z=pos.z, stackpos=253}
getplayer = getThingfromPos(beachpos)

outfit = {lookType=267,lookHead=0,lookAddons=0,lookLegs=0,lookBody=0,lookFeet=0}
outfitTime = 9000000

swimstorage = 33

swimstatus = getPlayerStorageValue(cid,swimstorage)

	if item.itemid == 7944 then
		if swimstatus == -1 or swimstatus == 0 then
		          npos = {x=pos.x-1, y=pos.y, z=pos.z}
		          doTeleportThing(getplayer.uid,npos)
		          doSendMagicEffect(npos, 53)
			  doSetCreatureOutfit(cid, outfit, outfitTime)
			  setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
			  npos = {x=pos.x+1, y=pos.y, z=pos.z}
		          doTeleportThing(getplayer.uid,npos)
			  doRemoveCondition(cid, 6)
			  setPlayerStorageValue(cid,swimstorage,0)	
		end


	elseif item.itemid == 7946 then
		if swimstatus == -1 or swimstatus == 0 then
		          npos = {x=pos.x+1, y=pos.y, z=pos.z}
		          doTeleportThing(getplayer.uid,npos)
		          doSendMagicEffect(npos, 53)
			  doSetCreatureOutfit(cid, outfit, outfitTime)
			  setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
			  npos = {x=pos.x-1, y=pos.y, z=pos.z}
		          doTeleportThing(getplayer.uid,npos)
			  doRemoveCondition(cid, 6)
			  setPlayerStorageValue(cid,swimstorage,0)
		end


	elseif item.itemid == 7943 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
			  npos = {x=pos.x, y=pos.y+1, z=pos.z}
		          doTeleportThing(getplayer.uid,npos)
			  doRemoveCondition(cid, 6)
			  setPlayerStorageValue(cid,swimstorage,0)
		end


	elseif item.itemid == 7945 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end

	elseif item.itemid == 7950 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x-1, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x+1, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end

	elseif item.itemid == 7948 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x-1, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x+1, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end

	elseif item.itemid == 7947 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x+1, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x-1, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end

		
	elseif item.itemid == 7949 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x+1, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x-1, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end

	elseif item.itemid == 7951 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x+1, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x-1, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end

	elseif item.itemid == 7952 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x-1, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x+1, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end

	elseif item.itemid == 7953 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x+1, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x-1, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end

	elseif item.itemid == 7954 then
		if swimstatus == -1 or swimstatus == 0 then
		         npos = {x=pos.x-1, y=pos.y-1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
		         doSendMagicEffect(npos, 53)
			 doSetCreatureOutfit(cid, outfit, outfitTime)
			 setPlayerStorageValue(cid,swimstorage,1)
			  doRemoveCondition(cid, 2)
		else
		         npos = {x=pos.x+1, y=pos.y+1, z=pos.z}
		         doTeleportThing(getplayer.uid,npos)
			 doRemoveCondition(cid, 6)
			 setPlayerStorageValue(cid,swimstorage,0)
		end


	end
	return 1
end