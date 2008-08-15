local focus = 0
local talk_start = 0
local target = 0
local iname = ''
local iid = ''
local allow_pattern = '^[a-zA-Z0-9 -]+$'
local invited = {}
local player = 0

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
  	

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
 		selfSay('Hello ' .. getCreatureName(cid) .. '! I sell premiums and promotions.')
 		focus = cid
		talk_state = 0
 		talk_start = os.clock()
		cname = getCreatureName(cid)

	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()
		playerguid = getPlayerGUID(cid)

		if talk_state <= 1 then

		if msgcontains(msg, 'found guild') or msgcontains(msg, 'create guild') then
 				selfSay('So, You want create guild? What name it should have?')
 				talk_state = 2

		elseif msgcontains(msg, 'invite') or msgcontains(msg, 'new member') then
				selfSay('So, Who You want to Invite?')
				talk_state = 3

		elseif msgcontains(msg, 'join') or msgcontains(msg, 'new member') then
				selfSay('So, You want Join?')
				talk_state = 4
		end
  		else	-- talk_state != 0
  			talk_start = os.clock()

		if talk_state == 2 then
		guildname = msg
		if msgcontains(guildname, allow_pattern) and talk_state == 2 then
				doPlayerSetGuildId(cid, playerguid)
				setPlayerGuildName(cid, guildname)
				doPlayerSetGuildRank(cid, "leader")
				selfSay('OK, guild ' .. guildname .. ' was created.')
				talk_state = 0
		end
		end

		if talk_state == 4 then
			if msgcontains(msg, 'yes') then
					if (cname == invited[0]) then
						doPlayerSetGuildId(cid, invited[1])
						setPlayerGuildName(cid, invited[2])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[3]) then
						doPlayerSetGuildId(cid, invited[4])
						setPlayerGuildName(cid, invited[5])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[6]) then
						doPlayerSetGuildId(cid, invited[7])
						setPlayerGuildName(cid, invited[8])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[9]) then
						doPlayerSetGuildId(cid, invited[10])
						setPlayerGuildName(cid, invited[11])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[12]) then
						doPlayerSetGuildId(cid, invited[13])
						setPlayerGuildName(cid, invited[14])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[15]) then
						doPlayerSetGuildId(cid, invited[16])
						setPlayerGuildName(cid, invited[17])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[18]) then
						doPlayerSetGuildId(cid, invited[19])
						setPlayerGuildName(cid, invited[20])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[21]) then
						doPlayerSetGuildId(cid, invited[22])
						setPlayerGuildName(cid, invited[23])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[24]) then
						doPlayerSetGuildId(cid, invited[25])
						setPlayerGuildName(cid, invited[26])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					elseif (cname == invited[27]) then
						doPlayerSetGuildId(cid, invited[28])
						setPlayerGuildName(cid, invited[29])
						selfSay('OK, you join to guild.')
						selfSay('ok,' .. invited[0] .. '.')
						selfSay('.' .. cname .. '.')
						talk_state = 0
					else
						selfSay('Sorry, You are not invited to any guild.')
					end

				end
		end

		if talk_state == 3 then
		invitedname = msg
		if msgcontains(invitedname, allow_pattern) then
				invited[0 + player] = invitedname
				invited[1 + player] = playerguid
				invited[2 + player] = getPlayerGuildName(cid)
				selfSay('OK, player ' .. invited[0 + player] .. ' was invited.')
				player = player + 3
				talk_state = 0
		end
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
