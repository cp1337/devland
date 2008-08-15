local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, 0)

local condition = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition, CONDITION_PARAM_TICKS, 40 * 6000)
setConditionParam(condition, CONDITION_PARAM_SKILL_DISTANCE, 8)
setConditionParam(condition, CONDITION_PARAM_SKILL_SHIELD, 4)
setCombatCondition(combat, condition)

function onUse(cid, item, frompos, item2, topos)
	var = numberToVariant(cid)
	doCombat(cid, combat, var)
	doRemoveItem(item.uid,1)
	return 1
end
