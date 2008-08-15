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

		if (msg == "salutations general") and not (isFocused(cid)) and (distance < 4) then
			selfSay("Salutations, commoner " .. getCreatureName(cid) .. "!", cid, TRUE)
  			talk_start = os.clock()
			talk_state = 1
			addFocus(cid)

		elseif msgcontains(msg, 'hi') or msgcontains(msg, 'hello') then
        		selfSay("Address me properly, " .. getCreatureName(cid) .. "!", cid, TRUE)

		elseif isFocused(cid) then
			talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay("I am the general of the queen's army and I have not the time to explainthis concept to you.", cid)	
	
		elseif msgcontains(msg, 'devland')then
        		selfSay("That\'s where we are. The world of DevLand.", cid)


		elseif msgcontains(msg, 'army') then
        		selfSay("The army protects the defenceless males of our city. Our elite forces arethe S-W-O-T.", cid)


		elseif msgcontains(msg, 'swot') or msgcontains(msg, 's-w-o-t') then
        		selfSay("Our elite forces are trained by rangers and sorcerers.", cid)


		elseif msgcontains(msg, 'sorcerers') then
        		selfSay("They are our main magic support and play a major role in our battle tactics.", cid)

		elseif msgcontains(msg, 'heal') then
                  doPlayerAddHealth(cid, 45)
                  doSendMagicEffect(cid,12)

		elseif msgcontains(msg, 'gold') then
        		selfSay("If you want change gold go to City Bank.", cid)


		elseif msgcontains(msg, 'fuck') or msgcontains(msg, 'suck') or msgcontains(msg, 'bitch') then
        		selfSay("Hey " .. getCreatureName(cid) .. "! We have rules here! Behave or get banned.", cid)
		
		end
	end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('LONG LIVE THE QUEEN!')
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
				selfSay("LONG LIVE THE QUEEN!", cid)
				removeFocus(focus)
			end
			if talk_state ~= 99 and (os.clock() - talk_start) > 30 then
  				selfSay("LONG LIVE THE QUEEN!", cid)
  				removeFocus(focus)
  			end
		end
	end
	lookAtFocus()
end