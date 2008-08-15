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
	{id=2510, charges=0, buy=120, sell=70},
	{id=2480, charges=0, buy=70, sell=30},
	{id=2419, charges=0, buy=200, sell=110},
	{id=2511, charges=0, buy=60, sell=30},
	{id=2412, charges=0, buy=200, sell=30},
	{id=6131, charges=0, buy=150, sell=50},
	{id=2530, charges=0, buy=70, sell=5},
	{id=2458, charges=0, buy=40, sell=12},
	{id=7430, charges=0, sell=5000},
	{id=2187, charges=0,  sell=10000},
{id=2395, charges=0, buy=400, sell=118},
{id=2383, charges=0, buy=8000, sell=240},
{id=2409, charges=0, buy=6000, sell=900},
{id=2377, charges=0, buy=950, sell=450},
{id=2392, charges=0, sell=4000},
{id=2393, charges=0, sell=17000},
{id=2378, charges=0, buy=235, sell=80},
{id=2430, charges=0, sell=2000},
{id=2429, charges=0, buy=590, sell=185},
{id=2425, charges=0, buy=3000, sell=500},
{id=2387, charges=0, sell=260},
{id=2381, charges=0, sell=310},
{id=2432, charges=0, sell=8000},
{id=2414, charges=0, sell=9000},
{id=2417, charges=0, buy=350, sell=120},
{id=2394, charges=0, buy=430, sell=100},
{id=2423, charges=0, buy=540, sell=170},
{id=2423, charges=0, sell=2000},
{id=2436, charges=0, sell=6000},
{id=1988, charges=0, buy=20},
{id=2391, charges=0, buy=10000, sell=1200},
{id=2190, charges=0, sell=100},
{id=2191, charges=0, sell=200},
{id=2188, charges=0, sell=1000},
{id=2189, charges=0, sell=2000},
{id=2182, charges=0, sell=100},
{id=2186, charges=0, sell=200},
{id=2185, charges=0, sell=1000},
{id=2181, charges=0, sell=2000},
{id=2183, charges=0, sell=3000},
{id=2465, charges=0, buy=450, sell=150},
{id=2463, charges=0, buy=1200, sell=400},
{id=2656, charges=0, sell=10000},
{id=2486, charges=0, buy=8000, sell=900},
{id=2476, charges=0, sell=5000},
{id=2487, charges=0, sell=12000},
{id=2466, charges=0, sell=20000},
{id=2492, charges=0, sell=40000},
{id=2648, charges=0, buy=80, sell=25},
{id=2478, charges=0, buy=195, sell=49},
{id=2647, charges=0, sell=115},
{id=2488, charges=0, sell=12000},
{id=2477, charges=0, sell=5000},
{id=2490, charges=0, buy=1000, sell=250},
{id=2479, charges=0, sell=500},
{id=2457, charges=0, buy=580, sell=300},
{id=2462, charges=0, sell=450},
{id=2491, charges=0, sell=2500},
{id=3972, charges=0, sell=2200},
{id=2475, charges=0, sell=5000},
{id=2497, charges=0, sell=6000},
{id=2498, charges=0, sell=30000},
{id=2645, charges=0, sell=30000},
{id=2195, charges=0, sell=30000},
{id=2513, charges=0, sell=95},
{id=2521, charges=0, sell=400},
{id=2525, charges=0, buy=500, sell=100},
{id=6131, charges=0, sell=150},
{id=2518, charges=0, buy=7000, sell=1200},
{id=2515, charges=0, sell=2000},
{id=2516, charges=0, sell=4000},
{id=2519, charges=0, sell=8000},
{id=2528, charges=0, sell=8000},
{id=2536, charges=0, sell=9000},
{id=2534, charges=0, sell=15000},
{id=2520, charges=0, sell=30000},
{id=2389, charges=1, buy=3, sell=10},
{id=7378, charges=1, sell=15},
{id=2413, charges=0, sell=500},
{id=2434, charges=0, sell=3000},
{id=2663, charges=0, sell=600},
{id=2418, charges=0, sell=3000},
{id=2661, charges=0, sell=500},
{id=7382, charges=0, sell=20000},
{id=7402, charges=0, sell=19000},
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
