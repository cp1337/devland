local focus = 0
local talk_start = 0
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
	{id=2266, charges=1, buy=40, sell=25},
	{id=2677, charges=3, sell=1},
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
			doPlayerSendTextMessage(cid, 21, "You Bought: " .. amount .. " " .. getItemName(item) .. ".")	
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
		doPlayerSendTextMessage(cid, 21, "You sold: " .. amount .. " " .. getItemName(item) .. ".")	
	else
		selfSay("No item, no deal.", cid)
	end
end

function onCreatureAppear(cid)
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


function msgcontains(txt, str)
  	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onCreatureSay(cid, type, msg)
  	msg = string.lower(msg)
	distance = getDistanceTo(cid)

	if (msg == "hi") and not (isFocused(cid)) and (distance < 4) then
		selfSay("Welcome, ".. getCreatureName(cid) ..".", cid, TRUE)
  		talk_start = os.clock()
		talk_state = 1
		addFocus(cid)

		elseif isFocused(cid) then
		talk_start = os.clock()

		if(msg == "wares" or msg == "trade") then
			selfSay("Pretty nice, right?", cid)
			sendShopWindow(cid, itemWindow, onBuy, onSell)

		elseif(msg == "bye" or msg == "goodbye" or msg == "cya") then
			selfSay("Goodbye!", cid, TRUE)
			closeShopWindow(cid)
			removeFocus(cid)

		elseif msgcontains(msg, 'job') then
			selfSay("I am a druid, bound to the spirit of nature. I\'m selling antidote runes that help against poison. Oh, and I buy blueberries, of course.", cid)		

		elseif msgcontains(msg, 'help') then
        		selfSay("I can sell you an antidote rune. It\'s against the poison of so many dangerous creatures.", cid)


		elseif msgcontains(msg, 'poison') then
        		selfSay("Many monsters are poisonous. Don\'t let them bite you or you will need one of my antidote runes.", cid)


		elseif msgcontains(msg, 'offer') then
        		selfSay("I only sell my antidote runes and I\'ll be happy to buy some blueberries from you.", cid)
			
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
				selfSay("Hmph!")
				closeShopWindow(focus)
				removeFocus(focus)
			end
		end
	end
	lookAtFocus()
end

