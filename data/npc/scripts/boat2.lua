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
			selfSay('Welcome on board, Sir ' .. getCreatureName(cid) .. '.')
			focus = cid
			talk_start = os.clock()
			TurnToPlayer(cid)
		end

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()

	     if msgcontains(msg, 'job') then
	          selfSay('I am the captain of this sailing-ship.')

	     elseif msgcontains(msg, 'sail') or msgcontains(msg, 'sailing') then
	          selfSay('Where do you want to go? To Vatone, Telmun?')
	     

	     elseif msgcontains(msg, 'vatone') then
		  selfSay('Do you seek a passage to Vatone for 120 gold?')
		  sail = 1

	     elseif msgcontains(msg, 'telmun') then
		  selfSay('Do you seek a passage to Telmun for 180 gold?')
		  sail = 2		  


	     elseif msgcontains(msg, 'yes') then
				if sail == 1 and pay(cid,120) then
					travel(cid, 453, 480, 6)
					selfSay('Set the sails!')
					focus = 0
					talk_start = 0

				elseif sail == 2 and pay(cid,160) then
					travel(cid, 453, 480, 6)
					selfSay('Set the sails!')
					focus = 0
					talk_start = 0

				elseif sail == 1 and not pay(cid,120) then
					selfSay('Sorry, you don\'t have enough money.')

				elseif sail == 2 and not pay(cid,160) then
					selfSay('Sorry, you don\'t have enough money.')
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
  			selfSay('Good bye. Recommend us, if you were satisfied with our service.')
  		end
  			focus = 0
  	end
	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Good bye. Recommend us, if you were satisfied with our service.')
 			focus = 0
 		end
 	end
end
