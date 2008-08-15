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
  	local msg = string.lower(msg)
	distance = getDistanceTo(cid)

	if (msg == "hi") and not (isFocused(cid)) and (distance < 4) then
  		selfSay("Welcome " .. getCreatureName(cid) .. "! Whats your need?", cid, TRUE)
  		talk_start = os.clock()
		addFocus(cid)

	elseif isFocused(cid) then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay("I am a {merchant}", cid)

		elseif msgcontains(msg, 'offer') then
			selfSay("Sorry, but I just move in, and {shop} is momentally closed.", cid)

		elseif msgcontains(msg, 'help') then
			selfSay("No thanks, I make all by myself.", cid)

		elseif msgcontains(msg, 'name') then
			selfSay("My name is {Monic}. Don\'t you think so my name is beatifull.", cid)

-- END -----------------------------------------------------------------------------------

		elseif string.find(msg, '(%a*)bye(%a*)') then
			selfSay("Goodbye then.", cid)
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
				selfSay("Goodbye!", cid)
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