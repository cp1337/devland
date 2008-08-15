local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false
local buyit = 0
local count = 0
local talk_start = os.clock()
local talk_start2 = os.clock()
local talk_start3 = os.clock()

function onCreatureAppear(creature)
	attacking = true
	target = creature
end


function onCreatureDisappear(id)
	if id == target then
		target = 0
		attacking = false
		selfAttackCreature(0)
		following = false
	end
end


function onCreatureAppear(creature)

end


function msgcontains(txt, str)
  	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onThink()
  	if (os.clock() - talk_start) > 60*30 then
  			commandSay('/saveplayers')
			talk_start = os.clock()
	elseif (os.clock() - talk_start2) > 60*31 then
			commandSay('/savemap')
			talk_start2 = os.clock()
	elseif (os.clock() - talk_start3) > 60*32 then
			commandSay('/savebans')
			talk_start3 = os.clock()
  	end
end
