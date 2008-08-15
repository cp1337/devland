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
	{id=2643, charges=0, buy=15},
	{id=2461, charges=0, buy=15},
	{id=2484, charges=0, buy=35, sell=15},
	{id=2526, charges=0, buy=40, sell=15},
	{id=2482, charges=0, buy=25, sell=20},
	{id=2512, charges=0, buy=25, sell=8},
	{id=2458, charges=0, buy=20},
	{id=2460, charges=0, buy=60},
	{id=2384, charges=0, buy=25, sell=10},
	{id=2380, charges=0, buy=25},
	{id=2448, charges=0, buy=15},
	{id=2420, charges=0, buy=35},
	{id=2406, charges=0, buy=30},
	{id=2120, charges=0, buy=40, sell=10},
	{id=2554, charges=0, buy=20},
	{id=2550, charges=0, buy=50},
	{id=2580, charges=0, buy=150, sell=40},
	{id=2398, charges=0, sell=25},
	{id=2473, charges=0, sell=25},
	{id=2473, charges=0, sell=30},
	{id=2464, charges=0, sell=40},
	{id=2511, charges=0, sell=25},
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
		selfSay("Do you want to see my {wares}?", cid)
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
			selfSay("I am a local merchant. I\'m selling and buing equipment or wepons.", cid)		

		elseif msgcontains(msg, 'help') then
        		selfSay("Ofcourse i help You, just tell me what you want to buy.", cid)


		elseif msgcontains(msg, 'quest') then
			selfSay("There are many quests in wolrd of DevLand. Ask citizens, maybe someone have one for You.", cid)
			buyit = 0

		elseif msgcontains(msg, 'weapon') or msgcontains(msg, 'weapons') or msgcontains(msg, 'equipment') or msgcontains(msg, 'offer') then
        		selfSay("You can se my offer on tables", cid)


		elseif msgcontains(msg, 'waldensi') then
			selfSay("Yes, thats me.", cid)
			buyit = 0

		elseif msgcontains(msg, 'name') then
			selfSay("Everyone call to me Waldensi.", cid)
			buyit = 0
		end
end
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