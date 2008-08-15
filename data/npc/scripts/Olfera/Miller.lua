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
	distance = getDistanceTo(cid)

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Welcome citizen, ' .. getCreatureName(cid) .. '! ')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am a Farmer and Miller.')	
	
		elseif msgcontains(msg, 'Miller')then
        		selfSay('Someone must ding this work.I inherit this work from my father.')

		elseif msgcontains(msg, 'Farmer')then
        		selfSay('I doing it beceause i need wheat to Mill.')


		elseif msgcontains(msg, 'orelfera') then
        		selfSay('I born here, and i will die here. This city is great.')

		elseif msgcontains(msg, 'life') then
        		selfSay('My life is very simple, but i love it.')

		elseif msgcontains(msg, 'quest') then
        		selfSay('I have problems with rat\'s in my basement. Kill them all for me then i give you Reward.')

		elseif msgcontains(msg, 'Reward') and getPlayerStorageValue(cid,7530) == -1 then
		        if doPlayerRemoveItem(cid,2813, 4) then			
				setPlayerStorageValue(cid,7530,1)
                        else
			 	selfSay('Sorry, but You not kill them all.')
			end

		elseif msgcontains(msg, 'Reward') and getPlayerStorageValue(cid,7530) >= 1 then
				selfSay('I already reward you.')

		end
	end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Farewell, ' .. getCreatureName(cid) .. '!')
			focus = 0
			talk_start = 0
		end
	end


function onCreatureChangeOutfit(creature)

end

function onThink()


  	if (os.clock() - talk_start) > 30 then
  		if focus > 0 then
  			selfSay('Well, bye then.')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Well, bye then.')
 			focus = 0
 		end
 	end
end