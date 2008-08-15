local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false
local buyit = 0
local count = 0

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

  	if (msgcontains(msg, 'hail') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Welcome citizen, ' .. getCreatureName(cid) .. '! ')
		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Aff, did someone tell anything? I think it\'s just imagine.')

  	elseif msgcontains(msg, 'hail') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am a Great traveler Ewryn. Show me respect when you talk to ME!')	
	
		elseif msgcontains(msg, 'travel')then
        		selfSay('Now i am on pension. I leave travel\'s for new guy\'s.')

		elseif msgcontains(msg, 'new')then
        		selfSay('I search for guy, who i can teach evrything what i know about world.')

		elseif msgcontains(msg, 'orelfera') then
        		selfSay('I born here, and now came for old years.')

		elseif msgcontains(msg, 'life') then
        		selfSay('My life was hard, but very interesting')

		elseif msgcontains(msg, 'quest') then
        		selfSay('You must find them by your self. How I made it.')

		end
	end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Farewell, ' .. getCreatureName(cid) .. '!')
			focus = 0
			talk_start = 0
		end
	end


function onCreatureChangeOutfit(creature)

end

function onThink()

  	if (os.clock() - talk_start) > 30 then
  		if focus > 0 then
  			selfSay('Well, bye then.')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Well, bye then.')
 			focus = 0
 		end
 	end
end