

function onLogin(cid)

if(getPlayerLastLogin(cid) < 1) then

	doPlayerAddItem(cid, 2483, 1)
	doPlayerAddItem(cid, 2397, 1)
	doPlayerAddItem(cid, 2473, 1)
	doPlayerAddItem(cid, 2513, 1)
	doPlayerAddItem(cid, 2478, 1)
	doPlayerAddItem(cid, 2643, 1)
	doPlayerAddItem(cid, 1991, 1)
	doPlayerAddItem(cid, 2152, 1)
	doShowOutfitWindow(cid)
end

if(getPlayerName(cid) == "AccountManager") then
       doShowTextDialog(cid, 1953, "Welcome at Devland Server. To create account write account, then Manager will ask you for account and password. If you want create character just say player, then Manager will ask about password, and later about player info.")
end

end