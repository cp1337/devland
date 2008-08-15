-- Key System by Dzojo

function onUse(cid, item, frompos, item2, topos)
	
action = item.actionid

	if item.actionid == item2.actionid then
		if item2.itemid == 1213 then
			doRemoveItem(item2.uid, 1)
			newitem = doCreateItem(1214,1,topos)
			doSetItemActionId(newitem, action)
		elseif item2.itemid == 1212 then
			doRemoveItem(item2.uid, 1)
			newitem = doCreateItem(1213,1,topos)
			doSetItemActionId(newitem, action)
		elseif item2.itemid == 1214 then
			doRemoveItem(item2.uid, 1)
			newitem = doCreateItem(1213,1,topos)
			doSetItemActionId(newitem, action)
		end
	else
		return 0
	end
     return 1
end
