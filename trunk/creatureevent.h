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

#ifndef __OTSERV_CREATUREEVENT_H__
#define __OTSERV_CREATUREEVENT_H__

#include "luascript.h"
#include "baseevents.h"

#ifdef __ON_ADVANCE__
#include "enums.h"
#endif

enum CreatureEventType_t{
	CREATURE_EVENT_NONE,
	CREATURE_EVENT_LOGIN,
	CREATURE_EVENT_LOGOUT,
	CREATURE_EVENT_DIE,
	#ifdef __ON_PLAYER_DIE_DZOJO__
    CREATURE_EVENT_DIE_PLAYER,
    #endif
	CREATURE_EVENT_KILL
	#ifdef __ON_ADVANCE__
	, CREATURE_EVENT_ADVANCE
    #endif
};

class CreatureEvent;

class CreatureEvents : public BaseEvents
{
public:
	CreatureEvents();
	virtual ~CreatureEvents();

	// global events
	uint32_t playerLogIn(Player* player);
	uint32_t playerLogOut(Player* player);
	#ifdef __ON_PLAYER_DIE_DZOJO__	
	uint32_t playerDie(Player* player, Item* corpse);
    #endif	
    
    #ifdef __ON_ADVANCE__
	uint32_t playerAdvance(Player* player, AdvanceType_t stat, uint32_t fromLv, uint32_t toLv);
    #endif

	CreatureEvent* getEventByName(const std::string& name, bool forceLoaded = true);

protected:

	virtual LuaScriptInterface& getScriptInterface();
	virtual std::string getScriptBaseName();
	virtual Event* getEvent(const std::string& nodeName);
	virtual bool registerEvent(Event* event, xmlNodePtr p);
	virtual void clear();

	//global events
	CreatureEvent* m_logInEvent;
	CreatureEvent* m_logOutEvent;
	
	#ifdef __ON_PLAYER_DIE_DZOJO__
    CreatureEvent* m_playerDieEvent;
    #endif	
    #ifdef __ON_ADVANCE__
	CreatureEvent* m_onAdvance;
    #endif

	//creature events
	typedef std::map<std::string, CreatureEvent*> CreatureEventList;
	CreatureEventList m_creatureEvents;

	LuaScriptInterface m_scriptInterface;
};

class CreatureEvent : public Event
{
public:
	CreatureEvent(LuaScriptInterface* _interface);
	virtual ~CreatureEvent();

	virtual bool configureEvent(xmlNodePtr p);

	CreatureEventType_t getEventType() const { return m_type; }
	const std::string& getName() const { return m_eventName; }
	bool isLoaded() const { return m_isLoaded; }

	void clearEvent();
	void copyEvent(CreatureEvent* creatureEvent);

	//scripting
	uint32_t executeOnLogin(Player* player);
	uint32_t executeOnLogout(Player* player);
	uint32_t executeOnDie(Creature* creature, Item* corpse);
	#ifdef __ON_PLAYER_DIE_DZOJO__	
	uint32_t executeOnDiePlayer(Player* player, Item* corpse);
    #endif
	uint32_t executeOnKill(Creature* creature, Creature* target);
	#ifdef __ON_ADVANCE__
	uint32_t executeOnAdvance(Player* player, AdvanceType_t stat, uint32_t fromLv, uint32_t toLv);
    #endif
	//

protected:
	virtual std::string getScriptEventName();

	std::string m_eventName;
	CreatureEventType_t m_type;
	bool m_isLoaded;
};


#endif // __OTSERV_CREATUREEVENT_H__
