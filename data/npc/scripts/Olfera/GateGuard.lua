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
  		selfSay('Welcome citizen, ' .. getCreatureName(cid) .. '! ')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am a protector of the people of Orelfera.')	
	
		elseif msgcontains(msg, 'devland')then
        		selfSay('That\'s where we are. The world of DevLand.')


		elseif msgcontains(msg, 'orelfera') then
        		selfSay('Yes, that\'s my city. If you want ask about it just talk for help')


		elseif msgcontains(msg, 'help') then
        		selfSay('The harbour is to the South-East, Depo and Temple it to North-East, Church is below gate. You will find other shops and the Citizen Portal in undergrounds.')


		elseif msgcontains(msg, 'undergrounds') or msgcontains(msg, 'underground') then
        		selfSay('It\'s part of City located under ground. You can enter there by stairs in depo.')

		elseif msgcontains(msg, 'fuck') or msgcontains(msg, 'suck') or msgcontains(msg, 'bitch') then
        		selfSay('Hey ' .. getCreatureName(cid) .. '! We have rules here! Get this!.')
                  hp = getPlayerHealth(cid) - 30
                  doPlayerAddHealth(cid, -hp)
                  doSendMagicEffect(cid,31)

		elseif msgcontains(msg, 'god') then
        		selfSay('They created DevLand and all life on it. Visit our library and learn about them.')


		elseif msgcontains(msg, 'life') then
        		selfSay('The gods decorated DevLand with various forms of life. Plants, the citizens, and even the monsters.')


		elseif msgcontains(msg, 'citizens') then
        		selfSay('Many people live in this city. Just go look around here.')


		elseif msgcontains(msg, 'plants') then
        		selfSay('Just walk around. You will see grass, trees, and bushes.')

		
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