do
	doPlayerAddStackable = doPlayerAddItem
	--Returns table with UIDs of added items
	doPlayerAddItem = function(cid, itemid, subType, amount)
		local amount = amount or 1
		local subAmount = 0
		local subType = subType or 0

		if(isItemStackable(itemid) == TRUE) then
			return doPlayerAddStackable(cid, itemid, amount), amount
		end

		local items = {}
		local ret = 0
		local a = 0
		for i = 1, amount do
			items[i] = doCreateItemEx(itemid, subType)
			ret = doPlayerAddItemEx(cid, items[i])
			if(ret ~= RETURNVALUE_NOERROR) then
				break
			end
			a = a + 1
		end

		return items, a
	end
end

function getPlayerMoney(cid)
	return ((getPlayerItemCount(cid, 2160) * 10000) + 
	(getPlayerItemCount(cid, 2152) * 100) + 
	getPlayerItemCount(cid, 2148))
end

-- get the distance to a creature
function getDistanceToCreature(id)
	if id == 0 or id == nil then
		selfGotoIdle()
	end
	cx, cy, cz = creatureGetPosition(id)
	if cx == nil then
		return nil
	end
	sx, sy, sz = selfGetPosition()
	return math.max(math.abs(sx-cx), math.abs(sy-cy))	
end

function TurnToPlayer(focus)
	x, y, z = creatureGetPosition(focus)
	myx, myy, myz = selfGetPosition()

		if ((myy-y==0) and (myx-x<=0 and myx-x>=-4)) then
			selfTurn(1)
		end 
		if ((myy-y==0) and (myx-x>=0 and myx-x<=4)) then
			selfTurn(3)
		end
		if ((myx-x==0) and (myy-y<=0 and myy-y>=-4)) then
			selfTurn(2)
		end
		if ((myx-x==0) and (myy-y>=0 and myy-y<=4)) then
			selfTurn(0)
		end
		if ((myy-y==-2) and (myx-x>=-1 and myx-x<=1)) then
			selfTurn(2)
		end
		if ((myy-y==2) and (myx-x>=-1 and myx-x<=1)) then
			selfTurn(0)
		end
		if ((myx-x==2) and (myy-y>=-1 and myy-y<=1)) then
			selfTurn(3)
		end
		if ((myx-x==-2) and (myy-y>=-1 and myy-y<=1)) then
			selfTurn(1)
		end
		if ((myy-y==-3) and (myx-x>=-2 and myx-x<=2)) then
			selfTurn(2)
		end
		if ((myy-y==3) and (myx-x>=-2 and myx-x<=2)) then
			selfTurn(0)
		end
		if ((myx-x==3) and (myy-y>=-2 and myy-y<=2)) then
			selfTurn(3)
		end
		if ((myx-x==-3) and (myy-y>=-2 and myy-y<=2)) then
			selfTurn(1)
		end
		if ((myy-y==-4) and (myx-x>=-3 and myx-x<=3)) then
			selfTurn(2)
		end
		if ((myy-y==4) and (myx-x>=-3 and myx-x<=3)) then
			selfTurn(0)
		end
		if ((myx-x==4) and (myy-y>=-3 and myy-y<=3)) then
			selfTurn(3)
		end
		if ((myx-x==-4) and (myy-y>=-3 and myy-y<=3)) then
			selfTurn(1)
		end
	end


-- do one step to reach position
function moveToPosition(x,y,z)
	selfMoveTo(x, y, z)
end

-- do one step to reach creature
function moveToCreature(id)
	if id == 0 or id == nil then
		selfGotoIdle()
	end
	tx,ty,tz=creatureGetPosition(id)
	if tx == nil then
		selfGotoIdle()
	else
	   moveToPosition(tx, ty, tz)
   end
end

function selfGotoIdle()
		following = false
		attacking = false
		selfAttackCreature(0)
		target = 0
end

-- pay for anything?
function pay(cid, cost)
	if doPlayerRemoveMoney(cid, cost) == 1 then
		return true
	else
		return false
	end
end

-- Travel player
function travel(cid, x, y, z)
	destpos = {x = x, y = y, z = z}
	doTeleportThing(cid, destpos)
	doSendMagicEffect(destpos, 10)
end

-- getCount function by Jiddo
function getCount(msg)
	b, e = string.find(msg, "%d+")
	
	if b == nil or e == nil then
		count = 1
	else
		count = tonumber(string.sub(msg, b, e))
	end
	
	return count
end

-- buy an item
function buy(cid, itemid, count, cost)
	cost = count*cost
	amount = count
	if doPlayerRemoveMoney(cid, cost) == 1 then
		if isItemStackable(itemid) then
			while count > 100 do
				doPlayerAddItem(cid, itemid, 100)
				count = count - 100
			end
			
			doPlayerAddItem(cid, itemid, amount, amount) -- add the last items, if there is left
		else
			while count > 0 do
				doPlayerAddItem(cid, itemid, 1)
				count = count - 1
			end
		end
	 if itemid ~= 2595 then 	
		if count <= 1 then
			selfSay('Here is your '.. getItemName(itemid) .. '!')
		else
			selfSay('Here are your '.. amount ..' '.. getItemName(itemid) .. 's!')		
		end
	 else
		selfSay('Here you are. Don\'t forget to write the name and the address of the receiver on the label. The label has to be in the parcelbefore you put the parcel in a mailbox.')
		end
     else
          selfSay('Sorry, you do not have enough money.')
   end
end

function buyFluidContainer(cid, itemid, count, cost, fluidtype)
	cost = count*cost
	amount = count
	if doPlayerRemoveMoney(cid, cost) == 1 then
		while count > 0 do
			doPlayerAddItem(cid, itemid, fluidtype)
			count = count - 1
		end
		
		if amount <= 1 then
			selfSay('Here is your '.. getItemName(itemid) .. '!')
		else
			selfSay('Here are your '.. amount ..' '.. getItemName(itemid) .. 's!')		
		end
	else
		selfSay('Sorry, you do not have enough money.')
	end
end


function sell(cid, itemid, count, cost)
	if(doPlayerRemoveItem(cid, itemid, count) == 1) then
		cost2 = cost*count
		selfSay('Thanks for this '.. getItemName(itemid) .. '!')
		if(doPlayerAddMoney(cid, cost2) ~= TRUE) then
			error('Could not add money to ' .. getPlayerName(cid) .. '(' .. cost .. 'gp)')
		end
		return LUA_NO_ERROR
	else
		selfSay('Sorry, You not have this item')
	end
	return LUA_ERROR
end

-- AddCash by Dzojo
function addcash(cid, cost)

	if cost >= 1 then
		coins = math.floor(cost/10000)
		crystals = coins
		while coins > 100 do
			doPlayerAddItem(cid, 2160, 100)
			coins = coins - 100
		end
		
		doPlayerAddItem(cid, 2160, coins)
		cost = cost - crystals*10000
		
		coins = math.floor(cost/100)
		if coins > 0 then
			doPlayerAddItem(cid, 2152, coins)
			cost = cost - coins*100
		end
		coins = cost
		if cost > 0 and cost < 100 then
			doPlayerAddItem(cid, 2148, coins)
			cost = cost - coins
		end
	else
		selfSay('Error with addcash, contact to GM.')
	end
end

function msgcontains(txt, str)
	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end

-- Including the Advanced NPC System
dofile('data/npc/lib/npcsystem/npcsystem.lua')