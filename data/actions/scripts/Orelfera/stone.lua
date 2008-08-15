function onUse(cid, item, frompos, item2, topos)

	if item.uid == 3002 then

	        pos1 = {x=457, y=473, z=8}
		pos2 = {x=457, y=474, z=8}
		pos3 = {x=457, y=475, z=8}
		pos4 = {x=458, y=473, z=8}
		pos5 = {x=458, y=475, z=8}
		pos6 = {x=459, y=473, z=8}
		pos7 = {x=459, y=474, z=8}
		pos8 = {x=459, y=475, z=8}

		doSendMagicEffect(pos1,12)
		doSendMagicEffect(pos2,12)
		doSendMagicEffect(pos3,12)
		doSendMagicEffect(pos4,12)
		doSendMagicEffect(pos5,12)
		doSendMagicEffect(pos6,12)
		doSendMagicEffect(pos7,12)
		doSendMagicEffect(pos8,12)

                doPlayerAddHealth(cid, 250)
	end
end
