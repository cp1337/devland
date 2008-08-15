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
  		selfSay('Oh, please come in, ' .. getCreatureName(cid) .. '! What do you need?')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am a jeweler. Maybe you want to have a look at my wonderful offers.')	
	
		elseif msgcontains(msg, 'offer') then
			selfSay('I can offer you various gems, pearls or some wonderful jewels.')

		elseif msgcontains(msg, 'gems') then
        		selfSay('You can buy and sell small diamonds, sapphires, rubies, emeralds, and amethysts.')	

		elseif msgcontains(msg, 'pearls') then
        		selfSay('There are white and black pearls you can buy or sell.')	

		elseif msgcontains(msg, 'jewels') then
        		selfSay('Currently you can purchase wedding rings, golden amulets, and ruby necklaces.')




		elseif msgcontains(msg, 'sell small ruby') then
			selfSay('Do you want to sell a small ruby for 250 gold?.')
			sellit = 1
		elseif msgcontains(msg, 'sell small emerald') then
			selfSay('Do you want to sell a small emerald for 250 gold?.')
			sellit = 2
		elseif msgcontains(msg, 'sell small diamond') then
			selfSay('Do you want to sell a small diamond for 300 gold?.')
			sellit = 3
		elseif msgcontains(msg, 'sell small sapphire') then
			selfSay('Do you want to sell a small sapphire for 250 gold?.')
			sellit = 4
		elseif msgcontains(msg, 'sell small amethyst') then
			selfSay('Do you want to sell a small amethyst for 250 gold?.')
			sellit = 5
		elseif msgcontains(msg, 'sell black pearl') then
			selfSay('Do you want to sell a black pearl for 280 gold?.')
			sellit = 6
		elseif msgcontains(msg, 'sell white pearl') then
			selfSay('Do you want to sell a white pearl for 160 gold?.')
			sellit = 7
		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'small rubies') then
			selfSay('Do you want to sell a ' .. getCount(msg) .. ' small rubies?')
			count = getCount(msg)
			sellit = 11
		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'small emeralds') then
			selfSay('Do you want to sell a ' .. getCount(msg) .. ' small emeralds?')
			count = getCount(msg)
			sellit = 12
		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'small diamonds') then
			selfSay('Do you want to sell a ' .. getCount(msg) .. ' small diamonds?')
			count = getCount(msg)
			sellit = 13
		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'small sapphires') then
			selfSay('Do you want to sell a ' .. getCount(msg) .. ' small sapphires?')
			count = getCount(msg)
			sellit = 14
		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'small amethysts') then
			selfSay('Do you want to sell a ' .. getCount(msg) .. ' small amethysts?')
			count = getCount(msg)
			sellit = 15
		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'black pearls') then
			selfSay('Do you want to sell a ' .. getCount(msg) .. ' black pearls?')
			count = getCount(msg)
			sellit = 16
		elseif msgcontains(msg, 'sell') and msgcontains(msg, 'white pearls') then
			selfSay('Do you want to sell a ' .. getCount(msg) .. ' white pearls?')
			count = getCount(msg)
			sellit = 17


		elseif msgcontains(msg, 'small ruby') then
			selfSay('Do you want to buy a small ruby for 500 gold?.')
			buyit = 1
		elseif msgcontains(msg, 'small emerald') then
			selfSay('Do you want to buy a small emerald for 500 gold?.')
			buyit = 2
		elseif msgcontains(msg, 'small diamond') then
			selfSay('Do you want to buy a small diamond for 600 gold?.')
			buyit = 3
		elseif msgcontains(msg, 'small sapphire') then
			selfSay('Do you want to buy a small sapphire for 500 gold?.')
			buyit = 4
		elseif msgcontains(msg, 'small amethyst') then
			selfSay('Do you want to buy a small amethyst for 500 gold?.')
			buyit = 5
		elseif msgcontains(msg, 'black pearl') then
			selfSay('Do you want to buy a black pearl for 560 gold?.')
			buyit = 6
		elseif msgcontains(msg, 'white pearl') then
			selfSay('Do you want to buy a white pearl for 320 gold?.')
			buyit = 7
		elseif msgcontains(msg, 'wedding ring') then
			selfSay('Do you want to buy a wedding ring for 990 gold?.')
			buyit = 8
		elseif msgcontains(msg, 'golden amulet') then
			selfSay('Do you want to buy a golden amulet for 6600 gold?.')
			buyit = 9

		elseif msgcontains(msg, 'small rubies') then
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' small rubies?')
			count = getCount(msg)
			buyit = 11
		elseif msgcontains(msg, 'small emeralds') then
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' small emeralds?')
			count = getCount(msg)
			buyit = 12
		elseif msgcontains(msg, 'small diamonds') then
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' small diamonds?')
			count = getCount(msg)
			buyit = 13
		elseif msgcontains(msg, 'small sapphires') then
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' small sapphires?')
			count = getCount(msg)
			buyit = 14
		elseif msgcontains(msg, 'small amethysts') then
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' small amethysts?')
			count = getCount(msg)
			buyit = 15
		elseif msgcontains(msg, 'black pearls') then
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' black pearls?')
			count = getCount(msg)
			buyit = 16
		elseif msgcontains(msg, 'white pearls') then
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' white pearls?')
			count = getCount(msg)
			buyit = 17
		elseif msgcontains(msg, 'wedding rings') then
			selfSay('Do you want to buy a ' .. getCount(msg) .. ' wedding rings?')
			count = getCount(msg)
			buyit = 18

		
		elseif msgcontains(msg, 'yes') then
			if buyit == 1 then
				buy(cid,2147,1,500)
			elseif buyit == 2 then
				buy(cid,2149,1,500)
			elseif buyit == 3 then
                                buy(cid,2145,1,600)
			elseif buyit == 4 then
				buy(cid,2146,1,500)	
			elseif buyit == 5 then
                                buy(cid,2150,1,500)
			elseif buyit == 6 then
				buy(cid,2144,1,560)
			elseif buyit == 7 then
				buy(cid,2143,1,320)
			elseif buyit == 8 then
				buy(cid,2121,1,990)
			elseif buyit == 9 then
				buy(cid,2130,1,6600)


			
			elseif sellit == 1 then
				sell(cid,2147,1,250)
			elseif sellit == 2 then
				sell(cid,2149,1,250)
			elseif sellit == 3 then
                                sell(cid,2145,1,300)
			elseif sellit == 4 then
				sell(cid,2146,1,250)	
			elseif sellit == 5 then
                                sell(cid,2150,1,250)
			elseif sellit == 6 then
				sell(cid,2144,1,280)
			elseif sellit == 7 then
				sell(cid,2143,1,160)

	

			elseif buyit == 11 then
				buy(cid,2149,count,500)
			elseif buyit == 12 then
				buy(cid,2149,count,500)
			elseif buyit == 13 then
                		buy(cid,2145,count,600)
			elseif buyit == 14 then
				buy(cid,2146,count,500)	
			elseif buyit == 15 then
                		buy(cid,2150,count,560)
			elseif buyit == 16 then
				buy(cid,2144,count,320)
			elseif buyit == 17 then
				buy(cid,2143,count,320)
			elseif buyit == 18 then
				buy(cid,2121,count,990)

			
			elseif sellit == 11 then
				sell(cid,2149,count,250)
			elseif sellit == 12 then
				sell(cid,2149,count,250)
			elseif sellit == 13 then
                		sell(cid,2145,count,300)
			elseif sellit == 14 then
				sell(cid,2146,count,250)	
			elseif sellit == 15 then
                		sell(cid,2150,count,250)
			elseif sellit == 16 then
				sell(cid,2144,count,280)
			elseif sellit == 17 then
				sell(cid,2143,count,160)
				
		end

		elseif msgcontains(msg, 'no') then
			selfSay('Hmm, but next time.')
			buyit = 0
			sellit = 0
		end


		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Good bye.')
			focus = 0
			talk_start = 0
		end

		if string.find(msg, '(%a*)(%a*)') and buyit >= 1 then
			buyit = 0
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