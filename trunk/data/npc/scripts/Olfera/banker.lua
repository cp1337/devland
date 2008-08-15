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
	balance = getPlayerStorageValue(cid,100)

  	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
  		selfSay('Hello, ' .. getCreatureName(cid) .. '! I will heal you if you are injured. Feel free to ask me for help.')
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
	
        	elseif msgcontains(msg, 'balance') then
			selfSay('Your account balance is ' .. getPlayerBalance(cid) .. ' gold.')
			talk_state = 0
			
        	elseif msgcontains(msg, 'basic functions') then
			selfSay('You can check the balance of your bank account, deposit money or withdraw it. You can also transfer money to othercharacters, provided that they have a vocation.')
			talk_state = 0
	
       	        elseif msgcontains(msg, 'advanced functions') then
			selfSay('Renting a house has never been this easy. Simply make a bid for an auction. We will check immediately if you have enough money ...')
			selfSay('Please keep in mind that the sum you have used to bid will be unavailable unless somebody places a higher bid. Once you haveacquired a house the rent will be charged automatically from your bank account every month.')
			talk_state = 0

		elseif getCount(msg) and talk_state == 2 then
			cash = getCount(msg)
			selfSay('Would you really like to deposit ' .. cash .. ' gold?')
			talk_state = 4
	 	
		elseif getCount(msg) and talk_state == 3 then
			cash = getCount(msg)
			selfSay('Would you really like to withdraw ' .. cash .. ' gold?')
			talk_state = 5

--- Change Gold ---------------------------------------------------------------------------------

		elseif msgcontains(msg, 'change gold') then
			selfSay('How many platinum coins would you like to get?')
			talk_state = 10

		elseif msgcontains(msg, 'change platinum') then
			selfSay('How many crystal coins would you like to get?')
			talk_state = 14

--- Change gold continue ----------------------------------------------------------------------------

		elseif getCount(msg) and talk_state == 10 then
			cash = getCount(msg)
			cash2 = cash*100
			selfSay('So you would like me to change ' .. cash2 .. ' of your gold coins into ' .. cash .. ' platinum coins?')
			talk_state = 20

		elseif getCount(msg) and talk_state == 14 then
			cash = getCount(msg)
			cash2 = cash*100
			selfSay('So you would like me to change ' .. cash2 .. ' of your platinum coins into ' .. cash .. ' crystal coins?')
			talk_state = 24
--- Yes! Part ------------------------------------------------------------------------------------------
        	elseif msgcontains(msg, 'yes') then

			if talk_state == 20 then
				if doPlayerRemoveItem(cid,2148, cash2) == 1 then
					doPlayerAddItem(cid,2152,cash,cash)
				else
					selfSay('Sorry, You not have that many gold coins.')	
				end
				talk_state = 0	
			end

			if talk_state == 24 then
				if doPlayerRemoveItem(cid,2152,cash2) == 1 then
					doPlayerAddItem(cid,2160,cash,cash)
				else
					selfSay('Sorry, You not have that many platinum coins.')
				end
				talk_state = 0	
			end


	     		if cash >= 1 and talk_state == 4 then
	           	        if getPlayerMoney(cid) >= cash then 
                                        doPlayerDepositMoney(cid, cash)
                                        selfSay('Alright, we have added the amount of ' .. cash .. ' gold to your balance. You can withdraw your money anytime you want to.')
		    		  else
	                                  selfSay('Sorry, you not have that much money')
	            	  end
			talk_state = 0			

	
	      	elseif getPlayerBalance(cid) >= cash and talk_state == 5 then
                           doPlayerWithdrawMoney(cid, cash)
		               talk_state = 0	
                           selfSay('Here you are, ' .. cash .. ' gold. Please let me know if there is something else I can do for you.')
	                

			elseif getPlayerBalance(cid) < cash and talk_state == 5 then
		                selfSay('Sorry, but you not have that much money on you bank account')
		                talk_state = 0
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
  			selfSay('Well, bye then.')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Well, bye then.')
 			focus = 0
 		end
 	end
end