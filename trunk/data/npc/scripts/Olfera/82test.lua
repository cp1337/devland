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

function onCreatureSay(cid, type, msg)
	if((msg == "hi") and not (isFocused(cid))) then
		selfSay("Hello! " .. getCreatureName(cid) .. ". I am {Librarian}. If You look for any {book} just ask me.", cid, TRUE)
		selfSay("Do you want to see my {wares}?", cid)
		addFocus(cid)
	elseif((isFocused(cid)) and (msg == "wares" or msg == "trade")) then
		selfSay("Pretty nice, right?", cid)
	elseif((isFocused(cid)) and (msg == "bye" or msg == "goodbye" or msg == "cya")) then
		selfSay("Goodbye!", cid, TRUE)
		focus = 0
	end
end

function onPlayerCloseChannel(cid)
	if(isFocused(cid)) then
		selfSay("Hmph!")
		closeShopWindow(cid)
		focus = 0
	end
end

function onPlayerEndTrade(cid)
	selfSay("It was a pleasure doing business with you.", cid)
end

function onThink()

	for i, focus in pairs(focuses) do
	
		if(isCreature(focus) == FALSE) then
			removeFocus(focus)
		else
			local distance = getDistanceTo(focus) or -1
			if((distance > 4) or (distance == -1)) then
				selfSay("Goodbye Then!")
				removeFocus(focus)
			end
			
			if (os.clock() - talk_start) > 30 then
  				selfSay("Goodbye then...")
  				removeFocus(focus)
  			end
		end
	end
	lookAtFocus()
end
