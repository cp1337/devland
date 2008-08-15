function onSay(cid, words, param)
	id = getPlayerByName(param)
	if isPlayer(id) == 1 then
			if getPlayerPremiumDays(id) <= 350 then
					doPlayerAddPremiumDays(id, 9)
					doPlayerSendTextMessage(id, MESSAGE_INFO_DESCR, "You have bought 9 days of premium account.")
			else
					doPlayerSendCancel(cid, "You can not buy more than one year of Premium Account.")
					doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)			
			end
	else
			doPlayerSendTextMessage(cid, 21, "Sorry, this player is not online.")	
	end	
end