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
  		selfSay('Welcome to My Furniture Store, ' .. getCreatureName(cid) .. '.')
  		focus = cid
  		talk_start = os.clock()
		TurnToPlayer(cid)

  	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
  		selfSay('Hello, ' .. getCreatureName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'job') then
			selfSay('Have you moved to a new home? Im the specialist for equipping it.')

		elseif msgcontains(msg, 'specialist') then
        		selfSay('My offers are permanently extraordinarily cheap.')

		elseif msgcontains(msg, 'offer') or msgcontains(msg, 'furniture') then
        		selfSay('I sell statues, tables, chairs, flowers, pillows, pottery, decoration, tapestries and containers.')

		elseif msgcontains(msg, 'statues') then
        		selfSay('What statue would you like? A knights statue, a minotaur statue or a goblin statue?')

		elseif msgcontains(msg, 'tables') then
        		selfSay('Do you want to buy a small table, a round table, a square table or a big table?')

		elseif msgcontains(msg, 'chairs') then
        		selfSay('I can offer you wooden chairs, rocking chairs, red cushioned chairs, green cushioned chairs and sofa chairs.')

		elseif msgcontains(msg, 'flowers') or msgcontains(msg, 'plants') then
        		selfSay('I offer indoor plants, flower bowls, god flowers, honey flowers and potted flowers. What do you need?')

		elseif msgcontains(msg, 'pillows') then
        		selfSay('I can offer small pillows, round pillows, square pillows and heart pillows. Which one might it be?')

		elseif msgcontains(msg, 'pottery') then
        		selfSay('I offer vases, coal basins, amphora and large amphora. What do you need?')

		elseif msgcontains(msg, 'decoration') then
        		selfSay('I can offer water pipes, pendulum clock, telescopes, table lamps, rocking horses, globes, ovens, empty goldfish bowls andbirdcages. I also sell wall hangings.')

		elseif msgcontains(msg, 'containers') then
        		selfSay('I offer drawers, dressers, lockers, crates, chests, boxes, barrels, trunks, troughs, bookcases, weapon racks and armor racks.')

		elseif msgcontains(msg, 'wall hangings') then
        		selfSay('I can offer mirrors, paintings and cuckoo clocks.')

		elseif msgcontains(msg, 'mirrors') then
        		selfSay('I sell round mirrors, oval mirrors and edged mirrors. Which one might it be?')

		elseif msgcontains(msg, 'paintings') then
        		selfSay('Would you like a landscape, a portrait or a still life. What is your choice?')


-- statues ---------------------------------------------------------------------------

		elseif msgcontains(msg, 'knight statue') then
			selfSay('Do you want to buy this wonderful statue for 50 gold?')
			buyit = 1

		elseif msgcontains(msg, 'minotaur statue') then
			selfSay('Do you want to buy this frightening statue for 50 gold?')
			buyit = 2

		elseif msgcontains(msg, 'goblin statue') then
			selfSay('Do you want to buy this disgusting statue for 50 gold?')
			buyit = 3

-- tables ----------------------------------------------------------------------------
		
		elseif msgcontains(msg, 'small table') then
			selfSay('Do you want to buy a small table for 20 gold?')
			buyit = 4

		elseif msgcontains(msg, 'round table') then
			selfSay('Do you want to buy a round table for 25 gold?')
			buyit = 5

		elseif msgcontains(msg, 'square table') then	
			selfSay('Do you want to buy a square table for 25 gold?')
			buyit = 6

		elseif msgcontains(msg, 'big table') then
			selfSay('Do you want to buy a big table for 30 gold?')
			buyit = 7

-- chairs ----------------------------------------------------------------------------
		
		elseif msgcontains(msg, 'wooden chair') then
			selfSay('Do you want to buy a wooden chair for 15 gold?')
			buyit = 8

		elseif msgcontains(msg, 'rocking chair') then
			selfSay('Do you want to buy a rocking chair for 25 gold?')
			buyit = 9

		elseif msgcontains(msg, 'red cushioned') then	
			selfSay('Do you want to buy a red cushioned chair for 40 gold?')
			buyit = 10

		elseif msgcontains(msg, 'green cushioned') then
			selfSay('Do you want to buy a green cushioned chair for 40 gold?')
			buyit = 11

		elseif msgcontains(msg, 'sofa chair') then
			selfSay('Do you want to buy a sofa chair for 55 gold?')
			buyit = 12

-- flowers ----------------------------------------------------------------------------
		
		elseif msgcontains(msg, 'indoor plant') then
			selfSay('Do you want to buy a indoor plant for 8 gold?')
			buyit = 13

		elseif msgcontains(msg, 'flower bowl') then
			selfSay('Do you want to buy a flower bowl for 6 gold?')
			buyit = 14

		elseif msgcontains(msg, 'god flower') then	
			selfSay('Do you want to buy a god flower for 5 gold?')
			buyit = 15

		elseif msgcontains(msg, 'honey flower') then
			selfSay('Do you want to buy a honey flower for 5 gold?')
			buyit = 16

		elseif msgcontains(msg, 'potted flower') then
			selfSay('Do you want to buy a potted flower for 5 gold?')
			buyit = 17
		
-- pillows ----------------------------------------------------------------------------
		
		elseif msgcontains(msg, 'small pillow') then
			selfSay('What color would you prefer? Purple, green, red, blue, orange, turquoise or white?')
			buyit = 201

		elseif msgcontains(msg, 'round pillow') then
			selfSay('What color would you prefer? Purple, red, blue or turquoise?')
			buyit = 202

		elseif msgcontains(msg, 'square pillow') then	
			selfSay('What color would you prefer? Red, green, blue or yellow?')
			buyit = 203

		elseif msgcontains(msg, 'heart pillow') then
			selfSay('Do you want to buy a heart pillow for 30 gold?')
			buyit = 18

-- pottery ----------------------------------------------------------------------------
		
		elseif msgcontains(msg, 'vase') then
			selfSay('Do you want to buy a vase for 3 gold?')
			buyit = 19

		elseif msgcontains(msg, 'coal basin') then
			selfSay('Do you want to buy a coal basin for 25 gold?')
			buyit = 20

		elseif msgcontains(msg, 'amphora') then	
			selfSay('Do you want to buy an amphora for 4 gold?')
			buyit = 21

		elseif msgcontains(msg, 'large amphora') then
			selfSay('Do you want to buy a large amphora for 50 gold?')
			buyit = 22

-- decorations ----------------------------------------------------------------------------
		
		elseif msgcontains(msg, 'water pipe') then
			selfSay('Do you want to buy a vase for 3 gold?')
			buyit = 23

		elseif msgcontains(msg, 'pendulum clock') then
			selfSay('Do you want to buy a coal basin for 25 gold?')
			buyit = 24

		elseif msgcontains(msg, 'telescope') then	
			selfSay('Do you want to buy an amphora for 4 gold?')
			buyit = 25

		elseif msgcontains(msg, 'table lamp') then
			selfSay('Do you want to buy a large amphora for 50 gold?')
			buyit = 26

		elseif msgcontains(msg, 'rocking horse') then
			selfSay('Do you want to buy a large amphora for 50 gold?')
			buyit = 27

		elseif msgcontains(msg, 'globe') then
			selfSay('Do you want to buy a large amphora for 50 gold?')
			buyit = 28

		elseif msgcontains(msg, 'oven') then
			selfSay('Do you want to buy a large amphora for 50 gold?')
			buyit = 29

		elseif msgcontains(msg, 'empty goldfish bowl') then
			selfSay('Do you want to buy a large amphora for 50 gold?')
			buyit = 30

		elseif msgcontains(msg, 'birdcage') then
			selfSay('Do you want to buy a large amphora for 50 gold?')
			buyit = 31

-- containers ----------------------------------------------------------------------------
		
		elseif msgcontains(msg, 'drawer') then
			selfSay('You want to buy drawers for 18 gold?')
			buyit = 32

		elseif msgcontains(msg, 'dresser') then
			selfSay('You want to buy a dresser for 25 gold?')
			buyit = 33

		elseif msgcontains(msg, 'locker') then	
			selfSay('You want to buy a locker for 30 gold?')
			buyit = 34

		elseif msgcontains(msg, 'crate') then
			selfSay('Do you want to buy a crate for 10 gold?')
			buyit = 35

		elseif msgcontains(msg, 'chest') then
			selfSay('Do you want to buy a chest for 10 gold?')
			buyit = 36

		elseif msgcontains(msg, 'box') then
			selfSay('Do you want to buy a box for 10 gold?')
			buyit = 37

		elseif msgcontains(msg, 'barrel') then
			selfSay('Do you want to buy a barrel for 12 gold?')
			buyit = 38

		elseif msgcontains(msg, 'trunk') then
			selfSay('Do you want to buy a trunk for 10 gold?')
			buyit = 39

		elseif msgcontains(msg, 'trough') then
			selfSay('Do you want to buy a trough for 7 gold?')
			buyit = 40

		elseif msgcontains(msg, 'bookcase') then
			selfSay('You want to buy a bookcase for 70 gold?')
			buyit = 41

		elseif msgcontains(msg, 'weapon rack') then
			selfSay('Do you want to buy a weapon rack for 90 gold?')
			buyit = 42

		elseif msgcontains(msg, 'armor rack') then
			selfSay('Do you want to buy an armor rack for 90 gold?')
			buyit = 43

-- tapestries ----------------------------------------------------------------------------
		
		elseif msgcontains(msg, 'purple tapestry') or msgcontains(msg, 'purple tapestries') then
		    count = getCount(msg)
		    if count > 1 then 	
			cost = 25*count
			selfSay('You want to buy ' .. getCount(msg) .. ' purple tapestry for ' .. cost .. ' gold?')
			buyit = 144
		    else
			selfSay('You want to buy a purple tapestry for 25 gold?')
			buyit = 44
		    end	

		elseif msgcontains(msg, 'green tapestry') or msgcontains(msg, 'green tapestries') then
		    count = getCount(msg)
		    if count > 1 then 
			cost = 25*count
			selfSay('You want to buy ' .. getCount(msg) .. ' green tapestry for ' .. cost .. ' gold?')
			buyit = 145
		    else
			selfSay('You want to buy a green tapestry for 25 gold?')
			buyit = 45
		    end

		elseif msgcontains(msg, 'yelow tapestry') or msgcontains(msg, 'yelow tapestries') then
		    count = getCount(msg)
		    if count > 1 then 
			cost = 25*count
			selfSay('You want to buy ' .. getCount(msg) .. ' yelow tapestry for ' .. cost .. ' gold?')
			buyit = 146
		    else
			selfSay('You want to buy a yelow tapestry for 25 gold?')
			buyit = 46
		    end

		elseif msgcontains(msg, 'orange tapestry') or msgcontains(msg, 'orange tapestries') then
		   count = getCount(msg) 
		   if count > 1 then 
			cost = 25*count
			selfSay('You want to buy ' .. getCount(msg) .. ' orange tapestry for ' .. cost .. ' gold?')
			buyit = 147
		    else
			selfSay('You want to buy a orange tapestry for 25 gold?')
			buyit = 47
		    end

		elseif msgcontains(msg, 'red tapestry') or msgcontains(msg, 'red tapestries') then
		    count = getCount(msg)
		    if count > 1 then 	
			cost = 25*count
			selfSay('You want to buy ' .. getCount(msg) .. ' red tapestry for ' .. cost .. ' gold?')
			buyit = 148
		    else
			selfSay('You want to buy a red tapestry for 25 gold??')
			buyit = 48
		    end

		elseif msgcontains(msg, 'blue tapestry') or msgcontains(msg, 'blue tapestries') then
		    count = getCount(msg)
		    if count > 1 then
			cost = 25*count
			selfSay('You want to buy ' .. getCount(msg) .. ' blue tapestry for ' .. cost .. ' gold?')
			buyit = 149
		    else
			selfSay('You want to buy a blue tapestry for 25 gold?')
			buyit = 49
		    end

		elseif msgcontains(msg, 'white tapestry') or msgcontains(msg, 'white tapestries') then
		    count = getCount(msg)
		    if count > 1 then
			cost = 25*count
			selfSay('You want to buy ' .. getCount(msg) .. ' white tapestry for ' .. cost .. ' gold?')
			buyit = 150
		    else
			selfSay('You want to buy a white tapestry for 25 gold?')
			buyit = 50
		    end

		elseif msgcontains(msg, 'tapestries') then
        		selfSay('Please tell me what color you would prefer: purple, green, yellow, orange, red, blue or white?')

		elseif msgcontains(msg, 'yes') then
			if buyit == 1 then
				buy(cid,1442,1,50)
			elseif buyit == 2 then
				buy(cid,1446,1,50)
			elseif buyit == 3 then
                                buy(cid,1447,1,50)
			elseif buyit == 4 then
				buy(cid,3912,1,20)
			elseif buyit == 5 then
				buy(cid,3911,1,25)
			elseif buyit == 6 then
                                buy(cid,3910,1,25)
			elseif buyit == 7 then
				buy(cid,3909,1,30)	
			elseif buyit == 8 then
				buy(cid,3901,1,15)
			elseif buyit == 9 then
                                buy(cid,3901,1,25)
			elseif buyit == 10 then
				buy(cid,3903,1,40)	
			elseif buyit == 11 then
				buy(cid,3904,1,40)
			elseif buyit == 12 then
                                buy(cid,3902,1,55)
			elseif buyit == 13 then
				buy(cid,3921,1,8)	
			elseif buyit == 14 then
				buy(cid,2102,1,6)
			elseif buyit == 15 then
                                buy(cid,2100,1,5)
			elseif buyit == 16 then
				buy(cid,2103,1,5)	
			elseif buyit == 17 then
				buy(cid,3928,1,5)
			elseif buyit == 18 then
                                buy(cid,1685,1,30)
-- pottery ----------------------------------------------------------------------------
			elseif buyit == 19 then
				buy(cid,2008,1,3)
			elseif buyit == 20 then
				buy(cid,3908,1,25)
			elseif buyit == 21 then
                                buy(cid,2023,1,4)
			elseif buyit == 22 then
				buy(cid,2034,1,50)
-- decorations ----------------------------------------------------------------------------
			elseif buyit == 23 then
				buy(cid,2093,1,3)
			elseif buyit == 24 then
                                buy(cid,3933,1,25)
			elseif buyit == 25 then
				buy(cid,2544,1,4)	
			elseif buyit == 26 then
				buy(cid,3937,1,50)
			elseif buyit == 27 then
                                buy(cid,2543,1,50)
			elseif buyit == 28 then
				buy(cid,3927,1,50)
			elseif buyit == 29 then
				buy(cid,2455,1,50)
			elseif buyit == 30 then
                                buy(cid,5928,1,50)
			elseif buyit == 31 then
				buy(cid,3918,1,50)
-- containers ----------------------------------------------------------------------------
			elseif buyit == 32 then
				buy(cid,3921,1,2)
			elseif buyit == 33 then
				buy(cid,3932,1,450)
			elseif buyit == 34 then
                                buy(cid,3934,1,3)
			elseif buyit == 35 then
				buy(cid,1739,1,2)
			elseif buyit == 36 then
				buy(cid,3915,1,450)
			elseif buyit == 37 then
                                buy(cid,1738,1,3)
			elseif buyit == 38 then
				buy(cid,3923,1,2)	
			elseif buyit == 39 then
				buy(cid,3938,1,450)
			elseif buyit == 40 then
                                buy(cid,3935,1,3)
			elseif buyit == 41 then
				buy(cid,2544,1,2)
			elseif buyit == 42 then
				buy(cid,2455,1,450)
			elseif buyit == 43 then
                                buy(cid,2543,1,3)
-- tapestries ----------------------------------------------------------------------------
			elseif buyit == 44 then
				buy(cid,1857,1,25)
			elseif buyit == 45 then
				buy(cid,1860,1,25)
			elseif buyit == 46 then
				buy(cid,1863,1,25)
			elseif buyit == 47 then
                                buy(cid,1866,1,25)
			elseif buyit == 48 then
				buy(cid,1869,1,25)
			elseif buyit == 49 then
                                buy(cid,1872,1,25)
			elseif buyit == 50 then
				buy(cid,1880,1,25)
			elseif buyit == 144 then
				buy(cid,1857,count,25)
			elseif buyit == 145 then
				buy(cid,1860,count,25)
			elseif buyit == 146 then
				buy(cid,1863,count,25)
			elseif buyit == 147 then
                                buy(cid,1866,count,25)
			elseif buyit == 148 then
				buy(cid,1869,count,25)
			elseif buyit == 149 then
                                buy(cid,1872,count,25)
			elseif buyit == 150 then
				buy(cid,1880,count,25)			
		end
		sellit = 0
		buyit = 0

		elseif msgcontains(msg, 'no') then
			selfSay('Hmm, but I\'m sure, it would fit nicely into your house.')
			buyit = 0
			sellit = 0
		end

		if string.find(msg, '(%a*)bye(%a*)') then
			selfSay('Good bye.')
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
  			selfSay('Good bye.')
  		end
  			focus = 0
  	end
 	if focus ~= 0 then
 		if getDistanceToCreature(focus) > 5 then
 			selfSay('Good bye.')
 			focus = 0
 		end
 	end
end