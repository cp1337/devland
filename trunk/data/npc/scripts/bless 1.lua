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
  		selfSay('Hello ' .. getCreatureName(cid) .. '?')
  		focus = cid
  		talk_start = os.clock()

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

	if msgcontains(msg, 'job') then
			selfSay('Im just humble monk.')

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

	elseif msgcontains(msg, 'bless') then
                 if getPlayerBlessing(cid, 1) then
		    selfSay('You already have this bless.')
		 else
                    selfSay('So, you want buy bless of Water God for 10 000 gold pieces?')
        	    bless_state = 1
	end

	elseif msgcontains(msg, 'yes') then
                 if pay(cid,10000) then
		    selfSay('God of Water blessed You.')
		    doPlayerAddBlessing(cid, 1)
                 else  
		    selfSay('Sorry, you not have enaugh gold')
		    bless_state = 0
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

