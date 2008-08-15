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


function onCreatureDisappear(cid)
	if(isFocused(cid)) then
		selfSay("Hmph!")
		focus = 0
		if(isPlayer(cid) == TRUE) then --Be sure he's online
			closeShopWindow(cid)
		end
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

local itemWindow = {
	{id=2671, charges=0, buy=6, sell=4},
	{id=2666, charges=0, buy=7, sell=3},
	{id=2689, charges=0, buy=3, sell=2},
}

local items = {}
for _, item in ipairs(itemWindow) do
	items[item.id] = {buyPrice = item.buy, sellPrice = item.sell, charges = item.charges}
end

local function getPlayerMoney(cid)
	return ((getPlayerItemCount(cid, 2160) * 10000) + 
	(getPlayerItemCount(cid, 2152) * 100) + 
	getPlayerItemCount(cid, 2148))
end

local onBuy = function(cid, item, charges, amount)
	if(items[item] == nil) then
		selfSay("Ehm.. sorry... this shouldn't be there, I'm not selling it.", cid)
		return
	end

	if(getPlayerMoney(cid) >= amount*items[item].buyPrice) then
		local itemz, i = doPlayerAddItem(cid, item, charges, amount)
		if(i < amount) then
			if(i == 0) then
				selfSay("Sorry, but you don't have space to take it.", cid)
			else
				selfSay("I've sold some for you, but it seems you can't carry more than this. I won't take more money than necessary.", cid)
				doPlayerRemoveMoney(cid, i*items[item].buyPrice)
			end
		else
			selfSay("Thanks for the money!", cid)
			doPlayerRemoveMoney(cid, amount*items[item].buyPrice)
		end
	else
		selfSay("Stfu noob, you don't have money.", cid)
	end
end

local onSell = function(cid, item, charges, amount)
	if(items[item] == nil) then
		selfSay("Ehm.. sorry... this shouldn't be there, I'm not buying it.", cid)
	end

	if(charges < 1) then
		charges = -1
	end
	if(doPlayerRemoveItem(cid, item, amount, charges) == TRUE) then
		doPlayerAddMoney(cid, items[item].sellPrice*amount)
		selfSay("Here you are.", cid)
	else
		selfSay("No item, no deal.", cid)
	end
end


function msgcontains(txt, str)
  	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onCreatureSay(cid, type, msg)
  	msg = string.lower(msg)
	distance = getDistanceTo(cid)


	if (msg == "hi") and not (isFocused(cid)) and (distance < 4) then
  		selfSay("Hiho " .. getCreatureName(cid) .. "?", cid, TRUE)
  		talk_start = os.clock()
		addFocus(cid)

	elseif isFocused(cid) then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay("I am a {farmer} and a cook.", cid)

		elseif msgcontains(msg, 'farmer') then
        		selfSay("Farmer work is really very hard.", cid)


		elseif msgcontains(msg, 'cook') then
        		selfSay("I try out old and new {recipes}. You can sell me all food you have.", cid)


		elseif msgcontains(msg, 'food') then
			sendShopWindow(cid, itemWindow, onBuy, onSell)
        		selfSay("Are you looking for {food}? I have bread, cheese, ham, and meat.", cid)


		elseif msgcontains(msg, 'monster') then
        		selfSay("Are you afraid them ... Ha Ha Ha!", cid)


		elseif msgcontains(msg, 'god') then
        		selfSay("I am a {farmer}, not a preacher.", cid)


		elseif msgcontains(msg, 'offer') then
			sendShopWindow(cid, itemWindow, onBuy, onSell)
        		selfSay("I can offer you {bread}, {cheese}, {ham}, or {meat}.", cid)


		elseif msgcontains(msg, 'help') then
        		selfSay("Help yourself, You will not stolen my {time}.", cid)


		elseif msgcontains(msg, 'time') then
        		selfSay("Am I a clock or what?", cid)


		elseif msgcontains(msg, 'magic') then
        		selfSay("I am magician in the kitchen.", cid)

		elseif msgcontains(msg, 'no') and buyit >= 1 then
			selfSay('Maybe another time.')
			buyit = 0
		end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Yeah, bye.')
			closeShopWindow(cid)
			removeFocus(cid)
			talk_start = 0
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
				closeShopWindow(focus)
  			end
		end
	end
	lookAtFocus()
end