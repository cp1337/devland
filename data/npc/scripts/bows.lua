local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false
local buyit = 0
local sellit = 0
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
  		selfSay('Ashari ' .. getCreatureName(cid) .. '.')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I sell bows, arrows, crossbows and bolts. I also teach some spells.')

		elseif msgcontains(msg, 'spells') then
        		selfSay('I teach Conjure Arrow, Poison Arrow, and Explosive Arrow.')



		elseif msgcontains(msg, 'bow') then
			selfSay('Do you want to buy a bow for 350 gold?')
			buyit = 1
		elseif msgcontains(msg, 'crossbow') then
			selfSay('Do you want to buy a crossbow for 450 gold?')
			buyit = 2

	
		elseif msgcontains(msg, 'bolt') then
			count = getCount(msg)
			cost = 3*count	
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' bolts for ' .. cost .. 'gp ?')
			buyit = 3
		elseif msgcontains(msg, 'arrow') then
			count = getCount(msg)
			cost = 2*count
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' arrow for ' .. cost .. 'gp ?')
			buyit = 4

		
		elseif msgcontains(msg, 'yes') then
			if buyit == 1 then
				buy(cid,2456,1,350)
				buyit = 0
			elseif buyit == 2 then
				buy(cid,2455,1,450)
				buyit = 0
			elseif buyit == 3 then
                                buy(cid,2543,count,3)
				buyit = 0
			elseif buyit == 4 then
				buy(cid,2544,count,2)
				buyit = 0				
		end


		elseif msgcontains(msg, 'no') then
			selfSay('Maybe we will make the deal another time.')
			buyit = 0
			sellit = 0
		end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Asha Thrazi.')
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