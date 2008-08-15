local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false
local talkstate = false

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
		selfSay('Welcome, how can i help You?')
  		focus = cid
  		talk_start = os.clock()

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')


	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I am a librarian.')	

		elseif msgcontains(msg, 'help') then
        		selfSay('I\'m busy now. TRy look at book\'s, there is writed evrything.')	

		elseif msgcontains(msg, 'book') or msgcontains(msg, 'books') then
        		selfSay('I love read book\'s. You should try it too.')

		elseif msgcontains(msg, 'devland') then
        		selfSay('It\'s our world. More info You can find at \'www.devland.info\', or at book\'s.')	

		elseif msgcontains(msg, 'quest') then
        		selfSay('Before make any quest You should buy better Equipment.')

		elseif msgcontains(msg, 'school') or msgcontains(msg, 'spiders') then
        		selfSay('It\'s on higher floor.')
		end

		if string.find(msg, '(%a*)bye(%a*)') and getDistanceToCreature(cid) < 4 then
			selfSay('Good bye, ' .. getCreatureName(cid) .. '. Remember about homework.')
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
  			selfSay('Are You listen Me?')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Hey, come back Im not end Lesson.')
 			focus = 0
 		end
 	end
end