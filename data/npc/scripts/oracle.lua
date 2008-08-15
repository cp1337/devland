local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false
local sail = 0

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
	pos = {x=508, y=454, z=7}

	distance = getDistanceTo(cid)

		if (msg == "hi") and not (isFocused(cid)) and (distance < 4) then
			if getPlayerLevel(cid) >= 8 then
				selfSay("Hello, Adventurer! Are you ready to face your destiny?", cid, TRUE)
  				talk_start = os.clock()
				talk_state = 1
				addFocus(cid)
			else
				selfSay("Come back when you will be ready.", cid, TRUE)
			end
			
	elseif isFocused(cid) then
		talk_start = os.clock()

	if msgcontains(msg, 'yes') and talk_state ~= 458 then
					selfSay("What would you like to be? A sorcerer, a druid, a paladin or a knight?", cid)
	 				talk_state = 459

   	elseif msgcontains(msg, 'no') then
			selfSay("Come back when you are ready then.", cid)
			talk_state = 0

   	elseif talk_state == 459 then
		vocationid = 0
		talk_state = 458

	if msgcontains(msg, 'sorcerer') then
		selfSay("A sorcerer! Are you sure?", cid)
		vocationid = 1

	elseif msgcontains(msg, 'knight') then
		selfSay("A knight! Are you sure?", cid)
		vocationid = 4

	elseif msgcontains(msg, 'paladin') then
		selfSay("A paladin! Are you sure?", cid)
		vocationid = 3

	elseif msgcontains(msg, 'druid') then
		selfSay("A druid! Are you sure?", cid)
		vocationid = 2

	else
		selfSay("Please type your vocation again.", cid)
		talk_state = 459
	end

	elseif talk_state == 458 then
     		if msgcontains(msg, 'yes') then
			selfSay("Great! You are sure this decission?", cid)
			talk_state = 452

    		end


	if msgcontains(msg, 'yes') then
		doPlayerSetVocation(cid,vocationid)
		doPlayerSetTown(cid,2)
		travel(cid, 508, 454, 7)
	end
   	talk_state = 0
   	talk_start = 0



		elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
			selfSay("Good bye. Come back when You will be ready.", cid)
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
