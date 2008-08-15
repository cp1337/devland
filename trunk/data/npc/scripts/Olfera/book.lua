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

function onThingMove(creature, thing, oldpos, oldstackpos)

end


function onCreatureAppear(cid)
end

function onCreatureDisappear(cid)
	if(isFocused(cid)) then
		selfSay("Hmph!")
		focus = 0
	end
end


function onCreatureTurn(creature)

end


function msgcontains(txt, str)
  	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onCreatureSay(cid, type, msg)
  	msg = string.lower(msg)
	distance = getDistanceTo(cid)

		if (msg == "hi") and not (isFocused(cid)) and (distance < 4) then
		selfSay("Hello! " .. getCreatureName(cid) .. ". I am {Librarian}. If You look for any {book} just ask me.", cid, TRUE)
  		talk_start = os.clock()
		talk_state = 1
		addFocus(cid)

	elseif isFocused(cid) then
		talk_start = os.clock()

	if msgcontains(msg, 'book') then
			selfSay("Yes, we have many books in this libary.", cid)

	elseif msgcontains(msg, 'help') then
			selfSay("You want my Help? Tell me what You need.", cid)

        elseif msgcontains(msg, 'quest') then
			selfSay("There are many quests in Devland World. Ask Burgess about it, i was hear he need someone to do one.", cid) 
        
	elseif msgcontains(msg, 'ferumbras') then
			selfSay("I read abut him in one of book. There was writed he was evil Mag, who lose war for Earth.We have luck he not alive anymore.", cid) 	
	
        elseif msgcontains(msg, 'devon six') then
			selfSay("He is our King! Dont You remember?.", cid)

	elseif msgcontains(msg, 'heal') then
			selfSay("Sorry, i cant heal you.", cid)        

	elseif msgcontains(msg, 'job') then	
	         if getPlayerStorageValue(cid,7525) == -1 then	 
                    talk_state = 2
                    selfSay("Job? Ahh yes, I think maybe have it for You.", cid)
                    selfSay("You will be searcher of books. Are You interested?", cid)
                 elseif getPlayerStorageValue(cid,7525) == 1 then	 
                    talk_state = 2
                    selfSay("Ok, it will be yor frist job for me. I need {trolls cookbook}.", cid)
                 elseif getPlayerStorageValue(cid,7525) == 2 then	 
                    talk_state = 2
                    selfSay("Ok, now your next Job. I need {minotaurs spellbook}.", cid)
                 elseif getPlayerStorageValue(cid,7525) == 3 then	 
                    talk_state = 2
                    selfSay("I need {Goblin Burka Book}. Comeback when you find it.", cid)
		 elseif getPlayerStorageValue(cid,7525) == 4 then	 
                    talk_state = 2
                    selfSay("Ok, now something more hard. Steal for me {Orc King Notepad}.", cid)
                 else
                    talk_state = 2
                    selfSay("Sorry, but i have no Job for You. Ask me for it Later.", cid)	
        end
   
        elseif msgcontains(msg, 'yes') then 
            if talk_state == 2 then   
                    talk_state = 3
                    setPlayerStorageValue(cid,7525,1)
                    selfSay('Ok, then. From now You are book finder. Take this 500 gold, propably it will be needed.')
            else
        end  
	      
	elseif msgcontains(msg, 'trolls cookbook') and getPlayerStorageValue(cid,7525) == 1 then
                 if doPlayerRemoveItem(cid,1966) == 0 then
                    setPlayerStorageValue(cid,7525,2)
                    selfSay("Thanks you for this book.", cid)
                 else  
                    selfSay("Its just Troll CookBook. Probably You can find it somewhere at Troll Caves", cid)
        end

	elseif msgcontains(msg, 'minotaurs spellbook') and getPlayerStorageValue(cid,7525) == 2 then
                 if doPlayerRemoveItem(cid,1966) == 0 then
                    setPlayerStorageValue(cid,7525,3)
                    selfSay("Thanks you for this book.", cid)
                 else  
                    selfSay("Its contains special minotaur spells. Try look at Minotaur montain, maybe there you will find it.", cid)
        end

	elseif msgcontains(msg, 'Goblin Burka Book') and getPlayerStorageValue(cid,7525) == 3 then
                 if doPlayerRemoveItem(cid,1966) == 0 then
                    setPlayerStorageValue(cid,7525,4)
                    selfSay("Thanks you for this book.", cid)
                 else  
                    selfSay("Its Goblin book. Dont know good where you can find it, and about what is it.", cid)
        end

	elseif msgcontains(msg, 'Orc King Notepad') and getPlayerStorageValue(cid,7525) == 4 then
                 if doPlayerRemoveItem(cid,1966) == 0 then
                    setPlayerStorageValue(cid,7525,5)
                    selfSay("Thanks you for this book.", cid)
                 else  
                    selfSay("I dont know anything about this book. Ask Manga Wang, maybe he know something more.", cid)
        end	 	

	elseif((isFocused(cid)) and (msg == "bye" or msg == "goodbye" or msg == "cya")) then
		selfSay("Goodbye!", cid, TRUE)
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

