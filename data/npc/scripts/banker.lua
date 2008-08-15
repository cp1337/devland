focus = 0
talk_start = 0
target = 0
following = false
attacking = false
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
	balance = getPlayerStorageValue(cid,100)

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Welcome ' .. getCreatureName(cid) .. '! What can I do for you? ')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Sorry, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

	if msgcontains(msg, 'job') then
			selfSay('I work in this bank. I can change money for you.')

	elseif msgcontains(msg, 'offer') or msgcontains(msg, 'bank') then
			selfSay('We can change money for you. You can also access your bank account.')

	elseif msgcontains(msg, 'account') then
			selfSay('From now on every Devland adventurer has one. The big advantage is that you can access your money in every branch of the Bank of Devland!! ...')
			selfSay('Would you like to know more about the basic functions of your bank account, the advanced functions, or are you already bored,perhaps?')

	elseif msgcontains(msg, 'deposit') then
			selfSay('Please tell me how much gold it is you would like to deposit.')
			talk_state = 2

        elseif msgcontains(msg, 'withdraw') then
			selfSay('Please tell me how much gold you would like to withdraw.')
			talk_state = 3

	elseif getCount(msg) and talk_state == 2 then
			cash = getCount(msg)
			selfSay('Would you really like to deposit ' .. cash .. ' gold?')
			talk_state = 4
	 	
	elseif getCount(msg) and talk_state == 3 then
			cash = getCount(msg)
			selfSay('Would you really like to withdraw ' .. cash .. ' gold?')
			talk_state = 5
	
        elseif msgcontains(msg, 'balance') then
			selfSay('Your account balance is ' .. balance .. ' gold.')
			talk_state = 0
			
        elseif msgcontains(msg, 'basic functions') then
			selfSay('You can check the balance of your bank account, deposit money or withdraw it. You can also transfer money to othercharacters, provided that they have a vocation.')
			talk_state = 0

        elseif msgcontains(msg, 'advanced functions') then
			selfSay('Renting a house has never been this easy. Simply make a bid for an auction. We will check immediately if you have enough money ...')
			selfSay('Please keep in mind that the sum you have used to bid will be unavailable unless somebody places a higher bid. Once you haveacquired a house the rent will be charged automatically from your bank account every month.')
			talk_state = 0

        elseif msgcontains(msg, 'yes') then
		    add = balance + cash
		    minus = balance - cash	
	      if cash >= 1 and talk_state == 4 then
	           if pay(cid,cash) then 
                         setPlayerStorageValue(cid,100,add)
                         selfSay('Alright, we have added the amount of ' .. cash .. ' gold to your balance. You can withdraw your money anytime you want to.')
		    else
	                 selfSay('Sorry, you not have that much money')
	            end
		    talk_state = 0	

	
	      elseif cash >= 1 and cash <= balance and talk_state == 5 then
                    setPlayerStorageValue(cid,100,minus)
		    addcash(cid, cash)
		    talk_state = 0	
                    selfSay('Here you are, ' .. cash .. ' gold. Please let me know if there is something else I can do for you.')
	      elseif cash > balance and talk_state == 5 then
		    selfSay('Sorry, but you not have that much money on you bank account')
		    talk_state = 0
	      else
	end

	elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
	             selfSay('Good bye, ' .. getCreatureName(cid) .. '! Come back soon..')
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

