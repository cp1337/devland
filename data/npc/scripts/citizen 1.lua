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

local focuses = {}
local function isFocused(cid)
	for i, v in pairs(focuses) do
		if(v == cid) then
			return true
		end
	end
	return false
end

local function addFocus(cid)
	if(not isFocused(cid)) then
		table.insert(focuses, cid)
	end
end

local function removeFocus(cid)
	for i, v in pairs(focuses) do
		if(v == cid) then
			table.remove(focuses, i)
			break
		end
	end
end

local function lookAtFocus()
	for i, v in pairs(focuses) do
		if(isPlayer(v) == TRUE) then
			doNpcSetCreatureFocus(v)
			return
		end
	end
	doNpcSetCreatureFocus(0)
end


function msgcontains(txt, str)
  	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onCreatureSay(cid, type, msg)
  	msg = string.lower(msg)
	distance = getDistanceTo(cid)

	if (msg == "hi") and not (isFocused(cid)) and (distance < 4) then
  		selfSay('Hiho ' .. getCreatureName(cid) .. '?')
  		addFocus(cid)
  		talk_start = os.clock()

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif isFocused(cid) then
		talk_start = os.clock()

	if msgcontains(msg, 'job') then
			selfSay('I am the older citizen at this city.')

	elseif msgcontains(msg, 'help') then
			selfSay('You want my Help? Tell me what You need.')

        elseif msgcontains(msg, 'quest') then
			selfSay('There are many quests in Devland World. Ask citizens about it, maybe someone of them have one for You.') 
        
	elseif msgcontains(msg, 'ferumbras') then
			selfSay('I read abut him in one of book. There was writed he was evil Mag, who lose war for Earth.We have luck he not alive anymore.') 	
	
        elseif msgcontains(msg, 'devon six') then
			selfSay('He is our King! Dont You remember?.')

	elseif msgcontains(msg, 'heal') then
			selfSay('Sorry, i cant heal you.')

	elseif msgcontains(msg, 'addon') then
                 if getPlayerStorageValue(cid,8000) >= 2 then
					selfSay('You already have this addon.')

                 else if getPlayerStorageValue(cid,8000) == 1 then
                    selfSay('So, you bring 100 minotaur leather to me?')
					addon_state = 2
		 else
		            setPlayerStorageValue(cid,8000,1)
                    selfSay('Bring me 100 minotaur leather, then i make one for You.')
        end
	end
	elseif msgcontains(msg, 'yes') and addon_state == 2 then
                 if doPlayerRemoveItem(cid,5878,100) == 0 then
		  			selfSay('Sorry, you not have them.')
                 else  
			selfSay('Thanks, addon is your now.')
			if getPlayerSex(cid) == 0 then
		    doPlayerAddAddon(cid, 136, 1)
		    setPlayerStorageValue(cid,8000,2)
			else
			doPlayerAddAddon(cid, 128, 1)
		    talk_state = 1
			end
        end	 	

	elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
	             selfSay('Good bye, ' .. getCreatureName(cid) .. '! Come back soon..')
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
