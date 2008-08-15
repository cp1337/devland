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

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Hello, ' .. getCreatureName(cid) .. '. ')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am a Usher of this Zoo. Maybe want buy ticket?')	
	
		elseif msgcontains(msg, 'offer')then
        		selfSay('I can sell You ticket.')


		elseif msgcontains(msg, 'ticket') then
        		selfSay('So you want buy ticket for 160gp')
                 	talk_state = 2

		elseif msgcontains(msg, 'broadcast') then
        		commandSay('/green http://www.devland.info')

		elseif msgcontains(msg, 'orelfera') then
        		selfSay('Yes, that\'s that city, with fantastic Zoo.')


		elseif msgcontains(msg, 'help') then
        		selfSay('If you need help ask city guard or temple monk for it.')



		elseif msgcontains(msg, 'fuck') or msgcontains(msg, 'suck') or msgcontains(msg, 'bitch') then
        		selfSay('Hey ' .. getCreatureName(cid) .. '! We have rules here!')                

		elseif msgcontains(msg, 'god') then
        		selfSay('They created DevLand and all life on it. Visit our library and learn about them.')


		elseif msgcontains(msg, 'life') then
        		selfSay('It\'s suck. I have hope i will be not Usher all life.')


		elseif msgcontains(msg, 'citizens') then
        		selfSay('All citizens cooming to Zoo with family to see Animals.')
		
		elseif msgcontains(msg, 'yes') and talk_state == 2 then
		     buy(cid,6086,1,160)
		     talk_state = 0			    

			
		elseif string.find(msg, '(%a*)(%a*)') and talk_state == 2 then
		     talk_state = 0	


		elseif string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Farewell, ' .. getCreatureName(cid) .. '!')
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