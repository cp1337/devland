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
	distance = getDistanceTo(cid)

  	if msgcontains(msg, 'hi') and distance <= 4 then
  		selfSay('Welcome ' .. getCreatureName(cid) .. '! Whats {bring} you to Me?')
  		talk_start = os.clock()

  	elseif msgcontains(msg, 'hi') and focus ~= cid and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('Dont kidding, im just statue, maybe magic statue but statue...')

----- Spells for Sell -----

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
                                buy(cid,2287,count,10)
			elseif talk_state == 21 then
				buy(cid,2311,count,20)	
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
