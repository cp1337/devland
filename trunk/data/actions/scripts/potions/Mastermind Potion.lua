local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, 0)

local condition = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition, CONDITION_PARAM_TICKS, 40 * 6000)
setConditionParam(condition, CONDITION_PARAM_STAT_MAGICPOINTS, 3)
setCombatCondition(combat, condition)

function onUse(cid, item, frompos, item2, topos)
	if getPlayerVocation(cid) == 1 or getPlayerVocation(cid) == 2 or getPlayerVocation(cid) == 5 or getPlayerVocation(cid) == 6 then
	var = numberToVariant(cid)
	doCombat(cid, combat, var)
	doRemoveItem(item.uid,1)
	else
	doPlayerSendTextMessage(cid,22,"Only druids and sorcerers can Use this Potion.")
	return 0
	end
	return 1
end
