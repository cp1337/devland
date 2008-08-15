function onSay(cid, words, param)


playerpos = getPlayerPosition(cid)

if getPlayerMana(cid) >= 10 then

	doPlayerAddManaSpent(cid,10) 
	doPlayerAddMana(cid,-10)

	creature = doPlayerSummonClone(cid, "Klon", playerpos)
	creature2 = doPlayerSummonClone(cid, "Klon", playerpos)
	creature3 = doPlayerSummonClone(cid, "Klon", playerpos)
	return 0
else

	doPlayerSendCancel(cid, "Sorry, You not have enaugh mana.") 
	doSendMagicEffect(playerpos, 2)
end
return 1

end