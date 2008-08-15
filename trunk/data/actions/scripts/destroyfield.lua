function onUse(cid, item, frompos, item2, topos)
-- Destroy Field v 1.4 by Rafacin
-- last edit 07/14/2006
-- Change:
-- Bug Fix

-- true for OTB IDS (7.4,7.6,7.7 and up)
-- false for 7.5 ids
otb = true

-- value where exhaust is saved
storevalue = 9999

-- Seconds of exhaust (in seconds)
exhausttime = 1

-------------------------------
--------- Dont change ---------
-------------------------------
 if (otb == true) then
  bigfire1 = 1487
  mediumfire1 = 1488
  littlefire1 = 1489
  poison1 = 1490
  energy1 = 1491
  bigfire2 = 1492
  mediumfire2 = 1493
  littlefire2 = 1494
  energy2 = 1495
  poison2 = 1496
  bigfirenonpvp = 1500
  mediumfirenonpvp = 1501
  littlefirenonpvp = 1502
  poisonnonpvp = 1503
  energynonpvp = 1504
  otherfire = none
  otherfire1 = none
  iddestroy = 2261
    else
  bigfire1 = 2097
  mediumfire1 = 2098
  littlefire1 = 2099
  poison1 = 2100
  energy1 = 2101
  bigfire2 = 2102
  mediumfire2 = 2103
  littlefire2 = 2104
  energy2 = 2105
  poison2 = 2106
  bigfirenonpvp = 2110
  mediumfirenonpvp = 2111
  littlefirenonpvp = 2112
  poisonnonpvp = 2113
  energynonpvp = 2114
  otherfire = 2116
  otherfire1 = 2117
  iddestroy = 3086
end

 if topos.x == 65535 then
    doChangeTypeItem(item.uid, item.type-1)
  if item.type == 1 then
   doRemoveItem(item.uid, 1)
 end
  doSendMagicEffect(frompos, 2)
 return 1
 end

   if getPlayerMagLevel(cid) >= 3 then
     if (exhaust(cid, storevalue, exhausttime) == 1) then
        if item.itemid == iddestroy then
          	doChangeTypeItem(item.uid, item.type-1)
		if item.type == 1 then
		doRemoveItem(item.uid, 1)
	           end
	      doSendMagicEffect(topos, 2)
     
          if (item2.itemid == bigfire1 or item2.itemid == bigfire2 or item2.itemid == mediumfire1 or item2.itemid == mediumfire2 or item2.itemid == littlefire1 or item2.itemid == littlefire2 or item2.itemid == poison1 or item2.itemid == energy1 or item2.itemid == energy2 or item2.itemid == poison2 or item2.itemid == bigfirenonpvp or item2.itemid == mediumfirenonpvp or item2.itemid == littlefirenonpvp or item2.itemid == poisonnonpvp or item2.itemid == energynonpvp or item2.itemid == otherfire or item2.itemid == otherfire1) then
	     doRemoveItem(item2.uid, 1)
	     doSendMagicEffect(topos, 2)
	   end
       else
           doSendMagicEffect(topos, 2)
              end
            else
          doPlayerSendCancel(cid, "You are exhausted.")
         end
       else
          doSendMagicEffect(frompos, 2)
      doPlayerSendCancel(cid, "Your magic level is too low.")
        end
	return 1
    end