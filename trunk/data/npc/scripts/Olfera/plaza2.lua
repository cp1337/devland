local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false
local sail = 0

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
		if isPremium(cid) == 1 then
			selfSay('Hello ' .. getCreatureName(cid) .. '! I can take you to Orelfera beach for 30gp.')
			focus = cid
			talk_start = os.clock()
			TurnToPlayer(cid)
		else
			selfSay('Sorry, my service is only for premium players.')
			focus = 0
			talk_start = 0
		end

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()

	     if msgcontains(msg, 'job') then
	          selfSay('I am the captain of this sailing-boat.')

	     elseif msgcontains(msg, 'sail') or msgcontains(msg, 'sailing') or msgcontains(msg, 'back') then
	          selfSay('Ready to sail back?')
		  sail = 1		  

	     elseif msgcontains(msg, 'yes') then
				if sail == 1 then
					travel(cid, 470, 496, 7)
					selfSay('Set the sails!')
					focus = 0
					talk_start = 0
				end


		elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
			selfSay('Good bye. Recommend us, if you were satisfied with our service.')
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
  			selfSay('Good bye. Recommend me, if you were satisfied with my service.')
  		end
  			focus = 0
  	end
	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Good bye. Recommend me, if you were satisfied with my service.')
 			focus = 0
 		end
 	end
end
