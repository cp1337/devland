local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false

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

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Hello ' .. getCreatureName(cid) .. '! I can sell You addons.')
  		focus = cid
  		talk_start = os.clock()

	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'citizen') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 136, 3)
					doPlayerAddAddon(cid, 128, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end

			elseif msgcontains(msg, 'hunter') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 137, 3)
					doPlayerAddAddon(cid, 129, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end

			elseif msgcontains(msg, 'summoner') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 141, 3)
					doPlayerAddAddon(cid, 133, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end

			elseif msgcontains(msg, 'knight') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 139, 3)
					doPlayerAddAddon(cid, 131, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end

			elseif msgcontains(msg, 'nobleman') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 140, 3)
					doPlayerAddAddon(cid, 132, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end

			elseif msgcontains(msg, 'mage') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 138, 3)
					doPlayerAddAddon(cid, 130, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end	

			elseif msgcontains(msg, 'warrior') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 142, 3)
					doPlayerAddAddon(cid, 134, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end	

			elseif msgcontains(msg, 'barbarian') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 147, 3)
					doPlayerAddAddon(cid, 143, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end	

			elseif msgcontains(msg, 'druid') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 148, 3)
					doPlayerAddAddon(cid, 144, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end	

			elseif msgcontains(msg, 'wizard') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 149, 3)
					doPlayerAddAddon(cid, 145, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end	

			elseif msgcontains(msg, 'oriental') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 150, 3)
					doPlayerAddAddon(cid, 146, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end	

			elseif msgcontains(msg, 'pirate') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 155, 3)
					doPlayerAddAddon(cid, 151, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end	

			elseif msgcontains(msg, 'assassin') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 156, 3)
					doPlayerAddAddon(cid, 152, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end		

			elseif msgcontains(msg, 'beggar') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 157, 3)
					doPlayerAddAddon(cid, 153, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end	

			elseif msgcontains(msg, 'shaman') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 158, 3)
					doPlayerAddAddon(cid, 154, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end		

			elseif msgcontains(msg, 'norseman') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 252, 3)
					doPlayerAddAddon(cid, 251, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end

			elseif msgcontains(msg, 'nightmare') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 268, 3)
					doPlayerAddAddon(cid, 269, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end

			elseif msgcontains(msg, 'jesker') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 270, 3)
					doPlayerAddAddon(cid, 273, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end

			elseif msgcontains(msg, 'brotherhood') then
				if pay(cid,1000) then
					doPlayerAddAddon(cid, 278, 3)
					doPlayerAddAddon(cid, 279, 3)
					selfSay('OK, done!')
				else
					selfSay('Sorry, you don\'t have enough money.')
				end


  		elseif string.find(msg, '(%a*)bye(%a*)')  and getDistanceToCreature(cid) < 4 then
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
