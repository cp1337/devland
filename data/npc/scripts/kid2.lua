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
		selfSay('What up?')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)


	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('Im just normal kid.')	

		elseif msgcontains(msg, 'teacher') then
        		selfSay('I hate it, i learning only becouse i must.')
		end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Good bye, ' .. getCreatureName(cid) .. '. Remember about homework.')
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
  			selfSay('Are You listen Me?')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Hey, come back Im not end Lesson.')
 			focus = 0
 		end
 	end
end