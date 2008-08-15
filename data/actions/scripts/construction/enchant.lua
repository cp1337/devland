-- Blogoslawienie broni zrobione przez Smoczek Leon --
-- Enchanted weapons by Smoczek Leon --

function onUse(cid, item, frompos, item2, topos) 

local gems = {2146, 2147, 2149, 2150}
local egems = {7759, 7760, 7761, 7762}
local altars = {{7508, 7509, 7510, 7511}, {7504, 7505, 7506, 7507}, {7516, 7517, 7518, 7519}, {7512, 7513, 7514, 7515}}
local weapons = {2383, 7384, 7406, 7402, 2429, 2430, 2435, 7380, 2454, 2423, 2445, 7415, 7392, 2391, 2544, 7383}
local eweapons = {{7763, 7744, 7854, 7869}, {7765, 7746, 7856, 7871}, {7766, 7747, 7857, 7872}, {7767, 7748, 7858, 7873}, {7768, 7749, 7859, 7874}, {7769, 7750, 7860, 7875}, {7770, 7751, 7861, 7876}, {7771, 7752, 7862, 7877}, {7772, 7753, 7863, 7878}, {7773, 7754, 7864, 7879}, {7774, 7755, 7865, 7880}, {7775, 7756, 7866, 7881}, {7776, 7757, 7867, 7882}, {7777, 7758, 7868, 7883}, {7839, 7840, 7850, 7838}, {7764, 7745, 7855, 7870}}

local type = item.type
if type == 0 then
type = 1
end

local mana = 300 * type                                                         -- B
local soul = 2 * type                                                           -- y

if isInArray(gems, item.itemid)== TRUE then                                     -- S
   for aa=1, #gems do                                                           -- m
   if item.itemid == gems[aa] then                                              -- o
   a=aa                                                                         -- c
   end                                                                          -- z
   end                                                                          -- e
   if isInArray(altars[a], item2.itemid)== TRUE then                            -- k
      if getPlayerMana(cid) >= mana and getPlayerSoul(cid) >= soul then
      doTransformItem(item.uid,egems[a])                                        -- L
      doPlayerAddMana(cid,-mana)                                                -- e
      doPlayerAddSoul(cid,-soul)                                                -- o
      doSendMagicEffect(frompos,39)                                             -- n
      else
      doPlayerSendCancel(cid,"You dont have mana or soul points.")
      end
   else
   return 2
   end

elseif isInArray(egems, item.itemid)== TRUE then
   for bb=1, #egems do   
   if item.itemid == egems[bb] then
   b=bb
   end
   end
   if isInArray(weapons, item2.itemid)== TRUE then
   for cc=1, #weapons do   
   if item2.itemid == weapons[cc] then
   c=cc
   end
   end
   doTransformItem(item2.uid,eweapons[c][b])
   doSendMagicEffect(frompos,39)
   doRemoveItem(item.uid,1)
   else
   doPlayerSendCancel(cid,"You can't enchanted this.")
   end
else
return 0
end
return 1
end