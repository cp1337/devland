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
 		selfSay('Hello ' .. getCreatureName(cid) .. '! I can Create guild, and invite Member.')
 		focus = cid
		talk_state = 0
 		talk_start = os.clock()
		cname = getCreatureName(cid)
		TurnToPlayer(cid)

	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()
		playerguid = getPlayerGUID(cid)

	if msgcontains(msg, 'bye')  and getDistanceToCreature(cid) < 4 then
  			selfSay('Good bye, ' .. getCreatureName(cid) .. '!')
  			focus = 0
  			talk_start = 0
  		end

		if talk_state <= 1 then

		if msgcontains(msg, 'found guild') or msgcontains(msg, 'create guild') then
 				selfSay('So, You want create guild? What name it should have?')
 				talk_state = 2

		elseif msgcontains(msg, 'invite') or msgcontains(msg, 'new member') then
				if (getPlayerGuildRank(cid) == "leader") then
				selfSay('So, Who You want to Invite?')
				talk_state = 3
				end

		elseif msgcontains(msg, 'join') or msgcontains(msg, 'new member') then
				selfSay('So, You want join to guild ' .. invited[2] .. '?')
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
						selfSay('OK, you joined to guild.')
						talk_state = 0
					elseif (cname == invited[0]) then
						selfSay('Sorry, You are not invited to any guild.')
					end

				end
		end

		if talk_state == 3 then
		invitedname = msg
		if msgcontains(invitedname, allow_pattern) then
				invited[0] = invitedname
				invited[1] = playerguid
				invited[2] = getPlayerGuildName(cid)
				selfSay('OK, player ' .. invited[0] .. ' was invited.')
				player = player + 3
				talk_state = 0
		end
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
