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
  		selfSay('Oh, please come in, ' .. getCreatureName(cid) .. '. What do you need?')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
		        selfSay('I am selling equipment of all kinds. Do you need anything?')		

		elseif msgcontains(msg, 'equipment') or msgcontains(msg, 'offer') then
		        selfSay('My inventory is large, just have a look at the blackboards.')
	

		elseif msgcontains(msg, 'shovel') or msgcontains(msg, 'shovels') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' shovels?.')
				buyit = 101
				count = getCount(msg)
			else
				selfSay('Do you want to buy a shovel?.')
				buyit = 1
			end
			
		elseif msgcontains(msg, 'backpack') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' backpacks?.')
				buyit = 102
				count = getCount(msg)
			else
				selfSay('Do you want to buy a backpack?.')
				buyit = 2
			end

		elseif msgcontains(msg, 'scythe') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' scythes?.')
				buyit = 103
				count = getCount(msg)
			else
				selfSay('Do you want to buy a scythe?.')
				buyit = 3
			end

		elseif msgcontains(msg, 'bag') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' bags?.')
				buyit = 104
				count = getCount(msg)
			else
				selfSay('Do you want to buy a bag?.')
				buyit = 4
			end

		elseif msgcontains(msg, 'watch') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' watches?.')
				buyit = 105
				count = getCount(msg)
			else
				selfSay('Do you want to buy a watch?.')
				buyit = 5
			end

		elseif msgcontains(msg, 'pick') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' picks?.')
				buyit = 106
				count = getCount(msg)
			else
				selfSay('Do you want to buy a pick?.')
				buyit = 6
			end

		elseif msgcontains(msg, 'footbal') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' footballs?.')
				buyit = 107
				count = getCount(msg)
			else
				selfSay('Do you want to buy a football?.')
				buyit = 7
			end

		elseif msgcontains(msg, 'fishing rod') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' fishing rods?.')
				buyit = 108
				count = getCount(msg)
			else
				selfSay('Do you want to buy a fishing rod?.')
				buyit = 8
			end

		elseif msgcontains(msg, 'torch') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' torches?.')
				buyit = 109
				count = getCount(msg)
			else
				selfSay('Do you want to buy a torch?.')
				buyit = 9
			end

		elseif msgcontains(msg, 'rope') then
			if getCount(msg) > 1 then
				selfSay('Do you want to buy a ' .. getCount(msg) .. ' ropes?.')
				buyit = 110
				count = getCount(msg)
			else
				selfSay('Do you want to buy a rope?.')
				buyit = 10
			end

		elseif msgcontains(msg, 'yes') then
			if buyit == 1 then
				buy(cid,2554,1,30)
			elseif buyit == 2 then
				buy(cid,1998,1,20)
			elseif buyit == 3 then
                                buy(cid,2550,1,80)
			elseif buyit == 4 then
				buy(cid,1991,1,10)	
			elseif buyit == 5 then
                                buy(cid,2036,1,100)
			elseif buyit == 6 then
				buy(cid,2553,1,50)
			elseif buyit == 7 then
				buy(cid,2109,1,111)
			elseif buyit == 8 then
				buy(cid,2580,1,150)
			elseif buyit == 9 then
				buy(cid,2050,1,2)
			elseif buyit == 10 then
				buy(cid,2120,1,50)
			
			elseif buyit == 101 then
				buy(cid,2554,count,30)
			elseif buyit == 102 then
				buy(cid,1998,count,20)
			elseif buyit == 103 then
                                buy(cid,2550,count,80)
			elseif buyit == 104 then
				buy(cid,1991,count,10)	
			elseif buyit == 105 then
                                buy(cid,2036,count,100)
			elseif buyit == 106 then
				buy(cid,2553,count,50)
			elseif buyit == 107 then
				buy(cid,2109,count,111)
			elseif buyit == 108 then
				buy(cid,2580,count,150)
			elseif buyit == 109 then
				buy(cid,2050,count,2)
			elseif buyit == 110 then
				buy(cid,2120,count,50)
		end

		elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
			selfSay('Good bye, ' .. getCreatureName(cid) .. '!')
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
