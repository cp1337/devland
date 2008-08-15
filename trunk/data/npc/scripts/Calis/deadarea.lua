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
			selfSay('Hello ' .. getCreatureName(cid) .. '! What brings you to me?')
			focus = cid
			talk_start = os.clock()
			TurnToPlayer(cid)
		else
			selfSay('Sorry, I talk only with premium players.')
			focus = 0
			talk_start = 0
		end

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()

	     if msgcontains(msg, 'job') then
	          selfSay('I am just old fisherman.')

	     elseif msgcontains(msg, 'dead zone') or msgcontains(msg, 'dead area') or msgcontains(msg, 'sail') or msgcontains(msg, 'swim') then
	          selfSay('What! Are you crazy! It is so danges... Hmmm, ok but for 300gp? Tell to me back or city to come back.')
		  sail = 1	

	     elseif msgcontains(msg, 'back') or msgcontains(msg, 'city') or msgcontains(msg, 'sail') or msgcontains(msg, 'swim') then
	          selfSay('What! Are you crazy! It is so danges... Hmmm, ok but for 300gp?')
		  sail = 2		  

	     elseif msgcontains(msg, 'yes') then
				if sail == 1 and pay(cid,300) then
					travel(cid, 421, 613, 7)
					selfSay('Set the sails!')
					focus = 0
					talk_start = 0

				elseif sail == 2 and pay(cid,300) then
					travel(cid, 411, 619, 7)
					selfSay('Set the sails!')
					focus = 0
					talk_start = 0

				elseif sail == 2 and not pay(cid,300) then
					selfSay('Sorry, you don\'t have enough money.')

				elseif sail == 1 and not pay(cid,300) then
					selfSay('Sorry, you don\'t have enough money.')

				end


		elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
			selfSay('Good bye then.')
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
  			selfSay('Good bye then.')
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
