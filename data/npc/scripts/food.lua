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
  		selfSay('Welcome to my humble shop, ' .. getCreatureName(cid) .. '.')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am the butcher. I am selling delicious meat.')	

		elseif msgcontains(msg, 'food') or msgcontains(msg, 'offer') then
        		selfSay('Are you looking for food? I can offer you ham or meat.')


		elseif msgcontains(msg, 'meat') then
			count = getCount(msg)
			cost = 3*count	
			selfSay('Do you want to buy a ' .. getCount(msg) .. '  meat ' .. cost .. 'gold ?')
			buyit = 1
		elseif msgcontains(msg, 'ham') then
			count = getCount(msg)
			cost = 6*count	
			selfSay('Do you want to buy a ' .. getCount(msg) .. '  ham ' .. cost .. 'gold ?')
			buyit = 2	
		
		elseif msgcontains(msg, 'yes') then
			if buyit == 1 then
				buy(cid,2666,count,3)
			elseif buyit == 2 then
				buy(cid,2671,count,6)			
		end

		elseif msgcontains(msg, 'no') then
			selfSay('Maybe you will buy it another time.')
			buyit = 0
		end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Please come and buy again.')
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