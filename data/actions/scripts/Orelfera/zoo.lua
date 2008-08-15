function onUse(cid, item, frompos, item2, topos)

	if item.actionid == 300 then

	      pos2 = {x=518, y=478, z=7}
		ticket = getPlayerItemCount(cid,6086)
		playerpos = getPlayerPosition(cid)

		barpos = {x = frompos.x, y = frompos.y, z = frompos.z, stackpos = 253}

            if playerpos.y == barpos.y + 1 and playerpos.x == barpos.x then
		    if ticket > 0 then
                    doSendAnimatedText(pos2,'Welcome!',95)
			  doTransformItem(item.uid, item.itemid + 1)
			  doMoveCreature(cid,0)
			  doPlayerRemoveItem(cid,6086, 1)
		    else
                    doSendAnimatedText(pos2,'Ticket!',95)
		end
		else
                    doTransformItem(item.uid, item.itemid + 1)
			  doSendAnimatedText(pos2,'Goodbye!',95)
			  doMoveCreature(cid,2)                   
		end
	end
end
