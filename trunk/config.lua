-------- config.lua --------
-- Config file for OTServ --
----------------------------

-- data directory location
datadir = "data/"

-- map location
map = "data/world/dev.otbm"

-- mapkind
-- options: OTBM for binary map, XML for OTX map
mapkind = "OTBM"

-- server name
servername = "DevLand"

-- server location
location = "Poland"

-- server ip (the ip that server listens on)
ip = "89.228.82.254"

-- server port (the port that server listens on)
port = "7171"

-- server url
url = "http://otserv.org"

-- server owner name
ownername = "DeVoNSiX"

-- server owner email
owneremail = "devonsix@o2.pl"

-- world name
worldname = "DevLand"

-- world type
-- options: pvp, no-pvp, pvp-enforced
worldtype = "pvp"

-- exhausted time in ms (1000 = 1 second) for none-aggressive spells/weapons
exhausted = 1000

-- exhausted time in ms (1000 = 1 second) for aggressive spells/weapons
fightexhausted = 2000

-- how many ms to add if the player is already exhausted and tries to cast a spell (1000 = 1 second)
exhaustedadd = 200

-- how long does the player has to stay out of fight to get pz unlocked in ms (1000 = 1 second)
pzlocked = 6000

-- set to 0 = disabled (default), 1 = enabled
enablehotkeys = 1

-- minimum amount of time between actions ('Use') (1000 = 1 second)
minactioninterval = 200

-- minimum amount of time between extended actions ('Use with...') (1000 = 1 second)
minactionexinterval = 1000

-- house rent period
-- options: daily, weekly, monthly
houserentperiod = "monthly"

-- Should the server use account balance system or depot system for paying houses?
useaccbalance = "yes"

-- rates (experience, skill, magic level, loot and spawn)
rate_exp = 5
rate_skill = 5
rate_mag = 5
rate_loot = 5
rate_spawn = 2

-- despawn configs
-- how many floors can a monster go from his spawn before despawning
despawnrange = 2

-- how many square metters can a monster be far from his spawn before despawning
despawnradius = 50

-- max number of messages a player can say before getting muted (default 4), set to 0 to disable muting
maxmessagebuffer = 4

-- motd (the message box that you sometimes get before you choose characters)
motd = "Please remove all items from yor house to end of the week, or all items will be lost."
motdnum = "1"

-- login message
loginmsg = "Please remove all items from yor house to end of the week, or all items will be lost."

-- how many logins attempts until ip is temporary disabled 
-- set to 0 to disable
logintries = 5

-- how long the retry timeout until a new login can be made (without disabling the ip)
retrytimeout = 5000

-- how long the player need to wait until the ip is allowed again
logintimeout = 60 * 1000

-- allow clones (multiple logins of the same char)
-- options: 0 (no), 1 (yes)
allowclones = 0

-- only one player online per account
-- options: 0 (no), 1 (yes)
checkaccounts = 0

-- players with that and lower lvl's cant be attacked 
protectLevel = 20

-- color o exp above player
expcolor = 35

corpsemuted = 15

houseprice = 200
houselevel = 20
capsystem = "no"
maxDeathEntries = 10
banunjust = 8
redunjust = 3
bantime = 24*7
fragtime = 24
whitetime = 15

-- animated spells above player (yes/no)
animatedspells = "no"

-- max number of players allowed
maxplayers = "35"

-- save client debug assertion reports
-- options: 0 (no), 1 (yes)
saveclientdebug = 0

-- Set the max query interval for retrieving status information
-- default: 5 minutes / IP
-- set to 0 to disable
statustimeout = 5 * 60 * 1000

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

