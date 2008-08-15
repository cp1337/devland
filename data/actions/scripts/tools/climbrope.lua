--Climb rope by Dzojo--

function onUse(cid, item, frompos, item2, topos)


	npos = {x=topos.x, y=topos.y, z=topos.z}
      npos2 = {x=topos.x, y=topos.y, z=topos.z, stackpos=253}
      playerpos = getPlayerPosition(cid)


	if (item2.itemid == 920 or item2.itemid == 937 or item2.itemid == 936 or item2.itemid == 926 
	        or item2.itemid == 927 or item2.itemid == 929 or item2.itemid == 939 or item2.itemid == 946
              or item2.itemid == 947 or item2.itemid == 948 or item2.itemid == 956 or item2.itemid == 957
              or item2.itemid == 958 or item2.itemid == 3348 or item2.itemid == 891 or item2.itemid == 892 
              or item2.itemid == 893 or item2.itemid == 894 or item2.itemid == 899 or item2.itemid == 900
              or item2.itemid == 901 or item2.itemid == 902) and playerpos.x == npos.x + 1 and playerpos.y == npos.y and playerpos.z == npos.z + 1 then
      doTeleportThing(cid,npos)
	end

	if (item2.itemid == 920 or item2.itemid == 937 or item2.itemid == 936 or item2.itemid == 926 
	        or item2.itemid == 927 or item2.itemid == 929 or item2.itemid == 939 or item2.itemid == 946
              or item2.itemid == 947 or item2.itemid == 948 or item2.itemid == 956 or item2.itemid == 957
              or item2.itemid == 958 or item2.itemid == 3348 or item2.itemid == 891 or item2.itemid == 892 
              or item2.itemid == 893 or item2.itemid == 894 or item2.itemid == 899 or item2.itemid == 900
              or item2.itemid == 901 or item2.itemid == 902) and playerpos.x == npos.x and playerpos.y == npos.y + 1 and playerpos.z == npos.z + 1 then
      doTeleportThing(cid,npos)
	end

      if item2.itemid == 4973 and playerpos.z == npos.z then
            doTeleportThing(cid,npos)
      end     
      return 0
end