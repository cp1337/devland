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
  	local msg = string.lower(msg)

  	if msgcontains(msg, 'hi') and focus == 0 and getDistanceToCreature(cid) < 4 then
  		selfSay('Welcome ' .. getCreatureName(cid) .. '! Whats your need?')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and focus ~= cid and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am barman Jackil.')

		elseif msgcontains(msg, 'jackil') then
			selfSay('Yep, that\'s me.')

		elseif msgcontains(msg, 'offer') then
			selfSay('I can sell you beer or wine.')

		elseif msgcontains(msg, 'grapes') or msgcontains(msg, 'grape') then
			selfSay('Hmm.. Yes, i need help. My stockpiles of grapes was run out.')
			selfSay('Find for me some grapes, then I will reward You.')


-- Others --------------------------------------------------------------------------------

		elseif msgcontains(msg, 'beer') then
			talk_state = 10
			selfSay('Do you want to buy mug of beer for 5 gold pieces.')

		elseif msgcontains(msg, 'wine')then
			selfSay('Sorry, but we run out of grapes. How you know they are needed to make wine.')


		elseif msgcontains(msg, 'water') then
		       selfSay('You trying to amuse me?? It\'s bar, you can take water from well.')

		elseif msgcontains(msg, 'golden mug') then
		       selfSay('Much time ago I won it in competition for the best barman of devland.')
		       selfSay('There were fine moments.')		

-- Yes -----------------------------------------------------------------------------------

		elseif msgcontains(msg, 'yes') and talk_state == 10 then
				buyFluidContainer(cid,2006,1,5,2)
				talk_state = 0

-- NO ------------------------------------------------------------------------------------

		elseif msgcontains(msg, 'no') and talk_state == 10 then
				selfSay('Ok, maybe next time.')
				talk_state = 0

-- END -----------------------------------------------------------------------------------

		elseif string.find(msg, '(%a*)bye(%a*)') and getDistanceToCreature(cid) < 4 then
			selfSay('Good bye.')
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
