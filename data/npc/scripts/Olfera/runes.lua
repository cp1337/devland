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
  	local msg = string.lower(msg)

  	if msgcontains(msg, 'hi') and focus == 0 and getDistanceToCreature(cid) < 8 then
  		selfSay('Welcome ' .. getCreatureName(cid) .. '! Whats your need?')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and focus ~= cid and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am the head alchemist of this City. I keep the secret recipies of our ancestors. Besides, I am selling mana and life fluids,spellbooks, wands, rods and runes.')

-- Main Runes ---------------------------------------------------------------------------------

		elseif msgcontains(msg, 'spell rune') then
			selfSay('I sell missile runes, explosive runes, field runes, wall runes, bomb runes, healing runes, convince creature rune and chameleon rune.')

		elseif msgcontains(msg, 'missile runes') then
			selfSay('I can offer you light magic missile runes, heavy magic missile runes and sudden death runes.')

		elseif msgcontains(msg, 'explosive runes') then
			selfSay('I can offer you fireball runes, great fireball runes and explosion runes.')

		elseif msgcontains(msg, 'field runes') then
			selfSay('I can offer you fire field runes, energy field runes, poison field runes and destroy field runes.')

		elseif msgcontains(msg, 'wall runes') then
			selfSay('I can offer you fire wall runes, energy wall runes and poison wall runes.')

		elseif msgcontains(msg, 'bomb runes') then
			selfSay('I can offer you firebomb runes.')

		elseif msgcontains(msg, 'healing runes') then
			selfSay('I can offer you antidote runes, intense healing runes and ultimate healing runes.')

-- Runes ---------------------------------------------------------------------------------

		elseif msgcontains(msg, 'light magic missile') then
			count = getCount(msg)
			cost = count*5
			talk_state = 20
			if count >= 2 then
			    selfSay('Do you want to buy ' .. count .. ' light magic missile runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a light magic missile rune for 5 gold?')
			end

		elseif msgcontains(msg, 'heavy magic missile') or msgcontains(msg, 'hmm') then
			count = getCount(msg)
			cost = count*10
			talk_state = 21
			if count >= 2 then
			    selfSay('Do you want to buy ' .. count .. ' heavy magic missile runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a heavy magic missile rune for 10 gold?')
			end

		elseif msgcontains(msg, 'sudden death') or msgcontains(msg, 'sd') then
			count = getCount(msg)
			cost = count*110
			talk_state = 22
			if count >= 2 then
			    selfSay('Do you want to buy ' .. count .. ' sudden death runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a sudden death rune for 110 gold?')
			end

		elseif msgcontains(msg, 'great fireball') or msgcontains(msg, 'gf') then
			count = getCount(msg)
			cost = count*25
			talk_state = 23
			if count >= 2 then
			    selfSay('Do you want to buy ' .. count .. ' great fireball runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a great fireball rune for 25 gold?')
			end

		elseif msgcontains(msg, 'explosion') or msgcontains(msg, 'explo') then
			count = getCount(msg)
			cost = count*30
			talk_state = 24
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' explosion runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a explosion rune for 30 gold?')
			end

		elseif msgcontains(msg, 'fire field') or msgcontains(msg, 'ff') then
			count = getCount(msg)
			cost = count*10
			talk_state = 25
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' fire field runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a fire field rune for 10 gold?')
			end

		elseif msgcontains(msg, 'energy field') or msgcontains(msg, 'ef') then
			count = getCount(msg)
			cost = count*30
			talk_state = 26
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' energy field runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a energy field rune for 30 gold?')
			end

		elseif msgcontains(msg, 'poison field') or msgcontains(msg, 'pf') then
			count = getCount(msg)
			cost = count*15
			talk_state = 27
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' poison field runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a poison field rune for 15 gold?')
			end

		elseif msgcontains(msg, 'destroy field') or msgcontains(msg, 'df') then
			count = getCount(msg)
			cost = count*20
			talk_state = 28
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' destroy field runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a destroy field rune for 20 gold?')
			end

		elseif msgcontains(msg, 'fire wall') or msgcontains(msg, 'fw') then
			count = getCount(msg)
			cost = count*25
			talk_state = 29
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' fire wall runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a fire wall rune for 25 gold?')
			end

		elseif msgcontains(msg, 'energy wall') or msgcontains(msg, 'ew') then
			count = getCount(msg)
			cost = count*30
			talk_state = 30
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' energy wall runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a energy wall rune for 30 gold?')
			end

		elseif msgcontains(msg, 'poison wall') or msgcontains(msg, 'pw') then
			count = getCount(msg)
			cost = count*20
			talk_state = 31
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' poison wall runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a poison wall rune for 20 gold?')
			end

		elseif msgcontains(msg, 'antidote') then
			count = getCount(msg)
			cost = count*25
			talk_state = 32
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' antidote runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a antidote rune for 25 gold?')
			end

		elseif msgcontains(msg, 'intense healing') or msgcontains(msg, 'ih') then
			count = getCount(msg)
			cost = count*30
			talk_state = 33
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' intense healing runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a intense healing rune for 30 gold?')
			end

		elseif msgcontains(msg, 'ultimate healing') or msgcontains(msg, 'uh') then
			count = getCount(msg)
			cost = count*60
			talk_state = 34
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' ultimate healing runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a ultimate healing rune for 60 gold?')
			end

		elseif msgcontains(msg, 'blank') then
			count = getCount(msg)
			cost = count*5
			talk_state = 35
			if count >= 2 then
			selfSay('Do you want to buy ' .. count .. ' blank runes for ' .. cost .. '.')
			else
			    selfSay('Do you want to buy a blank rune for 5 gold?')
			end


-- Wands and Rods --------------------------------------------------------------------------
	
		elseif msgcontains(msg, 'vortex') then
			talk_state = 50
			selfSay('This wand is only for sorcerers of level 7 and above. Would you like to buy a wand of vortex for 500 gold?')

		elseif msgcontains(msg, 'dragonbreath') then
			talk_state = 51
			selfSay('This wand is only for sorcerers of level 13 and above. Would you like to buy a wand of dragonbreath for 1000 gold?')

		elseif msgcontains(msg, 'plague') then
			talk_state = 52
			selfSay('This wand is only for sorcerers of level 19 and above. Would you like to buy a wand of plague for 5000 gold?')

		elseif msgcontains(msg, 'cosmic Energy') then
			talk_state = 53
			selfSay('This wand is only for sorcerers of level 26 and above. Would you like to buy a wand of cosmic energy for 10000 gold?')

		elseif msgcontains(msg, 'inferno') then
			selfSay('Sorry, this wand contains magic far too powerful and we are afraid to store it here. I heard they have a few of these at the Premium academy though.')

		elseif msgcontains(msg, 'snakebite') then
			talk_state = 55
			selfSay('This rod is only for druids of level 7 and above. Would you like to buy a snakebite rod for 500 gold?')

		elseif msgcontains(msg, 'moonlight') then
			talk_state = 56
			selfSay('This rod is only for druids of level 13 and above. Would you like to buy a moonlight rod for 1000 gold?')

		elseif msgcontains(msg, 'volcanic') then
			talk_state = 57
			selfSay('This rod is only for druids of level 19 and above. Would you like to buy a volcanic rod for 5000 gold?')

		elseif msgcontains(msg, 'quagmire') then
			talk_state = 58
			selfSay('This rod is only for druids of level 26 and above. Would you like to buy a quagmire rod for 10000 gold?')

		elseif msgcontains(msg, 'tempest') then
			selfSay('Sorry, this rod contains magic far too powerful and we are afraid to store it here. I heard they have a few of these at the Premium academy though.')
	
		elseif msgcontains(msg, 'wands') then
			selfSay('Wands can be wielded by sorcerers only and have a certain level requirement. There are five different wands, would you like to hear about them?')
			talk_state = 2
			
		elseif msgcontains(msg, 'rods') then
			selfSay('Rods can be wielded by druids only and have a certain level requirement. There are five different rods, would you like to hear about them?')
			talk_state = 3

-- Others --------------------------------------------------------------------------------

		elseif msgcontains(msg, 'mana fluid') or msgcontains(msg, 'mana fluids') then
			count = getCount(msg)
			cost = count*55
			talk_state = 36
			if count >= 2 then
			    selfSay('Do you want to buy ' .. count .. ' mana fluids for ' .. cost .. '.')
			else
			     selfSay('Do you want to buy mana fluid for 55 gold')
			end

		elseif msgcontains(msg, 'life fluid') or msgcontains(msg, 'life fluids') then
		       	count = getCount(msg)
			cost = count*60
			talk_state = 37
			if count >= 2 then
			    selfSay('Do you want to buy ' .. count .. ' life fluids for ' .. cost .. '.')
			else
			     selfSay('Do you want to buy life fluid for 60 gold')
			end

		elseif msgcontains(msg, 'spellbook') then
		       talk_state = 38
		       selfSay('A spellbook is a nice tool for beginners. Do you want to buy one for 150 gold?')		

-- Yes -----------------------------------------------------------------------------------

		elseif msgcontains(msg, 'yes') then
			if talk_state == 2 then
				selfSay('The names of the wands are \'Wand of Vortex\', \'Wand of Dragonbreath\', \'Wand of Plague\', \'Wand of Cosmic Energy\' and \'Wand ofInferno\'. Which one would you like to buy?')
			elseif talk_state == 3 then
				selfSay('The names of the rods are \'Snakebite Rod\', \'Moonlight Rod\', \'Volcanic Rod\', \'Quagmire Rod\', and \'Tempest Rod\'. Which one would you like to buy?')
			elseif talk_state == 20 then
                                buy(cid,2287,count,5)
			elseif talk_state == 21 then
				buy(cid,2311,count,10)
			elseif talk_state == 22 then
				buy(cid,2268,count,110)
			elseif talk_state == 23 then
                                buy(cid,2304,count,25)
			elseif talk_state == 24 then
				buy(cid,2313,count,30)	
			elseif talk_state == 25 then
				buy(cid,2301,count,10)
			elseif talk_state == 26 then
                                buy(cid,2277,count,15)
			elseif talk_state == 27 then
				buy(cid,2285,count,15)	
			elseif talk_state == 28 then
				buy(cid,2261,count,10)
			elseif talk_state == 29 then
                                buy(cid,2303,count,25)
			elseif talk_state == 30 then
				buy(cid,2279,count,30)	
			elseif talk_state == 31 then
				buy(cid,2289,count,20)
			elseif talk_state == 32 then
                                buy(cid,2266,count,25)
			elseif talk_state == 33 then
				buy(cid,2265,count,35)
			elseif talk_state == 34 then
				buy(cid,2273,count,60)
			elseif talk_state == 35 then
				buy(cid,2260,count,5)
			elseif talk_state == 36 then
				buyFluidContainer(cid,2006,count,55,7)
			elseif talk_state == 37 then
				buyFluidContainer(cid,2006,count,60,10)
			elseif talk_state == 38 then
				buy(cid,2175,1,150)
			elseif talk_state == 50 then
				buy(cid,2190,1,500)
			elseif talk_state == 51 then
				buy(cid,2191,1,1000)
			elseif talk_state == 52 then
				buy(cid,2188,1,5000)
			elseif talk_state == 53 then
				buy(cid,2189,1,10000)
			elseif talk_state == 55 then
				buy(cid,2182,1,500)
			elseif talk_state == 56 then
				buy(cid,2186,1,1000)
			elseif talk_state == 37 then
				buy(cid,2185,1,5000)
			elseif talk_state == 58 then
				buy(cid,2181,1,10000)		
			end
			talk_state = 0

-- NO ------------------------------------------------------------------------------------

elseif msgcontains(msg, 'no') then
			if talk_state >= 2 then
				selfSay('Ok, maybe next time.')
			else			
		end

-- END -----------------------------------------------------------------------------------

		elseif string.find(msg, '(%a*)bye(%a*)') and getDistanceToCreature(cid) < 8 then
			selfSay('Good bye.')
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
 		if getDistanceToCreature(focus) > 7 then
 			selfSay('Good bye then.')
 			focus = 0
 		end
 	end
end
