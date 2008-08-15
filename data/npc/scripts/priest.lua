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

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Welcome in the name of the gods, pilgrim ' .. getCreatureName(cid) .. '!')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am a priest of the great pantheon.')	

		elseif msgcontains(msg, 'god') then
        		selfSay('The gods of good guard us and guide us, the gods of evil want to destroy us and steal our souls!')	

		elseif msgcontains(msg, 'name') then
        		selfSay('My name is Malandy. And the spirits tell me that you are ' .. getCreatureName(cid) .. '.')

		elseif msgcontains(msg, 'name') then
        		selfSay('It is my mission to spread knowledge about the gods.')

		elseif msgcontains(msg, 'evil') then
        		selfSay('The gods we call the evil ones are Zathroth, Fafnar, Brog, Urgith, and the Archdemons!')	

		elseif msgcontains(msg, 'good guard') then
        		selfSay('The gods we call the good ones are Fardos, Uman, the Elements, Suon, Crunor, Nornur, Bastesh, Kirok, Toth, and Banor.')

		elseif msgcontains(msg, 'archdemons') then
        		selfSay('The demons are followers of Zathroth. The cruelest are known as the ruthless seven.')

		elseif msgcontains(msg, 'Zathroth') then
        		selfSay('Zathroth is the destructive aspect of magic. He is the deceiver and the thief of souls.')

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Good bye, ' .. getCreatureName(cid) .. '. May the gods guard you, my child!')
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