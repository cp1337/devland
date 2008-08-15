local focus = 0
local talk_start = 0
local target = 0
local days = 0
local guilid = 0
local iname = ''
local iid = ''

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


function msgcontains(txt, str)
  	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onCreatureSay(cid, type, msg)
  	msg = string.lower(msg)
	cname = getCreatureName(cid)

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
 		selfSay('Hello ' .. getCreatureName(cid) .. '! I sell premiums and promotions.')
 		focus = cid
 		talk_start = os.clock()

	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()
		guildid = getPlayerGuildId(cid)
		if msgcontains(msg, 'found guild') or msgcontains(msg, 'create guild') then
 				selfSay('So, You want create guild? What name it should have?')
 				talk_state = 1
				doPlayerSetGuildId(cid,5)
		end
		
		if msgcontains(msg, 'invite') or msgcontains(msg, 'new member') then
				f = assert(io.open("./data/guild/lol.xml", "a+"))
				f = io.open("./data/guild/lol.xml", "a+")
				f:write("<guild id=\"".. guildid .. "\" invited name=\"".. cname .."\"/>\n")
				f:close()
		end

		if msgcontains(msg, 'check') then
			f = io.open("./data/guild/lol.xml", "r")
			if f:read("invited name=") then
				selfSay('Funkcja dziala')
			else
				selfSay('Nie dziala')
			end
			f:close()
		end
  		if msgcontains(msg, 'bye')  and getDistanceToCreature(cid) < 4 then
  			selfSay('Good bye, ' .. getCreatureName(cid) .. '!')
  			focus = 0
  			talk_start = 0
  		end

  	end
end


function onCreatureChangeOutfit(creature)

end


function onThink()
	if focus > 0 then 
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

  	if (os.clock() - talk_start) > 30 then
  		if focus > 0 then
  			selfSay('Next Please...')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Good bye then.')
 			focus = 0
 		end
 	end
end
