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
		selfSay("Hello! How i can help You?", cid, TRUE)
  		talk_start = os.clock()
		talk_state = 1
		addFocus(cid)

	elseif isFocused(cid) then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay("I am a teacher of this {island}.", cid)	

		elseif msgcontains(msg, 'teacher') then
        		selfSay("Yep, its my work. It\'s hard, but i like my work.", cid)	

		elseif msgcontains(msg, 'name') then
        		selfSay("My name is Eleneora. And Your name is ...?", cid)

		elseif msgcontains(msg, 'help') then
        		selfSay("If you want help from me, then join to my class.", cid)

		elseif msgcontains(msg, 'lesson') then
        		selfSay("Yea, Lesson. You disturbing me with it.", cid)	

		elseif msgcontains(msg, 'quest') then
        		selfSay("I need new {Skull} to our Skeleton, if you find then bring it to me. Ofcourse, I will reward You for it.", cid)

		elseif msgcontains(msg, 'topic') then
        		selfSay("Today our topic are \'{spiders}\'. If you want to know something more about them read information\'s from blackboard.", cid)

		elseif msgcontains(msg, 'spider') or msgcontains(msg, 'spiders') then
        		selfSay("It\'s our {Topic} today.", cid)

		elseif msgcontains(msg, 'island') then
        		selfSay("This is Newbie {Island}, all player\'s under 8 lv live\'s here.", cid)

		elseif msgcontains(msg, 'diplom') then
        		selfSay("Ofcourse I have it, but Im not see any reason to show You it.", cid)

		elseif msgcontains(msg, 'skull') then
        		selfSay("You bring to Me one?", cid)
			talkstate = 10

		elseif msgcontains(msg, 'no') and talkstate == 10 then
			selfSay("Ok, then go look for it.", cid)
			talkstate = 0
		
		elseif msgcontains(msg, 'yes') and talkstate == 10 then
			if doPlayerRemoveItem(cid,2229) == 0 then
			doPlayerAddItem(cid, 2480, 1)
			selfSay("Ok, it\'s Your reward.", cid)
                 else  
                    selfSay("Hey, You not have it!", cid)		
		end


		elseif string.find(msg, '(%a*)bye(%a*)') then
			selfSay("Good bye, " .. getCreatureName(cid) .. ". Remember about homework.")
			removeFocus(cid)
			talk_start = 0
			talk_state = 99
	end
end
end


function onCreatureChangeOutfit(creature)

end

function onThink()

	for i, focus in pairs(focuses) do
	
		if(isCreature(focus) == FALSE) then
			removeFocus(focus)
		else
			local distance = getDistanceTo(focus) or -1
			if((distance > 4) or (distance == -1)) then
				selfSay("Goodbye, come back when you will ready!", cid)
				removeFocus(focus)
			end
			if talk_state ~= 99 and (os.clock() - talk_start) > 30 then
  				selfSay("Good bye! Come back soon..", cid)
  				removeFocus(focus)
  			end
		end
	end
	lookAtFocus()
end