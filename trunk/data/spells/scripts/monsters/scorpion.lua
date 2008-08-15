local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_BLOCKARMOR, 1)
setCombatParam(combat, COMBAT_PARAM_BLOCKSHIELD, 1)
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)

local condition = createConditionObject(CONDITION_POISON)
setConditionParam(condition, CONDITION_PARAM_DELAYED, 1)
addDamageCondition(condition, 1, 3000, -20)
addDamageCondition(condition, 2, 3000, -19)
addDamageCondition(condition, 3, 3000, -17)
addDamageCondition(condition, 4, 3000, -14)
addDamageCondition(condition, 5, 3000, -10)
addDamageCondition(condition, 4, 3000, -5)
addDamageCondition(condition, 3, 3000, -4)
addDamageCondition(condition, 5, 3000, -3)
addDamageCondition(condition, 4, 3000, -2)
addDamageCondition(condition, 10, 3000, -1)
setCombatCondition(combat, condition)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
