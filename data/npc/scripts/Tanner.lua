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
  		selfSay("I\'m the Tanner. How can I help you " .. getCreatureName(cid) .. "?", cid, TRUE)
  		addFocus(cid)
  		talk_start = os.clock()

	elseif isFocused(cid) then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay("I\'m the local tanner. I buy fresh animal corpses, tan them, and convert them into fine leather clothes.", cid)		

		elseif msgcontains(msg, 'tanner') then
        		selfSay("That\'s my job. I buy fresh animal corpses, tan them, and convert them into fine leather clothes.", cid)


		elseif msgcontains(msg, 'corpse') then
        		selfSay("I\'m buying fresh corpses of rats, rabbits and wolves. What do you want to sell?", cid)


		elseif msgcontains(msg, 'customers') then
        		selfSay("Yes. Edi, Caroline and good old Bob. Go ask them for leather clothes.", cid)


		elseif msgcontains(msg, 'troll') then
        		selfSay("Troll leather stinks. Can\'t use it.", cid)


		elseif msgcontains(msg, 'orc') then
        		selfSay("I don\'t buy Orcs. Their skin is too scratchy.", cid)


		elseif msgcontains(msg, 'human') then
        		selfSay("Are you Crazy?", cid)


		elseif msgcontains(msg, 'rat') then
			count = getCount(msg)
			cost = 2*count	
			selfSay("I\'ll give you " .. cost .. " gold for " .. getCount(msg) .. "dead rats. Do You accept?", cid)
			buyit = 1

		elseif msgcontains(msg, 'rabbit') then
			count = getCount(msg)
			cost = 2*count	
			selfSay("I\'ll give you " .. cost .. " gold for " .. getCount(msg) .. "dead rabbits. Do You accept?", cid)
			buyit = 2

		elseif msgcontains(msg, 'deer') then
			count = getCount(msg)
			cost = 6*count	
			selfSay("I\'ll give you " .. cost .. " gold for " .. getCount(msg) .. "dead deers. Do You accept?", cid)
			buyit = 3

		elseif msgcontains(msg, 'wolf') then
			count = getCount(msg)
			cost = 5*count	
			selfSay("I\'ll give you " .. cost .. " gold for " .. getCount(msg) .. "dead wolves. Do You accept?", cid)
			buyit = 4	
		
		elseif msgcontains(msg, 'yes') then
			if buyit == 1 then
				sell(cid,3073,count,2)
			elseif buyit == 2 then
				sell(cid,2992,count,2)
			elseif buyit == 3 then
				sell(cid,2835,count,6)	
			elseif buyit == 4 then
				sell(cid,2826,count,5)			
		end

		elseif msgcontains(msg, 'no') then
			selfSay("Maybe another time.", cid)
			buyit = 0
		end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay("Good hunting, son.", cid)
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