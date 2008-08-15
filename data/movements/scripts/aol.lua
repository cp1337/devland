function onEquip(cid, item, pos)

	if getWorldType() < 3 then
	    		pos = getPlayerPosition(cid)	
	    		doSendMagicEffect(pos, 11)			
	    		doPlayerSetLossPercent(cid, 3, 0)	
	else
	    	doPlayerSendTextMessage(cid, 21, "Aol not working in PVP-ENF servers.")			
	end
end




function onDeEquip(cid, item, pos)
	    doPlayerSetLossPercent(cid, 3, 10)
end