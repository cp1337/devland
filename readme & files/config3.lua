-------- config.lua --------
-- Config file for OTServ --
----------------------------

-- data directory location
datadir = "data/"

-- map location
map = "data/world/SadTeamMapper.otbm"

-- mapkind
-- options: OTBM for binary map, XML for OTX map
mapkind = "OTBM"

-- map store location (for XML only)
mapstore = "data/world/SadTeamMapper-mapstore.xml"

-- house store location (for XML only)
housestore = "data/world/SadTeamMapper-housestore.xml"

-- server name
servername = "B-Fox"

-- server location
location = "Poland"

-- server ip (the ip that server listens on)
ip = "localhost"

-- server port (the port that server listens on)
port = "7171"

-- server owner name
ownername = "Omen"

-- world name
worldname = "B-Fox"

-- world type
-- options: pvp, no-pvp, pvp-enforced
worldtype = "pvp"

-- exhausted time in ms (1000 = 1 second) for none-aggressive spells/weapons
exhausted = 1000

-- exhausted time in ms (1000 = 1 second) for aggressive spells/weapons
fightexhausted = 1000

-- how many ms to add if the player is already exhausted and tries to cast a spell (1000 = 1 second)
exhaustedadd = 200

-- how long does the player has to stay out of fight to get pz unlocked in ms (1000 = 1 second)
pzlocked = 60*1000

-- set to 0 = disabled (default), 1 = enabled
enablehotkeys = 1

-- minimum amount of time between actions ('Use') (1000 = 1 second)
minactioninterval = 200

-- minimum amount of time between extended actions ('Use with...') (1000 = 1 second)
minactionexinterval = 1000

-- house rent period
-- options: daily, weekly, monthly
houserentperiod = "monthly"

-- despawn configs
-- how many floors can a monster go from his spawn before despawning
despawnrange = 2

-- how many square metters can a monster be far from his spawn before despawning
despawnradius = 50

-- max number of messages a player can say before getting muted (default 4), set to 0 to disable muting
maxmessagebuffer = 4

-- motd (the message box that you sometimes get before you choose characters)
motd = "Welcome to B-Fox!"
motdnum = "1"

-- login message
loginmsg = "Welcome to OTServ."

-- how many logins attempts until ip is temporary disabled 
-- set to 0 to disable
logintries = 5

-- how long the retry timeout until a new login can be made (without disabling the ip)
retrytimeout = 5000

-- how long the player need to wait until the ip is allowed again
logintimeout = 60 * 100

-- allow clones (multiple logins of the same char)
-- options: 0 (no), 1 (yes)
allowclones = 0

-- only one player online per account
-- options: 0 (no), 1 (yes)
checkaccounts = 0

-- max number of players allowed
maxplayers = "900"

-- save client debug assertion reports
-- options: 0 (no), 1 (yes)
saveclientdebug = 0

-- Set the max query interval for retrieving status information
-- default: 5 minutes / IP (5 * 60 * 1000)
-- set to 0 to disable
statustimeout = 0

-- accounts password type
-- options: plain, md5, sha1
passwordtype = "plain"

-- SQL
-- options: mysql
sql_type = "mysql"

--- SQL connection part
sql_db   = "otserv"
sql_host = "localhost"
sql_port = 3306
sql_user = "root"
sql_pass = "kozibob202"

-- guild system type (SQL only) ingame / online
-- online guild system requires the latest Swelia AAC
guildsystem = "ingame"

----------------------------
-------Configuration ------
----------------------------

-- Crytical Hits
criticalHitChance = 7

-- Time of server save
-- 1 = 1 min
autosave = 15

-- Kick time (afk too long)
-- 1 = 1 min
kicktime = 15

-- Rent House System
-- Do you wanna use this?
house_rent = "yes"

-- allow outfit change
outfitchange = "yes"

-- Will players have free premium account?
-- yes or no
freepremium = "no"

-- Online.php Save Time
-- 1 = 1 min
onlinesave = 15

-- Cap system
-- Do you want cap system working?
capsystem = "yes"

-- Ammunation
-- Remove ammunation
removeammunation = "yes"

-- Rune Charges
-- No if runes infinite, Yes, if runes are not infinite
removerunecharges = "yes"

-- Learn Spell System
-- Do the players have to learn spells?
learnspells = "no"

-- Death List
-- Max Quantity of death entries
maxDeathEntries = 20

-- Houses
-- Price for each sqm
houseprice = 200
-- Level to buy a house
houselevel = 20

-- Corpse System
-- How many seconds receive you are not the owner
corpsemuted = 10

-- Clean Map
-- Auto Clean map : minutes
autocleanmap = 15

-- Exp colors
-- Randomize colors?
exp_color_random = "no"
-- If no, what color will be used? 215 = WHITE NORMAL EXP
exp_color = 215

-- If there's a house that is not configured, show warnings?
-- Yes/No
house_warning = "no"

-- If there's any deprecated item, show warning?
-- Yes/No
deprecated_warning = "no"

-- Shows in item "IT WAS MADE BY XXX"
-- When gamemasters makes items?
show_description = "yes"

-- Online list save update
-- Do you wanna refresh the online.php ALWAYS someone log in or log out? DEFAULT IS NO, CAN CAUSE LAG!
-- Mostly used by otservs that have sites that verify if someone is online
online_update = "no"

-- Protect system
-- Protect Level
protectLevel = 20

-------------------------------------------------------------------------------------
----------------------------------- Multipliers -----------------------------------
-------------------------------------------------------------------------------------

-- rates (experience, skill, magic level, loot and spawn)
rate_exp = 15
rate_skill = 100
rate_mag = 30
rate_loot = 2
rate_spawn = 2


-------- ACC. Man  ---------
-- Acc Manager Configur. --
----------------------------

-- Do you wanna use acc manager? (yes/no)
accountManager = "yes"
accountManager_account = 111111
accountManager_password = "tibia"


-- Player Status

player_level = 8
player_exp = 4200      
player_maglevel = 0  
player_cap = 470
player_soul = 100     	
player_heath = 185
player_mana = 35

-- Player localizations
-- X Y AND Z = 0 TO TEMPLE
town_id = 1
pos_x = 424
pos_y = 502
pos_z = 7

-- Items
-- Leave 0 if you don't want

helmet = 2490
armor = 2463
legs = 2647
boots = 2643
hand1 = 2397
hand2 = 2509
amulet = 2170
ring = 2206
arrowslot = 2544
arrowslot_count = 100

---------------------------------------------------------------------------------------
-------------------------- Skull System -----------------------------------------------
---------------------------------------------------------------------------------------


-- time to lose a white skull (1 = 1 minute)
whitetime = 15

-- time to lose one frag (1 = 1 hour)
fragtime = 1

-- ban unjust, how many frags you need to get banned (1 = 1 frag)
banunjust = 6

-- red skull unjust, how many frags you need to get a red skull (1 = 1 frag)
redunjust = 3

-- bantime, for how long the player is banned (1 = 1 hour)
bantime = 24*1


------ Stages System ------
--- Config Stage System ---
----------------------------

-- Wanna use stages?
-- Yes/No
usestages = "no"

-- LEAVE 0 AT RATE IF YOU WANNA IGNORE ONE STAGE
-- IF PLAYER AREN'T IN ANY STAGE, HIS RATE WILL BE NORMAL RATE_EXP
-- JUST FIVE STAGES, DO NOT ADD MORE

-- FIRST STAGE
-- INITIAL LEVEL OF THIS STAGE
initial_first = 8
-- END LEVEL OF THIS STAGE
end_first = 20
-- RATE EXP OF THIS STAGE
rate_first = 10

-- SECOND STAGE
-- INITIAL LEVEL OF THIS STAGE
initial_second = 21
-- END LEVEL OF THIS STAGE
end_second = 50
-- RATE EXP OF THIS STAGE
rate_second = 9

-- THIRD STAGE
-- INITIAL LEVEL OF THIS STAGE
initial_third = 51
-- END LEVEL OF THIS STAGE
end_third = 80
-- RATE EXP OF THIS STAGE
rate_third = 8

-- FOURTH STAGE
-- INITIAL LEVEL OF THIS STAGE
initial_fourth = 81
-- END LEVEL OF THIS STAGE
end_fourth = 100
-- RATE EXP OF THIS STAGE
rate_fourth = 7

-- FIFTH STAGE
-- INITIAL LEVEL OF THIS STAGE
initial_fifth = 101
-- END LEVEL OF THIS STAGE
end_fifth = 200
-- RATE EXP OF THIS STAGE
rate_fifth = 6

-------- Rook Cfg  ---------
--  Rook System Configur. --
----------------------------

-- TownID of RookGard
rook_townid = 9

-- Can the players be rooked? (yes/no)
player_can_be_rooked = "yes"

-- Level to be rooked
level_to_be_rooked = 5

-------- Login msg --------
-- Config Login Messages --
----------------------------

-- This message at global tibia is: "You must enter your account number."
messageone = "You must enter an account number."

-- This message at global tibia is: "Too many connections attempts from this IP. Try again later."
messagetwo = "Too many connections attempts from this IP. Try again later."

-- This message at tibia global is: "Your IP is banished!"
messagethr = "Your IP is banished!"

-- This message at tibia global is: "Please enter a valid account number and password."
messagefou = "Please enter a valid account number and password."