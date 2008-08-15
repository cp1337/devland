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
 		selfSay('Greetings, ' .. getCreatureName(cid) .. '.')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
		     selfSay('I am working here at the post office. If you have questions about the Royal Devland Mail System or the depots ask me.')

		elseif msgcontains(msg, 'depots') then
		     selfSay('The depots are very easy to use. Just step in front of them and you will find your items in them. They are free for all Devland citizens.')

		elseif msgcontains(msg, 'mail') then
		     selfSay('Our mail system is unique! And everyone can use it. Do you want to know more about it?')
		     talk_state = 2

		elseif msgcontains(msg, 'parcel') or msgcontains(msg, 'parcels') then
		    count = getCount(msg)
		    if count > 1 then
		        cost = 15*count
			talk_state = 13
		        selfSay('You want to buy ' .. getCount(msg) .. ' parcels for ' .. cost .. ' gold?')
                    else
		        selfSay('Do you want to buy a parcel for 15 gold?')
			talk_state = 3
		    end

		elseif msgcontains(msg, 'letter') or msgcontains(msg, 'letters') then
		    count = getCount(msg)
		    if count > 1 then
		        cost = 8*count
			talk_state = 14
		        selfSay('You want to buy ' .. getCount(msg) .. ' leters for ' .. cost .. ' gold?')
                    else
		        selfSay('Do you want to buy a leter for 8 gold?')
			talk_state = 4
		    end

		elseif msgcontains(msg, 'yes') then
		     if talk_state == 2 then
		          selfSay('The Devland Mail System enables you to send and receive letters and parcels. You can buy them here if you want.')
		     
		     elseif talk_state == 3 then
                          buy(cid,2595,1,15)
		      	  doPlayerAddItem(cid,2599,1)

		     elseif talk_state == 4 then
			buy(cid,2597,1,10)
		end

		elseif msgcontains(msg, 'no') and talk_state >= 2 then
			selfSay('Ok.')

		elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
			selfSay('It was a pleasure to help you.')
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
  			selfSay('It was a pleasure to help you.')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('It was a pleasure to help you.')
 			focus = 0
 		end
 	end
end