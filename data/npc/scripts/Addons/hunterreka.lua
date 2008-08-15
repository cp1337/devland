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

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Hello ' .. getCreatureName(cid) .. '! What brings You to me?')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
					selfSay('I am local hunter!')
		elseif msgcontains(msg, 'hunter') then
					selfSay('Yes, that is my Job. How you can see i have proper outfit.')
		elseif msgcontains(msg, 'outfit') then
					selfSay('Hunter with all addons. It is my outfit.')
		elseif msgcontains(msg, 'addon') then
				if getPlayerStorageValue(cid,3001) == 1 then
					if doPlayerRemoveItem(cid,2171,1) == 0 then
						selfSay('Come back when you get platinum amulet for me.')
					else
						setPlayerStorageValue(cid,3001,2)
						doPlayerAddAddon(cid, 137, 2)
						doPlayerAddAddon(cid, 129, 2)					
					end
				elseif getPlayerStorageValue(cid,3001) == 2 then
					selfSay('I already gave you my gloves.')
				else
					selfSay('Hmmm I have one pair of gloves. I can give it to You, if you bring me platinum amulet. I lost my in last hunt.')
					setPlayerStorageValue(cid,3001,1)
				end

  		elseif string.find(msg, '(%a*)bye(%a*)')  and getDistanceToCreature(cid) < 4 then
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
