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
			selfSay("Hello, " .. getCreatureName(cid) .. "! I will heal you if you are injured. Feel free to ask me for help.", cid, TRUE)
  			talk_start = os.clock()
			talk_state = 1
			addFocus(cid)

		elseif isFocused(cid) then
			talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay("I am just a humble {monk}. Ask me if you need {help} or {heal}ing.", cid)	
	
		elseif msgcontains(msg, 'devland')then
        		selfSay("That\'s where we are. The world of DevLand.", cid)


		elseif msgcontains(msg, 'edi') then
        		selfSay("He is a local shop owner.", cid)


		elseif msgcontains(msg, 'fight') then
        		selfSay("Take a weapon in your hand, activate your combat mode, and select a target. After a fight you should eat something to healyour wounds.", cid)


		elseif msgcontains(msg, 'monsters') then
        		selfSay("Monsters are a constant threat. Learn to fight by hunting rabbits, deers and sheeps. Then try to fight rats, bugs andperhaps spiders.", cid)

		elseif msgcontains(msg, 'gold') then
        		selfSay("You have to slay monsters and take their gold. Also You can sell food, or corpses at Tanner shop.", cid)


		elseif msgcontains(msg, 'fuck') or msgcontains(msg, 'suck') or msgcontains(msg, 'bitch') then
        		selfSay("Hey " .. getCreatureName(cid) .. "! We have rules here! Behave or get banned.", cid)


		elseif msgcontains(msg, 'monk') then
        		selfSay("I sacrifice my life to serve the good gods of DevLand.", cid)


		elseif msgcontains(msg, 'god') then
        		selfSay("They created DevLand and all life on it. Visit our library and learn about them.", cid)


		elseif msgcontains(msg, 'life') then
        		selfSay("The gods decorated DevLand with various forms of life. Plants, the {citizens}, and even the {monsters}.", cid)


		elseif msgcontains(msg, 'citizens') then
        		selfSay("Only few people live here. Walk around and talk to them.", cid)


		elseif msgcontains(msg, 'plants') then
        		selfSay("Just walk around. You will see grass, trees, and bushes.", cid)

		elseif msgcontains(msg, 'heal') then
		   if getPlayerHealth(cid) <= 70 then
			doPlayerAddHealth(cid,30)
			selfSay("Ok, done.", cid)
		   else
			selfSay("You not looking so bad, so i not heal you.", cid)
		   end

		end
	end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Farewell, ' .. getCreatureName(cid) .. '!')
			removeFocus(cid)
			talk_start = 0
			talk_state = 99
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