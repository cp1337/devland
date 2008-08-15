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
  		selfSay('Hello, ' .. getCreatureName(cid) .. '! I will heal you if you are injured. Feel free to ask me for help.')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am just a humble monk. Ask me if you need help or healing.')	
	
		elseif msgcontains(msg, 'devland')then
        		selfSay('That\'s where we are. The world of DevLand.')

		elseif msgcontains(msg, 'fight') then
        		selfSay('Take a weapon in your hand, activate your combat mode, and select a target. After a fight you should eat something to heal your wounds.')


		elseif msgcontains(msg, 'gold') then
        		selfSay('You have to slay monsters and take their gold. Also You can sell loot, runes, food or corpses at shop.')


		elseif msgcontains(msg, 'fuck') or msgcontains(msg, 'suck') or msgcontains(msg, 'bitch') then
        		selfSay('Hey ' .. getCreatureName(cid) .. '! We have rules here! Behave or get banned.')


		elseif msgcontains(msg, 'monk') then
        		selfSay('I sacrifice my life to serve the good gods of DevLand.')


		elseif msgcontains(msg, 'god') then
        		selfSay('They created DevLand and all life on it. Visit our library and learn about them.')


		elseif msgcontains(msg, 'life') then
        		selfSay('The gods decorated DevLand with various forms of life. Plants, the citizens, and even the monsters.')


		elseif msgcontains(msg, 'citizens') then
        		selfSay('Many people live in Orelfera. Walk around and talk to them.')


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