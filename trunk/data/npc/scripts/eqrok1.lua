local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false
local buyit = 0
local count = 0

function onCreatureAppear(creature)
	attacking = true
	target = creature
end


function onCreatureDisappear(id)
	if id == target then
		target = 0
		attacking = false
		selfAttackCreature(0)
		following = false
	end
end


function onCreatureAppear(creature)

end


function msgcontains(txt, str)
  	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onCreatureSay(cid, type, msg)
  	msg = string.lower(msg)

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Welcome ' .. getCreatureName(cid) .. '.')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('One moment, ' .. getCreatureName(cid) .. '! I\'ll be with you in no time.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am a local merchant. I\'m selling and buing equipment or wepons.')		

		elseif msgcontains(msg, 'help') then
        		selfSay('Ofcourse i help You, just tell me what you want to buy.')


		elseif msgcontains(msg, 'quest') then
			selfSay('There are many quests in wolrd of DevLand. Ask citizens, maybe someone have one for You.')
			buyit = 0

		elseif msgcontains(msg, 'weapon') or msgcontains(msg, 'weapons') or msgcontains(msg, 'equipment') or msgcontains(msg, 'offer') then
        		selfSay('You can se my offer on tables')

------------------- Leather set -----------------------------------------------------------------------

		elseif msgcontains(msg, 'boots') then
			selfSay('Do you want to buy a leather boots for 15gp?')
			buyit = 1

		elseif msgcontains(msg, 'leather armor') then
			selfSay('Do you want to buy a leather armor for 25gp?')
			buyit = 2

		elseif msgcontains(msg, 'leather helmet') then
			selfSay('Do you want to buy a leather helmet for 15gp?')
			buyit = 3

		elseif msgcontains(msg, 'leather trousers') or msgcontains(msg, 'leather legs') then
			selfSay('Do you want to buy a leather trousers for 25gp?')
			buyit = 4

------------------- Studded set -------------------------------------------------------------------------

		elseif msgcontains(msg, 'studded armor') then
			selfSay('Do you want to buy a studded armor for 35gp?')
			buyit = 5

		elseif msgcontains(msg, 'studded shield') then
			selfSay('Do you want to buy a studded shield for 40gp?')
			buyit = 6

		elseif msgcontains(msg, 'studded helmet') then
			selfSay('Do you want to buy a studded helmet for 25gp?')
			buyit = 7

		elseif msgcontains(msg, 'studded legs') then
			selfSay('Sorry, we are out of them. Maybe if you feel enaugh strong try loot them from spearman.')

------------------- Other armors -------------------------------------------------------------------------

		elseif msgcontains(msg, 'wooden shield') then
			selfSay('Do you want to buy a wooden shield for 25gp?')
			buyit = 8

		elseif msgcontains(msg, 'chain helmet') then
			selfSay('Do you want to buy a chain helmet for 20gp?')
			buyit = 9

		elseif msgcontains(msg, 'brass helmet') then
			selfSay('Do you want to buy a brass helmet for 60gp?')
			buyit = 10

------------------- Weapons ---------------------------------------------------------------------------------

		elseif msgcontains(msg, 'rapier') then
			selfSay('Do you want to buy a rapier for 25gp?')
			buyit = 11

		elseif msgcontains(msg, 'hand axe') then
			selfSay('Do you want to buy a hand axe for 25gp?')
			buyit = 12

		elseif msgcontains(msg, 'studded club') then
			selfSay('Do you want to buy a studded club for 15gp?')
			buyit = 13

		elseif msgcontains(msg, 'machete') then
			selfSay('Do you want to buy a machete for 35gp?')
			buyit = 14

		elseif msgcontains(msg, 'short sword') then
			selfSay('Do you want to buy a short sword for 30gp?')
			buyit = 15

------------------- Equipment ---------------------------------------------------------------------------------

		elseif msgcontains(msg, 'rope') then
			selfSay('Do you want to buy a rope for 40gp?')
			buyit = 16

		elseif msgcontains(msg, 'shovel') then
			selfSay('Do you want to buy a shovel for 20gp?')
			buyit = 17

		elseif msgcontains(msg, 'scythe') then
			selfSay('Do you want to buy a scythe for 50gp?')
			buyit = 18

		elseif msgcontains(msg, 'fishing rod') then
			selfSay('Do you want to buy a fishing rod for 150gp?')
			buyit = 19

------------------ Selling EQ ---------------------------------------------------------------------------------

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'rope') then
			count = getCount(msg)
			cost = 10*count
			buyit = 50
			if count > 1 then
				selfSay('Do you want to sell a ' .. getCount(msg) .. ' ropes for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a rope for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'fishing rod') then
			count = getCount(msg)
			cost = 40*count
			buyit = 51
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' rods for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a rod for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'wooden shield') then
			count = getCount(msg)
			cost = 8*count
			buyit = 52
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' wooden shields for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a wooden shield for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'studded shield') then
			count = getCount(msg)
			cost = 15*count
			buyit = 53
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' studded shields for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a studded shield for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'sword') then
			count = getCount(msg)
			cost = 25*count
			buyit = 54
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' swords for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a sword for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'mace') then
			count = getCount(msg)
			cost = 25*count
			buyit = 55
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' maces for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a mace for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'rapier') then
			count = getCount(msg)
			cost = 10*count
			buyit = 56
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' rapiers for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a rapier for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'viking helmet') then
			count = getCount(msg)
			cost = 25*count
			buyit = 57
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' viking helmets for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a viking helmet for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'legion helmet') then
			count = getCount(msg)
			cost = 30*count
			buyit = 58
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' legion helmets for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a legion helmet for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'studded helmet') then
			count = getCount(msg)
			cost = 20*count
			buyit = 59
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' studded helmets for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a studded helmet for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'chain armor') then
			count = getCount(msg)
			cost = 40*count
			buyit = 60
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' chain armors for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a chain armor for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'brass shield') then
			count = getCount(msg)
			cost = 25*count
			buyit = 61
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' brass shields for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a brass shield for ' .. cost .. 'gp ?')
			end

		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'studded armor') then
			count = getCount(msg)
			cost = 15*count
			buyit = 62
			if count > 1 then
				selfSay('Do you want to sell ' .. getCount(msg) .. ' studded armors for ' .. cost .. 'gp ?')
			else
				selfSay('Do you want to sell a studded armor for ' .. cost .. 'gp ?')
			end

------------------ Accepting offer -----------------------------------------------------------------
		elseif msgcontains(msg, 'yes') then	
			if buyit == 1 then
				buy(cid,2643,1,15)	
			elseif buyit == 2 then
				buy(cid,2467,1,25)
			elseif buyit == 3 then
				buy(cid,2461,1,15)
			elseif buyit == 4 then
				buy(cid,2649,1,25)
			elseif buyit == 5 then
				buy(cid,2484,1,35)
			elseif buyit == 6 then
				buy(cid,2526,1,40)
			elseif buyit == 7 then
				buy(cid,2482,1,25)
			elseif buyit == 8 then
				buy(cid,2512,1,25)
			elseif buyit == 9 then
				buy(cid,2458,1,20)
			elseif buyit == 10 then
				buy(cid,2460,1,60)
			elseif buyit == 11 then
				buy(cid,2384,1,25)
			elseif buyit == 12 then
				buy(cid,2380,1,25)
			elseif buyit == 13 then
				buy(cid,2448,1,15)
			elseif buyit == 14 then
				buy(cid,2420,1,35)
			elseif buyit == 15 then
				buy(cid,2406,1,30)
			elseif buyit == 16 then
				buy(cid,2120,1,40)
			elseif buyit == 17 then
				buy(cid,2554,1,20)
			elseif buyit == 18 then
				buy(cid,2550,1,50)
			elseif buyit == 19 then
				buy(cid,2580,1,150)
---------------- sell -------------------------------
			elseif buyit == 50 then
				sell(cid,2120,count,10)
			elseif buyit == 51 then
				sell(cid,2580,count,40)
			elseif buyit == 52 then
				sell(cid,2512,count,8)
			elseif buyit == 53 then
				sell(cid,2526,count,15)
			elseif buyit == 54 then
				sell(cid,2376,count,25)
			elseif buyit == 55 then
				sell(cid,2398,count,25)
			elseif buyit == 56 then
				sell(cid,2384,count,10)
			elseif buyit == 57 then
				sell(cid,2473,count,25)
			elseif buyit == 58 then
				sell(cid,2480,count,30)
			elseif buyit == 59 then
				sell(cid,2482,count,20)
			elseif buyit == 60 then
				sell(cid,2464,count,40)
			elseif buyit == 61 then
				sell(cid,2511,count,25)
			elseif buyit == 62 then
				sell(cid,2484,count,15)			
		end
			buyit = 0
			buyit = 0

		elseif msgcontains(msg, 'no') and buyit >= 1  then
			selfSay('As you wish.')
			buyit = 0

		elseif msgcontains(msg, 'waldensi') then
			selfSay('Yes, thats me.')
			buyit = 0

		elseif msgcontains(msg, 'name') then
			selfSay('Everyone call to me Waldensi.')
			buyit = 0
		end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Take care.')
			focus = 0
			talk_start = 0
		end

	end

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
