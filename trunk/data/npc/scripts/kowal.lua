local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false

function onThingMove(creature, thing, oldpos, oldstackpos)

end


function onCreatureAppear(creature)

end


function onCreatureDisappear(cid, pos)
  	if focus == cid then
          selfSay('Good bye then.')
          focus = 0
          talk_start = 0
  	end
end


function onCreatureTurn(creature)

end


function msgcontains(txt, str)
  	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onCreatureSay(cid, type, msg)
  	msg = string.lower(msg)
	distance = getDistanceTo(cid)
	time = getPlayerStorageValue(cid,200)
	status = getPlayerStorageValue(cid,201)
	timetowait = 60 * 120

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Welcome ' .. getCreatureName(cid) .. '.')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('One moment, ' .. getCreatureName(cid) .. '! I\'ll be with you in no time.')

	elseif focus == cid then
		talk_start = os.clock()
		

		if msgcontains(msg, 'job') then
			selfSay('I am smit. If you want I can repair your broken amulet for 25k.')

		elseif msgcontains(msg, 'recharge') or msgcontains(msg, 'repair') then
			if status == 0 or status == -1 then
				if pay(cid,25000) then
		    			if doPlayerRemoveItem(cid,2196,1) == 1 then		
						selfSay('Ok, come back for 2 minutes and say \'back\'.')
						setPlayerStorageValue(cid,200,os.clock())
						setPlayerStorageValue(cid,201,1)
					else
						selfSay('Sorry, you not have broken amulet to repair.')
					end
				else
					selfSay('Sorry, you not have enough gold.')
				end
			else
				selfSay('Sorry, I already habe broken amulet to repair from You.')
			end	

		elseif msgcontains(msg, 'back') then
			if status == 1 then
				if (os.clock() - time) >= timetowait then
					doPlayerAddItem(cid, 2173, 1)
					selfSay('Here take it.')
					setPlayerStorageValue(cid,201,0)
				else
					selfSay('Sorry, but You must wait until I reapir it..')
				end
			else
				selfSay('Sorry, You not gave me anything to repair.')
			end	
			    

		elseif string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Take care.')
			focus = 0
			talk_start = 0
		end
	end
end


function onCreatureChangeOutfit(creature)

end

function onThink()
  	if (os.clock() - talk_start) > 30 then
  		if focus > 0 then
  			selfSay('Next Please...')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Good bye then.')
 			focus = 0
 		end
 	end
end
