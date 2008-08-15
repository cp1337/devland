//////////////////////////////////////////////////////////////////////
// OpenTibia - an opensource roleplaying game
//////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software Foundation,
// Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
//
//You need also accept Additional conditions.
//Additional conditions:
//1. Software's author gives no guarantee and takes no responsibility for working and any possible uncommon effects or/and faults caused.
//2. Any individuals using, modyfing and sharing this software cannot remove any information like authorship, software's sources, properties of DevLand.exe file and information attached in programe icon i.e. software's title.
//
//Terms and conditions apply.
//////////////////////////////////////////////////////////////////////


#ifndef __OTSERV_COMMANDS_H__
#define __OTSERV_COMMANDS_H__

#include <string>
#include <map>
#include "creature.h"

class Game;
struct Command;
struct s_defcommands;

class Commands{
public:
	Commands():game(NULL),loaded(false){};
	Commands(Game* igame);

	bool loadXml(const std::string& _datadir);	
	bool isLoaded(){return loaded;}
	bool reload();

	bool exeCommand(Creature* creature, const std::string& cmd);

	static ReturnValue placeSummon(Creature* creature, const std::string& name);
	
protected:
	Game* game;
	bool loaded;
	std::string datadir;

	//commands
	bool placeNpc(Creature* creature, const std::string& cmd, const std::string& param);
	bool placeMonster(Creature* creature, const std::string& cmd, const std::string& param);
	bool placeSummon(Creature* creature, const std::string& cmd, const std::string& param);
	bool broadcastMessage(Creature* creature, const std::string& cmd, const std::string& param);
	bool banPlayer(Creature* creature, const std::string& cmd, const std::string& param);
	bool teleportMasterPos(Creature* creature, const std::string& cmd, const std::string& param);
	bool teleportHere(Creature* creature, const std::string& cmd, const std::string& param);
	bool teleportToTown(Creature* creature, const std::string& cmd, const std::string& param);
	bool teleportTo(Creature* creature, const std::string& cmd, const std::string& param);
	bool createItemById(Creature* creature, const std::string& cmd, const std::string& param);
	bool createItemByName(Creature* creature, const std::string& cmd, const std::string& param);
	bool subtractMoney(Creature* creature, const std::string& cmd, const std::string& param);
	bool reloadInfo(Creature* creature, const std::string& cmd, const std::string& param);
	bool testCommand(Creature* creature, const std::string& cmd, const std::string& param);
	bool getInfo(Creature* creature, const std::string& cmd, const std::string& param);
	bool closeServer(Creature* creature, const std::string& cmd, const std::string& param);
	bool openServer(Creature* creature, const std::string& cmd, const std::string& param);
	bool onlineList(Creature* creature, const std::string& cmd, const std::string& param);
	bool teleportNTiles(Creature* creature, const std::string& cmd, const std::string& param);
	bool kickPlayer(Creature* creature, const std::string& cmd, const std::string& param);
	//bool exivaPlayer(Creature* creature, const std::string& cmd, const std::string& param);
	bool setHouseOwner(Creature* creature, const std::string& cmd, const std::string& param);
	bool sellHouse(Creature* creature, const std::string& cmd, const std::string& param);
	bool getHouse(Creature* creature, const std::string& cmd, const std::string& param);
	bool bansManager(Creature* creature, const std::string& cmd, const std::string& param);
	bool serverInfo(Creature* creature, const std::string& cmd, const std::string& param);
	bool forceRaid(Creature* creature, const std::string& cmd, const std::string& param);

	#ifdef __SERVER_SAVE__
	bool savePlayers(Creature* creature, const std::string& cmd, const std::string& param);
	bool saveMap(Creature* creature, const std::string& cmd, const std::string& param);
	bool saveBans(Creature* creature, const std::string& cmd, const std::string& param);
	#endif
	#ifdef __SILV_MC_CHECK__
	bool mcCheck(Creature* creature, const std::string& cmd, const std::string& param);
	#endif
	#ifdef __PB_BUY_HOUSE__
	bool buyHouse(Creature* creature, const std::string& cmd, const std::string& param);
	#endif
    #ifdef __COMMANDS__
	bool setMaxPlayers(Creature* creature, const std::string &cmd, const std::string &param);
	bool whoIsOnline(Creature* creature, const std::string &cmd, const std::string &param);
	bool showFrags(Creature* creature, const std::string &cmd, const std::string &param);
    #endif
   	#ifdef __XID_SEPERATE_ADDONS__
    bool addAddon(Creature* creature, const std::string& cmd, const std::string& param);
    #endif
    
    #ifdef __PB_GMINVISIBLE__
	bool setGmInvisible(Creature* creature, const std::string& cmd, const std::string& param);
    #endif
    
	//table of commands
	static s_defcommands defined_commands[];
	
	typedef std::map<std::string,Command*> CommandMap;
	CommandMap commandMap;
};

typedef  bool (Commands::*CommandFunc)(Creature*,const std::string&,const std::string&);

struct Command{
	CommandFunc f;
	int32_t accesslevel;
	bool loaded;
};

struct s_defcommands{
	const char *name;
	CommandFunc f;
};

#endif
