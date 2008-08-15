local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false
local buyit = 0
local count = 0

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
  		selfSay('Ashari ' .. getCreatureName(cid) .. '.')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('I sell musical instruments of many kinds.')	

		elseif msgcontains(msg, 'instruments') or msgcontains(msg, 'offer') then
        		selfSay('I sell lyres, lutes, drums, and simple fanfares.')	
	
		elseif msgcontains(msg, 'musicial instruments') or msgcontains(msg, 'music') then
			selfSay('Music is an attempt to condense emotions into harmonies and save them for the times to come.')

		elseif msgcontains(msg, 'magic') then
        		selfSay('Sorry, I don't feel like teaching magic today.')	

		elseif msgcontains(msg, 'harmonies') or msgcontains(msg, 'song') then
        		selfSay(' Everything is a song. Life, death, history ... everything. To listen to the song of something is the first step to understand it.')

		elseif msgcontains(msg, 'time') then
        		selfSay('Time has its own song. Close your eyes and listen to the symphony of the seasons.')

		elseif msgcontains(msg, 'elf') then
        		selfSay('We are the most graceful of all races. We feel the music of the universe in our hearts and souls.')

		elseif msgcontains(msg, 'human') then
        		selfSay('They are too loud and don't even understand the concept of a melody.')




		elseif msgcontains(msg, 'lyre') then
			selfSay('Do you want to buy a lyre for 120 gold?')
			buyit = 1
		elseif msgcontains(msg, 'lute') then
			selfSay('Do you want to buy a lute for 195 gold?')
			buyit = 2
		elseif msgcontains(msg, 'drum') then
			selfSay('Do you want to buy a drum for 140 gold?')
			buyit = 3
		elseif msgcontains(msg, 'simple fanfare') then
			selfSay('Do you want to buy a simple fanfare for 150 gold?.')
			buyit = 4
		
		elseif msgcontains(msg, 'yes') then
			if buyit == 1 then
				buy(cid,2372,1,120)
			elseif buyit == 2 then
				buy(cid,2370,1,195)
			elseif buyit == 3 then
                                buy(cid,2367,1,140)
			elseif buyit == 4 then
				buy(cid,2368,1,150]			
		end

		elseif msgcontains(msg, 'no') then
			selfSay('Maybe you will buy it another time.')
			buyit = 0
		end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Asha Thrazi.')
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
  			selfSay('Asha Thrazi.')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Asha Thrazi.')
 			focus = 0
 		end
 	end
end