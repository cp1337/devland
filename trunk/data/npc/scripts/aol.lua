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

  	if (msgcontains(msg, 'hi') and focus == 0) and getDistanceToCreature(cid) < 4 then
  		selfSay('Hello ' .. creatureGetName(cid) .. '! What bring You to me?')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. creatureGetName(cid) .. '! I talk to you in a minute.')

  	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
		       selfSay('I keep secrets of mystic amulet of loss')			

		elseif msgcontains(msg, 'aol') or msgcontains(msg, 'amulet of loss') then
			selfSay('It\'s powerfull amulet. When you die with it, You not loose equipment.')
			selfSay('I can sell You it for 50k gold pieces. Deal?')
			buyit = 1

		elseif msgcontains(msg, 'eremo') then
			selfSay('Yes, it\'s me')

		elseif msgcontains(msg, 'name') then
			selfSay('Everyone call me Eremo.')

		elseif msgcontains(msg, 'yes') and buyit == 1 then
			buy(cid,2173,1,50000)
			buyit = 0

		elseif msgcontains(msg, 'no') then
			buy(cid,2173,1,50000)
			buyit = 0

		elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
			selfSay('Good bye, ' .. creatureGetName(cid) .. '!')
			focus = 0
			talk_start = 0
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
