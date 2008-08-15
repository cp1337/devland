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
#include "otpch.h"

#include <string>
#include <iostream>
#include <sstream>

#include "luascript.h"
#include "player.h"
#include "item.h"
#include "game.h"
#include "house.h"
#include "housetile.h"
#include "status.h"
#include "combat.h"
#include "spells.h"
#include "condition.h"
#include "monsters.h"
#include "baseevents.h"
#include "town.h"
#include "ioplayer.h"
#include "configmanager.h"
#include "teleport.h"
#include "ioaccount.h"

extern Game g_game;
extern Monsters g_monsters;
extern ConfigManager g_config;
extern Spells* g_spells;

enum{
	EVENT_ID_LOADING = 1,
	EVENT_ID_USER = 1000,
};

ScriptEnviroment::ThingMap ScriptEnviroment::m_globalMap;
ScriptEnviroment::AreaMap ScriptEnviroment::m_areaMap;
uint32_t ScriptEnviroment::m_lastAreaId = 0;
ScriptEnviroment::CombatMap ScriptEnviroment::m_combatMap;
uint32_t ScriptEnviroment::m_lastCombatId = 0;
ScriptEnviroment::ConditionMap ScriptEnviroment::m_conditionMap;
uint32_t ScriptEnviroment::m_lastConditionId = 0;
ScriptEnviroment::StorageMap ScriptEnviroment::m_globalStorageMap;

ScriptEnviroment::ScriptEnviroment()
{
	resetEnv();
	m_lastUID = 70000;
}

ScriptEnviroment::~ScriptEnviroment()
{
	resetEnv();

	for(CombatMap::iterator it = m_combatMap.begin(); it != m_combatMap.end(); ++it){
		delete it->second;
	}

	m_combatMap.clear();

	for(AreaMap::iterator it = m_areaMap.begin(); it != m_areaMap.end(); ++it){
		delete it->second;
	}

	m_areaMap.clear();
}

void ScriptEnviroment::resetEnv()
{
	m_scriptId = 0;
	m_callbackId = 0;
	m_timerEvent = false;
	m_interface = NULL;
	m_localMap.clear();

	for(std::list<Item*>::iterator it = m_tempItems.begin(); it != m_tempItems.end(); ++it){
		if((*it)->getParent() == VirtualCylinder::virtualCylinder){
			delete *it;
		}
	}
	m_tempItems.clear();

	m_realPos.x = 0;
	m_realPos.y = 0;
	m_realPos.z = 0;
}

bool ScriptEnviroment::saveGameState()
{
	Database* db = Database::instance();
	DBQuery query;

	if(!db->executeQuery("DELETE FROM `global_storage`")){
		return false;
	}

	DBInsert stmt(db);
	stmt.setQuery("INSERT INTO `global_storage` (`key`, `value`) VALUES ");

	for(StorageMap::const_iterator it = m_globalStorageMap.begin(); it != m_globalStorageMap.end(); ++it){
		query << it->first << ", " << it->second;

		if(!stmt.addRow(query)){
			return false;
		}
	}

	if(!stmt.execute()){
		return false;
	}

	return true;
}

bool ScriptEnviroment::loadGameState()
{
	Database* db = Database::instance();
	DBResult* result;
	DBQuery query;

	if(!(result = db->storeQuery("SELECT COUNT(*) AS `count` FROM `global_storage`"))){
		return false;
	}

	uint32_t count = result->getDataInt("count");
	db->freeResult(result);
	if(count == 0){
		return true;
	}

	if(!(result = db->storeQuery("SELECT * FROM `global_storage`"))){
		return false;
	}

	do{
		int32_t key = result->getDataInt("key");
		int32_t value = result->getDataInt("value");

		m_globalStorageMap[key] = value;
	}while(result->next());

	db->freeResult(result);
	return true;
}

bool ScriptEnviroment::setCallbackId(int32_t callbackId, LuaScriptInterface* scriptInterface)
{
	if(m_callbackId == 0){
		m_callbackId = callbackId;
		m_interface = scriptInterface;
		return true;
	}
	else{
		//nested callbacks are not allowed
		if(m_interface){
			m_interface->reportError(__FUNCTION__, "Nested callbacks!");
		}
		return false;
	}
}

void ScriptEnviroment::getEventInfo(int32_t& scriptId, std::string& desc, LuaScriptInterface*& scriptInterface, int32_t& callbackId, bool& timerEvent)
{
	scriptId = m_scriptId;
	desc = m_eventdesc;
	scriptInterface = m_interface;
	callbackId = m_callbackId;
	timerEvent = m_timerEvent;
}

void ScriptEnviroment::addUniqueThing(Thing* thing)
{
	Item* item = thing->getItem();
	if(item && item->getUniqueId() != 0 ){
		int32_t uid = item->getUniqueId();

		Thing* tmp = m_globalMap[uid];
		if(!tmp){
			m_globalMap[uid] = thing;
		}
		else{
			std::cout << "Duplicate uniqueId " <<  uid << std::endl;
		}
	}
}

void ScriptEnviroment::removeUniqueThing(Thing* thing)
{
	Item* item = thing->getItem();
	if(item && item->getUniqueId() != 0 ){
		int32_t uid = item->getUniqueId();
		ThingMap::iterator it = m_globalMap.find(uid);
		if(it != m_globalMap.end()){
			m_globalMap.erase(it);
		}
	}
}

uint32_t ScriptEnviroment::addThing(Thing* thing)
{
	if(thing){
		ThingMap::iterator it;
		for(it = m_localMap.begin(); it != m_localMap.end(); ++it){
			if(it->second == thing){
				return it->first;
			}
		}

		uint32_t newUid;
		if(Creature* creature = thing->getCreature()){
			newUid = creature->getID();
		}
		else{
			if(Item* item = thing->getItem()){
				uint32_t uid = item->getUniqueId();
				if(uid && item->getTile() == item->getParent()){
					m_localMap[uid] = thing;
					return uid;
				}
			}

			++m_lastUID;
			if(m_lastUID > 0xFFFFFF)
				m_lastUID = 70000;

			while(m_localMap[m_lastUID]){
				++m_lastUID;
			}
			newUid = m_lastUID;
		}

		m_localMap[newUid] = thing;
		return newUid;
	}
	else{
		return 0;
	}
}

void ScriptEnviroment::insertThing(uint32_t uid, Thing* thing)
{
	if(!m_localMap[uid]){
		m_localMap[uid] = thing;
	}
	else{
		std::cout << std::endl << "Lua Script Error: Thing uid already taken.";
	}
}

Thing* ScriptEnviroment::getThingByUID(uint32_t uid)
{
	Thing* tmp = m_localMap[uid];
	if(tmp && !tmp->isRemoved()){
		return tmp;
	}
	tmp = m_globalMap[uid];
	if(tmp && !tmp->isRemoved()){
		return tmp;
	}
	if(uid >= 0x10000000){ //is a creature id
		tmp = g_game.getCreatureByID(uid);
		if(tmp && !tmp->isRemoved()){
			m_localMap[uid] = tmp;
			return tmp;
		}
	}
	return NULL;
}

Item* ScriptEnviroment::getItemByUID(uint32_t uid)
{
	Thing* tmp = getThingByUID(uid);
	if(tmp){
		if(Item* item = tmp->getItem())
			return item;
	}
	return NULL;
}

Container* ScriptEnviroment::getContainerByUID(uint32_t uid)
{
	Item* tmp = getItemByUID(uid);
	if(tmp){
		if(Container* container = tmp->getContainer())
			return container;
	}
	return NULL;
}

Creature* ScriptEnviroment::getCreatureByUID(uint32_t uid)
{
	Thing* tmp = getThingByUID(uid);
	if(tmp){
		if(Creature* creature = tmp->getCreature())
			return creature;
	}
	return NULL;
}

Player* ScriptEnviroment::getPlayerByUID(uint32_t uid)
{
	Thing* tmp = getThingByUID(uid);
	if(tmp){
		if(Creature* creature = tmp->getCreature())
			if(Player* player = creature->getPlayer())
				return player;
	}
	return NULL;
}

void ScriptEnviroment::removeItemByUID(uint32_t uid)
{
	ThingMap::iterator it;
	it = m_localMap.find(uid);
	if(it != m_localMap.end()){
		m_localMap.erase(it);
	}

	it = m_globalMap.find(uid);
	if(it != m_globalMap.end()){
		m_globalMap.erase(it);
	}
}

uint32_t ScriptEnviroment::addCombatArea(AreaCombat* area)
{
	uint32_t newAreaId = m_lastAreaId + 1;
	m_areaMap[newAreaId] = area;

	m_lastAreaId++;
	return newAreaId;
}

AreaCombat* ScriptEnviroment::getCombatArea(uint32_t areaId)
{
	AreaMap::const_iterator it = m_areaMap.find(areaId);
	if(it != m_areaMap.end()){
		return it->second;
	}

	return NULL;
}

uint32_t ScriptEnviroment::addCombatObject(Combat* combat)
{
	uint32_t newCombatId = m_lastCombatId + 1;
	m_combatMap[newCombatId] = combat;

	m_lastCombatId++;
	return newCombatId;
}


Combat* ScriptEnviroment::getCombatObject(uint32_t combatId)
{
	CombatMap::iterator it = m_combatMap.find(combatId);
	if(it != m_combatMap.end()){
		return it->second;
	}

	return NULL;
}

uint32_t ScriptEnviroment::addConditionObject(Condition* condition)
{
	uint32_t newConditionId = m_lastConditionId + 1;
	m_conditionMap[newConditionId] = condition;

	m_lastConditionId++;
	return m_lastConditionId;
}

Condition* ScriptEnviroment::getConditionObject(uint32_t conditionId)
{
	ConditionMap::iterator it = m_conditionMap.find(conditionId);
	if(it != m_conditionMap.end()){
		return it->second;
	}

	return NULL;
}

void ScriptEnviroment::addTempItem(Item* item)
{
	m_tempItems.push_back(item);
}

void ScriptEnviroment::addGlobalStorageValue(const uint32_t key, const int32_t value)
{
	m_globalStorageMap[key] = value;
}

bool ScriptEnviroment::getGlobalStorageValue(const uint32_t key, int32_t& value) const
{
	StorageMap::const_iterator it;
	it = m_globalStorageMap.find(key);
	if(it != m_globalStorageMap.end()){
		value = it->second;
		return true;
	}
	else{
		value = 0;
		return false;
	}
}

std::string LuaScriptInterface::getErrorDesc(ErrorCode_t code){
	switch(code){
	case LUA_ERROR_PLAYER_NOT_FOUND:
		return "Player not found";
		break;
	case LUA_ERROR_CREATURE_NOT_FOUND:
		return "Creature not found";
		break;
	case LUA_ERROR_ITEM_NOT_FOUND:
		return "Item not found";
		break;
	case LUA_ERROR_THING_NOT_FOUND:
		return "Thing not found";
		break;
	case LUA_ERROR_TILE_NOT_FOUND:
		return "Tile not found";
		break;
	case LUA_ERROR_HOUSE_NOT_FOUND:
		return "House not found";
		break;
	case LUA_ERROR_COMBAT_NOT_FOUND:
		return "Combat not found";
		break;
	case LUA_ERROR_CONDITION_NOT_FOUND:
		return "Condition not found";
		break;
	case LUA_ERROR_AREA_NOT_FOUND:
		return "Area not found";
		break;
	case LUA_ERROR_CONTAINER_NOT_FOUND:
		return "Container not found";
		break;
	case LUA_ERROR_VARIANT_NOT_FOUND:
		return "Variant not found";
	case LUA_ERROR_VARIANT_UNKNOWN:
		return "Unknown variant type";
		break;
	case LUA_ERROR_SPELL_NOT_FOUND:
		return "Spell not found";
		break;
	default:
		return "Wrong error code!";
		break;
	};
}

ScriptEnviroment LuaScriptInterface::m_scriptEnv[16];
int32_t LuaScriptInterface::m_scriptEnvIndex = -1;

LuaScriptInterface::LuaScriptInterface(std::string interfaceName)
{
	m_luaState = NULL;
	m_interfaceName = interfaceName;
	m_lastEventTimerId = 1000;
}

LuaScriptInterface::~LuaScriptInterface()
{
	closeState();
}

bool LuaScriptInterface::reInitState()
{
	closeState();
	return initState();
}

void LuaScriptInterface::dumpLuaStack()
{
	int a = lua_gettop(m_luaState);
	std::cout <<  "stack size: " << a << std::endl;
	for(int i = 1; i <= a ; ++i){
		std::cout << lua_typename(m_luaState, lua_type(m_luaState,-i)) << " " << lua_topointer(m_luaState, -i) << std::endl;
	}
}

int32_t LuaScriptInterface::loadFile(const std::string& file, Npc* npc /* = NULL*/)
{
	//loads file as a chunk at stack top
	int ret = luaL_loadfile(m_luaState, file.c_str());
	if(ret != 0){
		m_lastLuaError = popString(m_luaState);
		return -1;
	}
	//check that it is loaded as a function
	if(lua_isfunction(m_luaState, -1) == 0){
		return -1;
	}

	m_loadingFile = file;
	this->reserveScriptEnv();
	ScriptEnviroment* env = this->getScriptEnv();
	env->setScriptId(EVENT_ID_LOADING, this);
	env->setNpc(npc);

	//execute it
	ret = lua_pcall(m_luaState, 0, 0, 0);
	if(ret != 0){
		reportError(NULL, std::string(popString(m_luaState)));
		this->releaseScriptEnv();
		return -1;
	}

	this->releaseScriptEnv();
	return 0;
}

int32_t LuaScriptInterface::getEvent(const std::string& eventName)
{
	//get our events table
	lua_getfield(m_luaState, LUA_REGISTRYINDEX, "EVENTS");
	if(lua_istable(m_luaState, -1) == 0){
		lua_pop(m_luaState, 1);
		return -1;
	}
	//get current event function pointer
	lua_getglobal(m_luaState, eventName.c_str());
	if(lua_isfunction(m_luaState, -1) == 0){
		lua_pop(m_luaState, 1);
		return -1;
	}
	//save in our events table
	lua_pushnumber(m_luaState, m_runningEventId);
	lua_pushvalue(m_luaState, -2);
	lua_rawset(m_luaState, -4);
	lua_pop(m_luaState, 2);
	//reset global value of this event
	lua_pushnil(m_luaState);
	lua_setglobal(m_luaState, eventName.c_str());

	m_cacheFiles[m_runningEventId] = m_loadingFile + ":" + eventName;
	++m_runningEventId;
	return m_runningEventId - 1;
}

const std::string& LuaScriptInterface::getFileById(int32_t scriptId)
{
	const static std::string unk = "(Unknown scriptfile)";
	if(scriptId != EVENT_ID_LOADING){
		ScriptsCache::iterator it = m_cacheFiles.find(scriptId);
		if(it != m_cacheFiles.end()){
			return it->second;
		}
		else{
			return unk;
		}
	}
	else{
		return m_loadingFile;
	}
}

void LuaScriptInterface::reportError(const char* function, const std::string& error_desc)
{
	ScriptEnviroment* env = getScriptEnv();
	int32_t scriptId;
	int32_t callbackId;
	bool timerEvent;
	std::string event_desc;
	LuaScriptInterface* scriptInterface;
	env->getEventInfo(scriptId, event_desc, scriptInterface, callbackId, timerEvent);

	std::cout << std::endl << "Lua Script Error: ";
	if(scriptInterface){
		std::cout << "[" << scriptInterface->getInterfaceName() << "] " << std::endl;
		if(timerEvent){
			std::cout << "in a timer event called from: " << std::endl;
		}
		if(callbackId){
			std::cout << "in callback: " << scriptInterface->getFileById(callbackId) << std::endl;
		}
		std::cout << scriptInterface->getFileById(scriptId) << std::endl;
	}
	std::cout << event_desc << std::endl;
	if(function)
		std::cout << function << "(). ";
	std::cout << error_desc << std::endl;
}

bool LuaScriptInterface::pushFunction(int32_t functionId)
{
	lua_getfield(m_luaState, LUA_REGISTRYINDEX, "EVENTS");
	if(lua_istable(m_luaState, -1) != 0){
		lua_pushnumber(m_luaState, functionId);
		lua_rawget(m_luaState, -2);
		lua_remove(m_luaState, -2);
		if(lua_isfunction(m_luaState, -1) != 0){
			return true;
		}
	}
	return false;
}

bool LuaScriptInterface::initState()
{
	m_luaState = luaL_newstate();
	if(!m_luaState){
		return false;
	}

#ifndef __USE_LUALIBRARIES__
	//Here you load only the "safe" libraries
	luaopen_base(m_luaState);
	luaopen_table(m_luaState);
	luaopen_os(m_luaState);
	luaopen_string(m_luaState);
	luaopen_math(m_luaState);
#else
	//And here you load both "safe" and "unsafe" libraries
	luaL_openlibs(m_luaState);
#endif

	std::string datadir = g_config.getString(ConfigManager::DATA_DIRECTORY);

    registerFunctions();

	if(loadFile(std::string(datadir + "global.lua")) == -1){
		std::cout << "Warning: [LuaScriptInterface::initState] Can not load " << datadir << "global.lua." << std::endl;
	}

	lua_newtable(m_luaState);
	lua_setfield(m_luaState, LUA_REGISTRYINDEX, "EVENTS");

	m_runningEventId = EVENT_ID_USER;
	return true;
}

bool LuaScriptInterface::closeState()
{
	if(m_luaState){
		m_cacheFiles.clear();

		LuaTimerEvents::iterator it;
		for(it = m_timerEvents.begin(); it != m_timerEvents.end(); ++it){
			for(std::list<int>::iterator lt = it->second.parameters.begin(); lt != it->second.parameters.end(); ++lt){
				luaL_unref(m_luaState, LUA_REGISTRYINDEX, *lt);
			}
			it->second.parameters.clear();
			luaL_unref(m_luaState, LUA_REGISTRYINDEX, it->second.function);
		}
		m_timerEvents.clear();

		lua_close(m_luaState);
	}

	return true;
}

void LuaScriptInterface::executeTimerEvent(uint32_t eventIndex)
{
	LuaTimerEvents::iterator it = m_timerEvents.find(eventIndex);
	if(it != m_timerEvents.end()){
		//push function
		lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, it->second.function);

		//push parameters
		for(std::list<int>::reverse_iterator rt = it->second.parameters.rbegin();
			rt != it->second.parameters.rend(); ++rt){
			lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, *rt);
		}

		//call the function
		if(reserveScriptEnv()){
			ScriptEnviroment* env = getScriptEnv();
			env->setTimerEvent();
			env->setScriptId(it->second.scriptId, this);
			callFunction(it->second.parameters.size());
			releaseScriptEnv();
		}
		else{
			std::cout << "[Error] Call stack overflow. LuaScriptInterface::executeTimerEvent" << std::endl;
		}

		//free resources
		for(std::list<int>::iterator lt = it->second.parameters.begin(); lt != it->second.parameters.end(); ++lt){
			luaL_unref(m_luaState, LUA_REGISTRYINDEX, *lt);
		}
		it->second.parameters.clear();
		luaL_unref(m_luaState, LUA_REGISTRYINDEX, it->second.function);
		m_timerEvents.erase(it);
	}
}

int32_t LuaScriptInterface::callFunction(uint32_t nParams)
{
	int32_t result = LUA_NO_ERROR;

	int size0 = lua_gettop(m_luaState);
	if(lua_pcall(m_luaState, nParams, 1, 0) != 0){
		LuaScriptInterface::reportError(NULL, std::string(LuaScriptInterface::popString(m_luaState)));
		result = LUA_ERROR;
	}
	else{
		result = (int32_t)LuaScriptInterface::popNumber(m_luaState);
	}

	if((lua_gettop(m_luaState) + (int)nParams  + 1) != size0){
		LuaScriptInterface::reportError(NULL, "Stack size changed!");
	}

	return result;
}

void LuaScriptInterface::pushVariant(lua_State *L, const LuaVariant& var)
{
	lua_newtable(L);
	setField(L, "type", var.type);

	switch(var.type){
		case VARIANT_NUMBER: setField(L, "number", var.number); break;
		case VARIANT_STRING: setField(L, "string", var.text); break;
		case VARIANT_TARGETPOSITION:
		case VARIANT_POSITION:
		{
				lua_pushstring(L, "pos");
				pushPosition(L, var.pos);
				lua_settable(L, -3);
				break;
		}
		case VARIANT_NONE:
			break;
 	}
}

void LuaScriptInterface::pushThing(lua_State *L, Thing* thing, uint32_t thingid)
{
	lua_newtable(L);
	if(thing && thing->getItem()){
		const Item* item = thing->getItem();
		setField(L, "uid", thingid);
		setField(L, "itemid", item->getID());

		if(item->hasSubType())
			setField(L, "type", item->getSubType());
		else
			setField(L, "type", 0);

		setField(L, "actionid", item->getActionId());
	}
	else if(thing && thing->getCreature()){
		const Creature* creature = thing->getCreature();
		setField(L, "uid", thingid);
		setField(L, "itemid", 1);
		char type;
		if(creature->getPlayer()){
			type = 1;
		}
		else if(creature->getMonster()){
			type = 2;
		}
		else{//npc
			type = 3;
		}
		setField(L, "type", type);
		setField(L, "actionid", 0);
	}
	else{
		setField(L, "uid", 0);
		setField(L, "itemid", 0);
		setField(L, "type", 0);
		setField(L, "actionid", 0);
	}
}

void LuaScriptInterface::pushPosition(lua_State *L, const PositionEx& position)
{
	lua_newtable(L);
	setField(L, "z", position.z);
	setField(L, "y", position.y);
	setField(L, "x", position.x);
	setField(L, "stackpos", position.stackpos);
}

void LuaScriptInterface::pushPosition(lua_State *L, const Position& position, uint32_t stackpos)
{
	lua_newtable(L);
	setField(L, "z", position.z);
	setField(L, "y", position.y);
	setField(L, "x", position.x);
	setField(L, "stackpos", stackpos);
}

void LuaScriptInterface::pushCallback(lua_State *L, int32_t callback) 
{ 
    lua_rawgeti(L, LUA_REGISTRYINDEX, callback); 
} 


LuaVariant LuaScriptInterface::popVariant(lua_State *L)
{
	uint32_t type = getField(L, "type");

	LuaVariant var;
	var.type = (LuaVariantType_t)type;

	switch(type){
		case VARIANT_NUMBER:
		{
			var.number = getField(L, "number");
			break;
		}

		case VARIANT_STRING:
		{
			var.text = getField(L, "string");
			break;
		}

		case VARIANT_POSITION:
		case VARIANT_TARGETPOSITION:
		{
			lua_pushstring(L, "pos");
			lua_gettable(L, -2);
			popPosition(L, var.pos);
			break;
		}

		default:
		{
			var.type = VARIANT_NONE;
			break;
		}
	}

	lua_pop(L, 1); //table

	return var;
}

void LuaScriptInterface::popPosition(lua_State *L, PositionEx& position)
{
	position.z = getField(L, "z");
	position.y = getField(L, "y");
	position.x = getField(L, "x");
	position.stackpos = getField(L, "stackpos");

	lua_pop(L, 1); //table
}

void LuaScriptInterface::popPosition(lua_State *L, Position& position, uint32_t& stackpos)
{
	position.z = getField(L, "z");
	position.y = getField(L, "y");
	position.x = getField(L, "x");
	stackpos = getField(L, "stackpos");
	lua_pop(L, 1); //table
}

uint32_t LuaScriptInterface::popNumber(lua_State *L)
{
	lua_pop(L,1);
	return (uint32_t)lua_tonumber(L, 0);
}

double LuaScriptInterface::popFloatNumber(lua_State *L)
{
	lua_pop(L,1);
	return (double)lua_tonumber(L, 0);
}

const char* LuaScriptInterface::popString(lua_State *L)
{
	lua_pop(L,1);
	return lua_tostring(L, 0);
}

int32_t LuaScriptInterface::popCallback(lua_State *L) 
{ 
     return luaL_ref(L, LUA_REGISTRYINDEX); 
} 

int32_t LuaScriptInterface::getField(lua_State *L, const char *key)
{
	int32_t result;
	lua_pushstring(L, key);
	lua_gettable(L, -2);  // get table[key]
	result = (int32_t)lua_tonumber(L, -1);
	lua_pop(L, 1);  // remove number and key
	return result;
}

void LuaScriptInterface::setField(lua_State *L, const char* index, uint32_t val)
{
	lua_pushstring(L, index);
	lua_pushnumber(L, (double)val);
	lua_settable(L, -3);
}

void LuaScriptInterface::setField(lua_State *L, const char* index, const std::string& val)
{
	lua_pushstring(L, index);
	lua_pushstring(L, val.c_str());
	lua_settable(L, -3);
}

void LuaScriptInterface::registerFunctions()
{
	//lua_register(L, "name", C_function);

	//getPlayerFood(cid)
	lua_register(m_luaState, "getPlayerFood", LuaScriptInterface::luaGetPlayerFood);

	//getPlayerHealth(cid)
	lua_register(m_luaState, "getPlayerHealth", LuaScriptInterface::luaGetPlayerHealth);

	//getPlayerMaxHealth(cid)
	lua_register(m_luaState, "getPlayerMaxHealth", LuaScriptInterface::luaGetPlayerMaxHealth);

	//getPlayerMana(cid)
	lua_register(m_luaState, "getPlayerMana", LuaScriptInterface::luaGetPlayerMana);

	//getPlayerMaxMana(cid)
	lua_register(m_luaState, "getPlayerMaxMana", LuaScriptInterface::luaGetPlayerMaxMana);

	//getPlayerLevel(cid)
	lua_register(m_luaState, "getPlayerLevel", LuaScriptInterface::luaGetPlayerLevel);

	//getPlayerMagLevel(cid)
	lua_register(m_luaState, "getPlayerMagLevel", LuaScriptInterface::luaGetPlayerMagLevel);

	//getPlayerName(cid)
	lua_register(m_luaState, "getPlayerName", LuaScriptInterface::luaGetPlayerName);

	//getPlayerAccess(cid)
	lua_register(m_luaState, "getPlayerAccess", LuaScriptInterface::luaGetPlayerAccess);

	//getPlayerPosition(cid)
	lua_register(m_luaState, "getPlayerPosition", LuaScriptInterface::luaGetPlayerPosition);

	//getPlayerSkill(cid, skillid)
	lua_register(m_luaState, "getPlayerSkill", LuaScriptInterface::luaGetPlayerSkill);

	//getPlayerMasterPos(cid)
	lua_register(m_luaState, "getPlayerMasterPos", LuaScriptInterface::luaGetPlayerMasterPos);

	//getPlayerTown(cid)
	lua_register(m_luaState, "getPlayerTown", LuaScriptInterface::luaGetPlayerTown);

	//getPlayerVocation(cid)
	lua_register(m_luaState, "getPlayerVocation", LuaScriptInterface::luaGetPlayerVocation);

	//getPlayerItemCount(cid, itemid)
	lua_register(m_luaState, "getPlayerItemCount", LuaScriptInterface::luaGetPlayerItemCount);

	//getPlayerSoul(cid)
	lua_register(m_luaState, "getPlayerSoul", LuaScriptInterface::luaGetPlayerSoul);

	//getPlayerFreeCap(cid)
	lua_register(m_luaState, "getPlayerFreeCap", LuaScriptInterface::luaGetPlayerFreeCap);

	//getPlayerLight(cid)
	lua_register(m_luaState, "getPlayerLight", LuaScriptInterface::luaGetPlayerLight);

	//getPlayerSlotItem(cid, slot)
	lua_register(m_luaState, "getPlayerSlotItem", LuaScriptInterface::luaGetPlayerSlotItem);

	//getPlayerItemById(cid, deepSearch, itemId, <optional> subType)
	lua_register(m_luaState, "getPlayerItemById", LuaScriptInterface::luaGetPlayerItemById);

	//getPlayerDepotItems(cid, depotid)
	lua_register(m_luaState, "getPlayerDepotItems", LuaScriptInterface::luaGetPlayerDepotItems);

	//getPlayerGuildId(cid)
	lua_register(m_luaState, "getPlayerGuildId", LuaScriptInterface::luaGetPlayerGuildId);

	//getPlayerGuildName(cid)
	lua_register(m_luaState, "getPlayerGuildName", LuaScriptInterface::luaGetPlayerGuildName);

	//getPlayerGuildRank(cid)
	lua_register(m_luaState, "getPlayerGuildRank", LuaScriptInterface::luaGetPlayerGuildRank);

	//getPlayerGuildNick(cid)
	lua_register(m_luaState, "getPlayerGuildNick", LuaScriptInterface::luaGetPlayerGuildNick);

	//getPlayerSex(cid)
	lua_register(m_luaState, "getPlayerSex", LuaScriptInterface::luaGetPlayerSex);

	//getPlayerLookDir(cid)
	lua_register(m_luaState, "getPlayerLookDir", LuaScriptInterface::luaGetPlayerLookDir);

#ifdef __GET_OUTFIT__
	//getPlayerLookType(cid) 
    lua_register(m_luaState, "getPlayerLookType", LuaScriptInterface::luaGetPlayerLookType); 
   	//getPlayerLookHead(cid) 
    lua_register(m_luaState, "getPlayerLookHead", LuaScriptInterface::luaGetPlayerLookHead); 
   	//getPlayerLookBody(cid) 
    lua_register(m_luaState, "getPlayerLookBody", LuaScriptInterface::luaGetPlayerLookBody); 
   	//getPlayerLookLegs(cid) 
    lua_register(m_luaState, "getPlayerLookLegs", LuaScriptInterface::luaGetPlayerLookLegs); 
   	//getPlayerLookFeet(cid) 
    lua_register(m_luaState, "getPlayerLookFeet", LuaScriptInterface::luaGetPlayerLookFeet); 
   	//getPlayerLookAddons(cid) 
    lua_register(m_luaState, "getPlayerLookAddons", LuaScriptInterface::luaGetPlayerLookAddons); 
#endif

	//getPlayerGUID(cid)
	lua_register(m_luaState, "getPlayerGUID", LuaScriptInterface::luaGetPlayerGUID);

	//getPlayerFlagValue(cid, flag)
	lua_register(m_luaState, "getPlayerFlagValue", LuaScriptInterface::luaGetPlayerFlagValue);

	//getPlayerLossPercent(cid, lossType)
	lua_register(m_luaState, "getPlayerLossPercent", LuaScriptInterface::luaGetPlayerLossPercent);

	//doPlayerAddPremiumDays(cid, days)
	lua_register(m_luaState, "doPlayerAddPremiumDays", LuaScriptInterface::luaDoPlayerAddPremiumDays);

	//getPlayerPremiumDays(cid)
	lua_register(m_luaState, "getPlayerPremiumDays", LuaScriptInterface::luaGetPlayerPremiumDays);

	//getPlayerSkullType(cid)
	lua_register(m_luaState, "getPlayerSkullType", LuaScriptInterface::luaGetPlayerSkullType);

	//getPlayerAccountBalance(cid)
	lua_register(m_luaState, "getPlayerBalance", LuaScriptInterface::luaGetPlayerBalance);

	//playerLearnInstantSpell(cid, name)
	lua_register(m_luaState, "playerLearnInstantSpell", LuaScriptInterface::luaPlayerLearnInstantSpell);

	//canPlayerLearnInstantSpell(cid, name)
	lua_register(m_luaState, "canPlayerLearnInstantSpell", LuaScriptInterface::luaCanPlayerLearnInstantSpell);

	//getPlayerLearnedInstantSpell(cid, name)
	lua_register(m_luaState, "getPlayerLearnedInstantSpell", LuaScriptInterface::luaGetPlayerLearnedInstantSpell);

	//getPlayerInstantSpellInfo(cid, index)
	lua_register(m_luaState, "getPlayerInstantSpellInfo", LuaScriptInterface::luaGetPlayerInstantSpellInfo);

	//getPlayerInstantSpellCount(cid)
	lua_register(m_luaState, "getPlayerInstantSpellCount", LuaScriptInterface::luaGetPlayerInstantSpellCount);

	//getInstantSpellInfoByName(cid, name)
	lua_register(m_luaState, "getInstantSpellInfoByName", LuaScriptInterface::luaGetInstantSpellInfoByName);

	//getInstantSpellWords(name)
	lua_register(m_luaState, "getInstantSpellWords", LuaScriptInterface::luaGetInstantSpellWords);

	//getPlayerStorageValue(cid, valueid)
	lua_register(m_luaState, "getPlayerStorageValue", LuaScriptInterface::luaGetPlayerStorageValue);

	//setPlayerStorageValue(cid, valueid, newvalue)
	lua_register(m_luaState, "setPlayerStorageValue", LuaScriptInterface::luaSetPlayerStorageValue);

	//isPremium(cid)
	lua_register(m_luaState, "isPremium", LuaScriptInterface::luaIsPremium);

	//getGlobalStorageValue(valueid)
	lua_register(m_luaState, "getGlobalStorageValue", LuaScriptInterface::luaGetGlobalStorageValue);

	//setGlobalStorageValue(valueid, newvalue)
	lua_register(m_luaState, "setGlobalStorageValue", LuaScriptInterface::luaSetGlobalStorageValue);

	//getTilePzInfo(pos)
	//1 is pz. 0 no pz.
	lua_register(m_luaState, "getTilePzInfo", LuaScriptInterface::luaGetTilePzInfo);

	//getTileHouseInfo(pos)
	//0 no house. != 0 house id
	lua_register(m_luaState, "getTileHouseInfo", LuaScriptInterface::luaGetTileHouseInfo);

	//getItemRWInfo(uid)
	lua_register(m_luaState, "getItemRWInfo", LuaScriptInterface::luaGetItemRWInfo);

	//getThingfromPos(pos)
	lua_register(m_luaState, "getThingfromPos", LuaScriptInterface::luaGetThingfromPos);

	//getThing(uid)
	lua_register(m_luaState, "getThing", LuaScriptInterface::luaGetThing);

	//queryTileAddThing(uid, pos, <optional> flags)
	lua_register(m_luaState, "queryTileAddThing", LuaScriptInterface::luaQueryTileAddThing);

	//getThingPos(uid)
	lua_register(m_luaState, "getThingPos", LuaScriptInterface::luaGetThingPos);

	//getTileItemById(pos, itemId, <optional> subType)
	lua_register(m_luaState, "getTileItemById", LuaScriptInterface::luaGetTileItemById);

	//getTileItemByType(pos, type)
	lua_register(m_luaState, "getTileItemByType", LuaScriptInterface::luaGetTileItemByType);

	//getTileThingByPos(pos)
	lua_register(m_luaState, "getTileThingByPos", LuaScriptInterface::luaGetTileThingByPos);

	//getTopCreature(pos)
	lua_register(m_luaState, "getTopCreature", LuaScriptInterface::luaGetTopCreature);

	//doRemoveItem(uid, <optional> count)
	lua_register(m_luaState, "doRemoveItem", LuaScriptInterface::luaDoRemoveItem);

	//doPlayerFeed(cid, food)
	lua_register(m_luaState, "doPlayerFeed", LuaScriptInterface::luaDoFeedPlayer);

	//doPlayerSendCancel(cid, text)
	lua_register(m_luaState, "doPlayerSendCancel", LuaScriptInterface::luaDoSendCancel);

	//doPlayerSendDefaultCancel(cid, ReturnValue)
	lua_register(m_luaState, "doPlayerSendDefaultCancel", LuaScriptInterface::luaDoSendDefaultCancel);

	//doTeleportThing(uid, newpos)
	lua_register(m_luaState, "doTeleportThing", LuaScriptInterface::luaDoTeleportThing);

	//doTransformItem(uid, toitemid, <optional> count/subtype)
	lua_register(m_luaState, "doTransformItem", LuaScriptInterface::luaDoTransformItem);

	//doCreatureSay(cid, text, type)
	lua_register(m_luaState, "doCreatureSay", LuaScriptInterface::luaDoCreatureSay);
	lua_register(m_luaState, "doPlayerSay", LuaScriptInterface::luaDoCreatureSay); //For scripts compatibility

	//doSendMagicEffect(pos, type)
	lua_register(m_luaState, "doSendMagicEffect", LuaScriptInterface::luaDoSendMagicEffect);

	//doSendDistanceShoot(frompos, topos, type)
	lua_register(m_luaState, "doSendDistanceShoot", LuaScriptInterface::luaDoSendDistanceShoot);

	//doChangeTypeItem(uid, newtype)
	lua_register(m_luaState, "doChangeTypeItem", LuaScriptInterface::luaDoChangeTypeItem);

	//doSetItemActionId(uid, actionid)
	lua_register(m_luaState, "doSetItemActionId", LuaScriptInterface::luaDoSetItemActionId);

	//doSetItemText(uid, text)
	lua_register(m_luaState, "doSetItemText", LuaScriptInterface::luaDoSetItemText);

	//doSetItemSpecialDescription(uid, desc)
	lua_register(m_luaState, "doSetItemSpecialDescription", LuaScriptInterface::luaDoSetItemSpecialDescription);

	//doSendAnimatedText(pos, text, color)
	lua_register(m_luaState, "doSendAnimatedText", LuaScriptInterface::luaDoSendAnimatedText);

	//doPlayerAddSkillTry(cid, skillid, n)
	lua_register(m_luaState, "doPlayerAddSkillTry", LuaScriptInterface::luaDoPlayerAddSkillTry);

	//doPlayerAddManaSpent(cid, mana)
	lua_register(m_luaState, "doPlayerAddManaSpent", LuaScriptInterface::luaDoPlayerAddManaSpent);

	//doPlayerAddHealth(cid, health)
	lua_register(m_luaState, "doPlayerAddHealth", LuaScriptInterface::luaDoPlayerAddHealth);

	//doCreatureAddHealth(cid, health)
	lua_register(m_luaState, "doCreatureAddHealth", LuaScriptInterface::luaDoPlayerAddHealth);

	//doPlayerAddMana(cid, mana)
	lua_register(m_luaState, "doPlayerAddMana", LuaScriptInterface::luaDoPlayerAddMana);

	//cleanMap()
	lua_register(m_luaState, "cleanMap", LuaScriptInterface::luaCleanMap);

	#ifdef __CHANGE_MAX__
	//doPlayerAddHealthMax(cid,health)
	lua_register(m_luaState, "doPlayerAddHealthMax", LuaScriptInterface::luaDoPlayerAddHealthMax);
	//doPlayerAddManaMax(cid,health)
	lua_register(m_luaState, "doPlayerAddManaMax", LuaScriptInterface::luaDoPlayerAddManaMax);
	#endif

	//doPlayerAddSoul(cid, soul)
	lua_register(m_luaState, "doPlayerAddSoul", LuaScriptInterface::luaDoPlayerAddSoul);

	//doPlayerAddItem(uid, itemid, <optional> count/subtype)
	//Returns uid of the created item
	lua_register(m_luaState, "doPlayerAddItem", LuaScriptInterface::luaDoPlayerAddItem);

	//doPlayerAddItemEx(cid, uid, <optional: default: 0> canDropOnMap)
	lua_register(m_luaState, "doPlayerAddItemEx", LuaScriptInterface::luaDoPlayerAddItemEx);

	//doPlayerSendTextMessage(cid, MessageClasses, message)
	lua_register(m_luaState, "doPlayerSendTextMessage", LuaScriptInterface::luaDoPlayerSendTextMessage);

	//doPlayerRemoveMoney(cid, money)
	lua_register(m_luaState, "doPlayerRemoveMoney", LuaScriptInterface::luaDoPlayerRemoveMoney);

	//doPlayerAddMoney(cid, money)
	lua_register(m_luaState, "doPlayerAddMoney", LuaScriptInterface::luaDoPlayerAddMoney);

	//doPlayerWithdrawMoney(cid, money)
	lua_register(m_luaState, "doPlayerWithdrawMoney", LuaScriptInterface::luaDoPlayerWithdrawMoney);

	//doPlayerDepositMoney(cid, money)
	lua_register(m_luaState, "doPlayerDepositMoney", LuaScriptInterface::luaDoPlayerDepositMoney);

	//doPlayerTransferMoneyTo(cid, target, money)
	lua_register(m_luaState, "doPlayerTransferMoneyTo", LuaScriptInterface::luaDoPlayerTransferMoneyTo);

	//doShowTextWindow(cid, maxlen, canWrite)
	lua_register(m_luaState, "doShowTextWindow", LuaScriptInterface::luaDoShowTextWindow);

	//doShowTextDialog(cid, itemid, text)
	lua_register(m_luaState, "doShowTextDialog", LuaScriptInterface::luaDoShowTextDialog);

	//doDecayItem(uid)
	lua_register(m_luaState, "doDecayItem", LuaScriptInterface::luaDoDecayItem);

	//doCreateItem(itemid, <optional> type/count, pos)
	//Returns uid of the created item, only works on tiles.
	lua_register(m_luaState, "doCreateItem", LuaScriptInterface::luaDoCreateItem);

	//doCreateItemEx(itemid, <optional> count/subtype)
	lua_register(m_luaState, "doCreateItemEx", LuaScriptInterface::luaDoCreateItemEx);

	//doTileAddItemEx(pos, uid)
	lua_register(m_luaState, "doTileAddItemEx", LuaScriptInterface::luaDoTileAddItemEx);

	//doRelocate(pos, posTo)
	//Moves all moveable objects from pos to posTo
	lua_register(m_luaState, "doRelocate", LuaScriptInterface::luaDoRelocate);

	//doCreateTeleport(teleportID, positionToGo, createPosition)
	lua_register(m_luaState, "doCreateTeleport", LuaScriptInterface::luaDoCreateTeleport);

	//doSummonCreature(name, pos)
	lua_register(m_luaState, "doSummonCreature", LuaScriptInterface::luaDoSummonCreature);

	//doPlayerSummonCreature(cid, name, pos)
	lua_register(m_luaState, "doPlayerSummonCreature", LuaScriptInterface::luaDoPlayerSummonCreature);

#ifdef __SUMMON_CLONE_DZOJO__	
    //doPlayerSummonClone(cid,name, position)
	lua_register(m_luaState, "doPlayerSummonClone", LuaScriptInterface::luaDoPlayerSummonClone);
#endif

	//doRemoveCreature(cid)
	lua_register(m_luaState, "doRemoveCreature", LuaScriptInterface::luaDoRemoveCreature);

	//doMoveCreature(cid, direction)
	lua_register(m_luaState, "doMoveCreature", LuaScriptInterface::luaDoMoveCreature);

	//doPlayerSetMasterPos(cid, pos)
	lua_register(m_luaState, "doPlayerSetMasterPos", LuaScriptInterface::luaDoPlayerSetMasterPos);

	//doPlayerSetTown(cid, townid)
	lua_register(m_luaState, "doPlayerSetTown", LuaScriptInterface::luaDoPlayerSetTown);

	//doPlayerSetVocation(cid, voc)
	lua_register(m_luaState, "doPlayerSetVocation", LuaScriptInterface::luaDoPlayerSetVocation);

	//doPlayerRemoveItem(cid, itemid, count, <optional> subtype)
	lua_register(m_luaState, "doPlayerRemoveItem", LuaScriptInterface::luaDoPlayerRemoveItem);

	//doPlayerAddExp(cid, exp)
	lua_register(m_luaState, "doPlayerAddExp", LuaScriptInterface::luaDoPlayerAddExp);

	//doPlayerSetGuildId(cid, id)
	//lua_register(m_luaState, "doPlayerSetGuildId", LuaScriptInterface::luaDoPlayerSetGuildId);

	//doPlayerSetGuildRank(cid, rank)
	lua_register(m_luaState, "doPlayerSetGuildRank", LuaScriptInterface::luaDoPlayerSetGuildRank);

	//doPlayerSetGuildNick(cid, nick)
	lua_register(m_luaState, "doPlayerSetGuildNick", LuaScriptInterface::luaDoPlayerSetGuildNick);

	//doPlayerAddOutfit(cid, looktype, addons)
	lua_register(m_luaState, "doPlayerAddOutfit", LuaScriptInterface::luaDoPlayerAddOutfit);

	//doPlayerRemOutfit(cid, looktype, addons)
	lua_register(m_luaState, "doPlayerRemOutfit", LuaScriptInterface::luaDoPlayerRemOutfit);

	//canPlayerWearOutfit(cid, looktype, addons)
	lua_register(m_luaState, "canPlayerWearOutfit", LuaScriptInterface::luaCanPlayerWearOutfit);

	//doSetCreatureLight(cid, lightLevel, lightColor, time)
	lua_register(m_luaState, "doSetCreatureLight", LuaScriptInterface::luaDoSetCreatureLight);

	//doPlayerSetLossPercent(cid, lossType, newPercent)
	lua_register(m_luaState, "doPlayerSetLossPercent", LuaScriptInterface::luaDoPlayerSetLossPercent);

	//doSetCreatureDropLoot(cid, doDrop)
	lua_register(m_luaState, "doSetCreatureDropLoot", LuaScriptInterface::luaDoSetCreatureDropLoot);

	//isPlayer(cid)
	lua_register(m_luaState, "isPlayer", LuaScriptInterface::luaIsPlayer);

	//isCreature(cid)
	lua_register(m_luaState, "isCreature", LuaScriptInterface::luaIsCreature);

	//isContainer(uid)
	lua_register(m_luaState, "isContainer", LuaScriptInterface::luaIsContainer);

	//isMoveable(uid)
	lua_register(m_luaState, "isMoveable", LuaScriptInterface::luaIsMoveable);

	//getPlayerByName(name)
	lua_register(m_luaState, "getPlayerByName", LuaScriptInterface::luaGetPlayerByName);

	//getPlayerGUIDByName(name)
	lua_register(m_luaState, "getPlayerGUIDByName", LuaScriptInterface::luaGetPlayerGUIDByName);

	//registerCreatureEvent(uid, eventName)
	lua_register(m_luaState, "registerCreatureEvent", LuaScriptInterface::luaRegisterCreatureEvent);

	//getContainerSize(uid)
	lua_register(m_luaState, "getContainerSize", LuaScriptInterface::luaGetContainerSize);

	//getContainerCap(uid)
	lua_register(m_luaState, "getContainerCap", LuaScriptInterface::luaGetContainerCap);

	//getContainerItem(uid, slot)
	lua_register(m_luaState, "getContainerItem", LuaScriptInterface::luaGetContainerItem);

	//doAddContainerItem(uid, itemid, <optional> count/subtype)
	lua_register(m_luaState, "doAddContainerItem", LuaScriptInterface::luaDoAddContainerItem);

	//getDepotId(uid)
	lua_register(m_luaState, "getDepotId", LuaScriptInterface::luaGetDepotId);

	//getHouseOwner(houseid)
	lua_register(m_luaState, "getHouseOwner", LuaScriptInterface::luaGetHouseOwner);

	//getHouseName(houseid)
	lua_register(m_luaState, "getHouseName", LuaScriptInterface::luaGetHouseName);

	//getHouseEntry(houseid)
	lua_register(m_luaState, "getHouseEntry", LuaScriptInterface::luaGetHouseEntry);

	//getHouseRent(houseid)
	lua_register(m_luaState, "getHouseRent", LuaScriptInterface::luaGetHouseRent);

	//getHouseTown(houseid)
	lua_register(m_luaState, "getHouseTown", LuaScriptInterface::luaGetHouseTown);

	//getHouseAccessList(houseid, listid)
	lua_register(m_luaState, "getHouseAccessList", LuaScriptInterface::luaGetHouseAccessList);

	//getHouseByPlayerGUID(playerGUID)
	lua_register(m_luaState, "getHouseByPlayerGUID", LuaScriptInterface::luaGetHouseByPlayerGUID);

	//getHouseTilesSize(houseid)
	lua_register(m_luaState, "getHouseTilesSize", LuaScriptInterface::luaGetHouseTilesSize);

	//setHouseAccessList(houseid, listid, listtext)
	lua_register(m_luaState, "setHouseAccessList", LuaScriptInterface::luaSetHouseAccessList);

	//setHouseOwner(houseid, ownerGUID)
	lua_register(m_luaState, "setHouseOwner", LuaScriptInterface::luaSetHouseOwner);

	//setWorldType(type)
	lua_register(m_luaState, "setWorldType", LuaScriptInterface::luaSetWorldType);

	//getWorldType()
	lua_register(m_luaState, "getWorldType", LuaScriptInterface::luaGetWorldType);

	//getWorldTime()
	lua_register(m_luaState, "getWorldTime", LuaScriptInterface::luaGetWorldTime);

	//getWorldLight()
	lua_register(m_luaState, "getWorldLight", LuaScriptInterface::luaGetWorldLight);

	//getWorldCreatures(type)
	//0 players, 1 monsters, 2 npcs, 3 all
	lua_register(m_luaState, "getWorldCreatures", LuaScriptInterface::luaGetWorldCreatures);

	//getWorldUpTime()
	lua_register(m_luaState, "getWorldUpTime", LuaScriptInterface::luaGetWorldUpTime);

	//getPlayersOnlineList()
	lua_register(m_luaState, "getPlayersOnlineList", LuaScriptInterface::luaGetPlayersOnlineList);

	//broadcastMessage(<optional> messageClass, message)
	lua_register(m_luaState, "broadcastMessage", LuaScriptInterface::luaBroadcastMessage);
	lua_register(m_luaState, "broadcastMessageEx", LuaScriptInterface::luaBroadcastMessage);

	//getGuildId(guild_name)
	lua_register(m_luaState, "getGuildId", LuaScriptInterface::luaGetGuildId);

	//createCombatArea( {area}, <optional> {extArea} )
	lua_register(m_luaState, "createCombatArea", LuaScriptInterface::luaCreateCombatArea);

	//createConditionObject(type)
	lua_register(m_luaState, "createConditionObject", LuaScriptInterface::luaCreateConditionObject);

	//setCombatArea(combat, area)
	lua_register(m_luaState, "setCombatArea", LuaScriptInterface::luaSetCombatArea);

	//setCombatCondition(combat, condition)
	lua_register(m_luaState, "setCombatCondition", LuaScriptInterface::luaSetCombatCondition);

	//setCombatParam(combat, key, value)
	lua_register(m_luaState, "setCombatParam", LuaScriptInterface::luaSetCombatParam);

	//setConditionParam(condition, key, value)
	lua_register(m_luaState, "setConditionParam", LuaScriptInterface::luaSetConditionParam);

	//addDamageCondition(condition, rounds, time, value)
	lua_register(m_luaState, "addDamageCondition", LuaScriptInterface::luaAddDamageCondition);

	//addOutfitCondition(condition, lookTypeEx, lookType, lookHead, lookBody, lookLegs, lookFeet)
	lua_register(m_luaState, "addOutfitCondition", LuaScriptInterface::luaAddOutfitCondition);

	//setCombatCallBack(combat, key, function_name)
	lua_register(m_luaState, "setCombatCallback", LuaScriptInterface::luaSetCombatCallBack);

	//setCombatFormula(combat, type, mina, minb, maxa, maxb)
	lua_register(m_luaState, "setCombatFormula", LuaScriptInterface::luaSetCombatFormula);

	//setConditionFormula(combat, mina, minb, maxa, maxb)
	lua_register(m_luaState, "setConditionFormula", LuaScriptInterface::luaSetConditionFormula);

	//doCombat(cid, combat, param)
	lua_register(m_luaState, "doCombat", LuaScriptInterface::luaDoCombat);

	//createCombatObject()
	lua_register(m_luaState, "createCombatObject", LuaScriptInterface::luaCreateCombatObject);

	//doAreaCombatHealth(cid, type, pos, area, min, max, effect)
	lua_register(m_luaState, "doAreaCombatHealth", LuaScriptInterface::luaDoAreaCombatHealth);

	//doTargetCombatHealth(cid, target, type, min, max, effect)
	lua_register(m_luaState, "doTargetCombatHealth", LuaScriptInterface::luaDoTargetCombatHealth);

	//doAreaCombatMana(cid, pos, area, min, max, effect)
	lua_register(m_luaState, "doAreaCombatMana", LuaScriptInterface::luaDoAreaCombatMana);

	//doTargetCombatMana(cid, target, min, max, effect)
	lua_register(m_luaState, "doTargetCombatMana", LuaScriptInterface::luaDoTargetCombatMana);

	//doAreaCombatCondition(cid, pos, area, condition, effect)
	lua_register(m_luaState, "doAreaCombatCondition", LuaScriptInterface::luaDoAreaCombatCondition);

	//doTargetCombatCondition(cid, target, condition, effect)
	lua_register(m_luaState, "doTargetCombatCondition", LuaScriptInterface::luaDoTargetCombatCondition);

	//doAreaCombatDispel(cid, pos, area, type, effect)
	lua_register(m_luaState, "doAreaCombatDispel", LuaScriptInterface::luaDoAreaCombatDispel);

	//doTargetCombatDispel(cid, target, type, effect)
	lua_register(m_luaState, "doTargetCombatDispel", LuaScriptInterface::luaDoTargetCombatDispel);

	//doChallengeCreature(cid, target)
	lua_register(m_luaState, "doChallengeCreature", LuaScriptInterface::luaDoChallengeCreature);

	//doConvinceCreature(cid, target)
	lua_register(m_luaState, "doConvinceCreature", LuaScriptInterface::luaDoConvinceCreature);

	//doAddCondition(cid, condition)
	lua_register(m_luaState, "doAddCondition", LuaScriptInterface::luaDoAddCondition);

	//doRemoveCondition(cid, type)
	lua_register(m_luaState, "doRemoveCondition", LuaScriptInterface::luaDoRemoveCondition);

	//numberToVariant(number)
	lua_register(m_luaState, "numberToVariant", LuaScriptInterface::luaNumberToVariant);

	//stringToVariant(string)
	lua_register(m_luaState, "stringToVariant", LuaScriptInterface::luaStringToVariant);

	//positionToVariant(pos)
	lua_register(m_luaState, "positionToVariant", LuaScriptInterface::luaPositionToVariant);

	//targetPositionToVariant(pos)
	lua_register(m_luaState, "targetPositionToVariant", LuaScriptInterface::luaTargetPositionToVariant);

	//variantToNumber(var)
	lua_register(m_luaState, "variantToNumber", LuaScriptInterface::luaVariantToNumber);

	//variantToString(var)
	lua_register(m_luaState, "variantToString", LuaScriptInterface::luaVariantToString);

	//variantToPosition(var)
	lua_register(m_luaState, "variantToPosition", LuaScriptInterface::luaVariantToPosition);

	//doChangeSpeed(cid, delta)
	lua_register(m_luaState, "doChangeSpeed", LuaScriptInterface::luaDoChangeSpeed);

	//doCreatureChangeOutfit(cid, outfit)
	lua_register(m_luaState, "doCreatureChangeOutfit", LuaScriptInterface::luaDoCreatureChangeOutfit);

	//doSetMonsterOutfit(cid, name, time)
	lua_register(m_luaState, "doSetMonsterOutfit", LuaScriptInterface::luaSetMonsterOutfit);

	//doSetItemOutfit(cid, item, time)
	lua_register(m_luaState, "doSetItemOutfit", LuaScriptInterface::luaSetItemOutfit);

	//doSetCreatureOutfit(cid, outfit, time)
	lua_register(m_luaState, "doSetCreatureOutfit", LuaScriptInterface::luaSetCreatureOutfit);

	//getCreatureOutfit(cid)
	lua_register(m_luaState, "getCreatureOutfit", LuaScriptInterface::luaGetCreatureOutfit);

	#ifdef __XID_SEPERATE_ADDONS__
	//doPlayerAddAddon(cid, looktype, addon)
    lua_register(m_luaState, "doPlayerAddAddon", LuaScriptInterface::luaDoPlayerAddAddon);
	//getPlayerOutfitAddon(cid, looktype)
    lua_register(m_luaState, "getPlayerOutfitAddon", LuaScriptInterface::luaGetPlayerOutfitAddon);
	#endif

	//getCreaturePosition(cid)
	lua_register(m_luaState, "getCreaturePosition", LuaScriptInterface::luaGetCreaturePosition);

	//getCreatureName(cid)
	lua_register(m_luaState, "getCreatureName", LuaScriptInterface::luaGetCreatureName);

	//getCreatureSpeed(cid)
	lua_register(m_luaState, "getCreatureSpeed", LuaScriptInterface::luaGetCreatureSpeed);

	//getCreatureBaseSpeed(cid)
	lua_register(m_luaState, "getCreatureBaseSpeed", LuaScriptInterface::luaGetCreatureBaseSpeed);

	//getCreatureTarget(cid)
	lua_register(m_luaState, "getCreatureTarget", LuaScriptInterface::luaGetCreatureTarget);

	//getCreatureHealth(cid)
	lua_register(m_luaState, "getCreatureHealth", LuaScriptInterface::luaGetCreatureHealth);

	//getCreatureMaxHealth(cid)
	lua_register(m_luaState, "getCreatureMaxHealth", LuaScriptInterface::luaGetCreatureMaxHealth);

	//getCreatureMaster(cid)
	//returns the creature's master or itself if the creature isn't a summon
	lua_register(m_luaState, "getCreatureMaster", LuaScriptInterface::luaGetCreatureMaster);

	//getCreatureSummons(cid)
	//returns a table with all the summons of the creature
	lua_register(m_luaState, "getCreatureSummons", LuaScriptInterface::luaGetCreatureSummons);

	//hasCondition(cid, conditionid)
	lua_register(m_luaState, "hasCondition", LuaScriptInterface::luaHasCondition);

	//hasProperty(uid)
	lua_register(m_luaState, "hasProperty", LuaScriptInterface::luaHasProperty);

	//isItemStackable(itemid)
	lua_register(m_luaState, "isItemStackable", LuaScriptInterface::luaIsItemStackable);

	//isItemRune(itemid)
	lua_register(m_luaState, "isItemRune", LuaScriptInterface::luaIsItemRune);

	//isItemDoor(itemid)
	lua_register(m_luaState, "isItemDoor", LuaScriptInterface::luaIsItemDoor);

	//isItemContainer(itemid)
	lua_register(m_luaState, "isItemContainer", LuaScriptInterface::luaIsItemContainer);

	//isItemFluidContainer(itemid)
	lua_register(m_luaState, "isItemFluidContainer", LuaScriptInterface::luaIsItemFluidContainer);

	//isItemMoveable(itemid)
	lua_register(m_luaState, "isItemMoveable",LuaScriptInterface::luaIsItemMoveable);

	//getItemName(itemid)
	lua_register(m_luaState, "getItemName", LuaScriptInterface::luaGetItemName);

	//getItemDescriptions(itemid)
	lua_register(m_luaState, "getItemDescriptions", LuaScriptInterface::luaGetItemDescriptions);

	//getItemWeight(uid)
	lua_register(m_luaState, "getItemWeight", LuaScriptInterface::luaGetItemWeight);

	//getItemIdByName(name)
	lua_register(m_luaState, "getItemIdByName", LuaScriptInterface::luaGetItemIdByName);

	//debugPrint(text)
	lua_register(m_luaState, "debugPrint", LuaScriptInterface::luaDebugPrint);

	//isInArray(array, value)
	lua_register(m_luaState, "isInArray", LuaScriptInterface::luaIsInArray);

	//addEvent(callback, delay, ...)
	lua_register(m_luaState, "addEvent", LuaScriptInterface::luaAddEvent);

	//stopEvent(eventid)
	lua_register(m_luaState, "stopEvent", LuaScriptInterface::luaStopEvent);

	//getDataDir()
	lua_register(m_luaState, "getDataDir", LuaScriptInterface::luaGetDataDirectory);

	//bit operations for Lua, based on bitlib project release 24
	//bit.bnot, bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift
	luaL_register(m_luaState, "bit", LuaScriptInterface::luaBitReg);
}

int LuaScriptInterface::internalGetPlayerInfo(lua_State *L, PlayerInfo_t info)
{
	uint32_t cid = popNumber(L);
	ScriptEnviroment* env = getScriptEnv();
	int32_t value;

	const Player* player = env->getPlayerByUID(cid);
	if(player){
		const Tile *tile;
		Position pos;
		uint32_t stackpos;
		switch(info){
		case PlayerInfoAccess:
			value = player->getAccessLevel();
			break;
		case PlayerInfoLevel:
			value = player->getLevel();
			break;
		case PlayerInfoMagLevel:
			value = player->getMagicLevel();
			break;
		case PlayerInfoMana:
			value = player->getMana();
			break;
		case PlayerInfoMaxMana:
			value = player->getMaxMana();
			break;
		case PlayerInfoHealth:
			value = player->getHealth();
			break;
		case PlayerInfoMaxHealth:
			value = player->getMaxHealth();
			break;
		case PlayerInfoName:
			lua_pushstring(L, player->name.c_str());
			return 1;
			break;
		case PlayerInfoPosition:
			pos = player->getPosition();
			tile = player->getTile();
			if(tile){
				stackpos = player->getParent()->__getIndexOfThing(player);
			}
			else{
				stackpos = 0;
			}
			pushPosition(L, pos, stackpos);
			return 1;
			break;
		case PlayerInfoMasterPos:
			pos = player->masterPos;
			pushPosition(L, pos, 0);
			return 1;
			break;
		case PlayerInfoFood:
		{
			value = 0;

			Condition* condition = player->getCondition(CONDITION_REGENERATION, CONDITIONID_DEFAULT);
			if(condition){
				value = condition->getTicks() / 1000;
			}
			else{
				value = 0;
			}
			break;
		}
		case PlayerInfoVocation:
			value = player->getVocationId();
			break;
		case PlayerInfoSoul:
			value = player->getPlayerInfo(PLAYERINFO_SOUL);
			break;
		case PlayerInfoFreeCap:
			value = (int)player->getFreeCapacity();
			break;
		case PlayerInfoGuildId:
			value = player->getGuildId();
			break;
		case PlayerInfoGuildName:
			lua_pushstring(L, player->getGuildName().c_str());
			return 1;
			break;
		case PlayerInfoGuildRank:
			lua_pushstring(L, player->getGuildRank().c_str());
			return 1;
			break;
		case PlayerInfoGuildNick:
			lua_pushstring(L, player->getGuildNick().c_str());
			return 1;
			break;
		case PlayerInfoSex:
			value = player->getSex();
			break;
		case PlayerInfoLookDirection:
			value = player->getDirection();
			break;
#ifdef __GET_OUTFIT__
        case PlayerInfoLookType: 
            value = player->currentOutfit.lookType;
            break;
        case PlayerInfoLookHead: 
            value = player->currentOutfit.lookHead; 
            break;
        case PlayerInfoLookBody: 
            value = player->currentOutfit.lookBody; 
            break;
        case PlayerInfoLookLegs: 
            value = player->currentOutfit.lookLegs; 
            break;
        case PlayerInfoLookFeet: 
            value = player->currentOutfit.lookFeet; 
            break;
        case PlayerInfoLookAddons: 
            value = player->currentOutfit.lookAddons; 
            break;
#endif			
		case PlayerInfoTown:
			value = player->getTown();
			break;
		case PlayerInfoGUID:
			value = player->getGUID();
			break;
		case PlayerInfoPremiumDays:
			value = player->getPremiumDays();
			break;
		case PlayerInfoSkullType:
			#ifdef __SKULLSYSTEM__
			value = (uint32_t)player->getSkull();
			#else
			value = 0;
			#endif
			break;
		case PlayerInfoBalance:
		{
			if(g_config.getString(ConfigManager::USE_ACCBALANCE) == "no"){
				value = 0;
			}
			else{
				value = player->balance;
			}
			break;
		}
		default:
			std::string error_str = "Unknown player info. info = " + info;
			reportErrorFunc(error_str);
			value = 0;
			break;
		}
		lua_pushnumber(L,value);
		return 1;
	}
	else{
		std::stringstream error_str;
		error_str << "Player not found. info = " << info;
		reportErrorFunc(error_str.str());
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}
//getPlayer[Info](uid)
int LuaScriptInterface::luaGetPlayerFood(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoFood);}

int LuaScriptInterface::luaGetPlayerAccess(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoAccess);}

int LuaScriptInterface::luaGetPlayerLevel(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoLevel);}

int LuaScriptInterface::luaGetPlayerMagLevel(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoMagLevel);}

int LuaScriptInterface::luaGetPlayerMana(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoMana);}

int LuaScriptInterface::luaGetPlayerMaxMana(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoMaxMana);}

int LuaScriptInterface::luaGetPlayerHealth(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoHealth);}

int LuaScriptInterface::luaGetPlayerMaxHealth(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoMaxHealth);}

int LuaScriptInterface::luaGetPlayerName(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoName);}

int LuaScriptInterface::luaGetPlayerPosition(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoPosition);}

int LuaScriptInterface::luaGetPlayerVocation(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoVocation);}

int LuaScriptInterface::luaGetPlayerMasterPos(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoMasterPos);}

int LuaScriptInterface::luaGetPlayerSoul(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoSoul);}

int LuaScriptInterface::luaGetPlayerFreeCap(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoFreeCap);}

int LuaScriptInterface::luaGetPlayerGuildId(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoGuildId);}

int LuaScriptInterface::luaGetPlayerGuildName(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoGuildName);}

int LuaScriptInterface::luaGetPlayerGuildRank(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoGuildRank);}

int LuaScriptInterface::luaGetPlayerGuildNick(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoGuildNick);}

int LuaScriptInterface::luaGetPlayerSex(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoSex);}

int LuaScriptInterface::luaGetPlayerLookDir(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoLookDirection);}

#ifdef __GET_OUTFIT__    
int LuaScriptInterface::luaGetPlayerLookType(lua_State *L){ 
    return internalGetPlayerInfo(L, PlayerInfoLookType);}
     
int LuaScriptInterface::luaGetPlayerLookHead(lua_State *L){ 
    return internalGetPlayerInfo(L, PlayerInfoLookHead);}
    
int LuaScriptInterface::luaGetPlayerLookBody(lua_State *L){ 
    return internalGetPlayerInfo(L, PlayerInfoLookBody);}
    
int LuaScriptInterface::luaGetPlayerLookLegs(lua_State *L){ 
    return internalGetPlayerInfo(L, PlayerInfoLookLegs);} 
    
int LuaScriptInterface::luaGetPlayerLookFeet(lua_State *L){ 
    return internalGetPlayerInfo(L, PlayerInfoLookFeet);}
    
int LuaScriptInterface::luaGetPlayerLookAddons(lua_State *L){ 
    return internalGetPlayerInfo(L, PlayerInfoLookAddons);}      
#endif

int LuaScriptInterface::luaGetPlayerTown(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoTown);}

int LuaScriptInterface::luaGetPlayerGUID(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoGUID);}

int LuaScriptInterface::luaGetPlayerPremiumDays(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoPremiumDays);}

int LuaScriptInterface::luaGetPlayerSkullType(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoSkullType);}
int LuaScriptInterface::luaGetPlayerBalance(lua_State *L){
	return internalGetPlayerInfo(L, PlayerInfoBalance);}
//

int LuaScriptInterface::luaGetPlayerFlagValue(lua_State *L)
{
	//getPlayerFlagValue(cid, flag)
	uint32_t flagindex = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(flagindex < PlayerFlag_LastFlag){
			lua_pushnumber(L, player->hasFlag((PlayerFlags)flagindex) ? 1 : 0);
		}
		else{
			reportErrorFunc("No valid flag index.");
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaPlayerLearnInstantSpell(lua_State *L)
{
	//playerLearnInstantSpell(cid, name)
	std::string spellName = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(!player){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	InstantSpell* spell = g_spells->getInstantSpellByName(spellName);
	if(!spell){
		std::string error_str = (std::string)"Spell \"" + spellName +  (std::string)"\" not found";
		reportErrorFunc(error_str);
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	player->learnInstantSpell(spell->getName());
	lua_pushnumber(L, LUA_TRUE);
	return 1;
}

int LuaScriptInterface::luaCanPlayerLearnInstantSpell(lua_State *L)
{
	//canPlayerLearnInstantSpell(cid, name)
	std::string spellName = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(!player){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	InstantSpell* spell = g_spells->getInstantSpellByName(spellName);
	if(!spell){
		std::string error_str = (std::string)"Spell \"" + spellName +  (std::string)"\" not found";
		reportErrorFunc(error_str);
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(!player->hasFlag(PlayerFlag_IgnoreSpellCheck)){
		if(player->getLevel() < spell->getLevel()){
			lua_pushnumber(L, LUA_FALSE);
			return 1;
		}

		if(player->getMagicLevel() < spell->getMagicLevel()){
			lua_pushnumber(L, LUA_FALSE);
			return 1;
		}
	}

	lua_pushnumber(L, LUA_TRUE);
	return 1;
}

int LuaScriptInterface::luaGetPlayerLearnedInstantSpell(lua_State *L)
{
	//getPlayerLearnedInstantSpell(cid, name)
	std::string spellName = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(!player){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	InstantSpell* spell = g_spells->getInstantSpellByName(spellName);
	if(!spell){
		std::string error_str = (std::string)"Spell \"" + spellName +  (std::string)"\" not found";
		reportErrorFunc(error_str);
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(!player->hasLearnedInstantSpell(spellName)){
		lua_pushnumber(L, LUA_FALSE);
		return 1;
	}

	lua_pushnumber(L, LUA_TRUE);
	return 1;
}

int LuaScriptInterface::luaGetPlayerInstantSpellCount(lua_State *L)
{
	//getPlayerInstantSpellCount(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		lua_pushnumber(L, g_spells->getInstantSpellCount(player));
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetPlayerInstantSpellInfo(lua_State *L)
{
	//getPlayerInstantSpellInfo(cid, index)
	uint32_t index = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(!player){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	InstantSpell* spell = g_spells->getInstantSpellByIndex(player, index);
	if(!spell){
		reportErrorFunc(getErrorDesc(LUA_ERROR_SPELL_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	lua_newtable(L);
	setField(L, "name", spell->getName());
	setField(L, "words", spell->getWords());
	setField(L, "level", spell->getLevel());
	setField(L, "mlevel", spell->getMagicLevel());
	setField(L, "mana", spell->getManaCost(player));
	setField(L, "manapercent", spell->getManaPercent());
	return 1;
}

int LuaScriptInterface::luaGetInstantSpellInfoByName(lua_State *L)
{
	//getInstantSpellInfoByName(cid, name)
	std::string spellName = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(!player && cid != 0){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	InstantSpell* spell = g_spells->getInstantSpellByName(spellName);
	if(!spell){
		reportErrorFunc(getErrorDesc(LUA_ERROR_SPELL_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	lua_newtable(L);
	setField(L, "name", spell->getName());
	setField(L, "words", spell->getWords());
	setField(L, "level", spell->getLevel());
	setField(L, "mlevel", spell->getMagicLevel());
	setField(L, "mana", (player != NULL ? spell->getManaCost(player) : 0));
	setField(L, "manapercent", spell->getManaPercent());
	return 1;
}

int LuaScriptInterface::luaGetInstantSpellWords(lua_State *L)
{
	//getInstantSpellWords(name)
	std::string spellName = popString(L);
	InstantSpell* spell = g_spells->getInstantSpellByName(spellName);
	if(!spell){
		reportErrorFunc(getErrorDesc(LUA_ERROR_SPELL_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	lua_pushstring(L, spell->getWords().c_str());
	return 1;
}


int LuaScriptInterface::luaDoRemoveItem(lua_State *L)
{
	//doRemoveItem(uid, <optional> count)
	int32_t parameters = lua_gettop(L);

	int32_t count = -1;
	if(parameters > 1){
		count = popNumber(L);
	}

	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(!item){
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	ReturnValue ret = g_game.internalRemoveItem(item, count);
	if(ret != RET_NOERROR){
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	env->removeItemByUID(uid);
	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoPlayerRemoveItem(lua_State *L)
{
	//doPlayerRemoveItem(cid, itemid, count, <optional> subtype)
	int32_t parameters = lua_gettop(L);

	int32_t subType = -1;
	if(parameters > 3){
		subType = popNumber(L);
	}

	uint32_t count = popNumber(L);
	uint16_t itemId = (uint16_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(g_game.removeItemOfType(player, itemId, count, subType)){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoFeedPlayer(lua_State *L)
{
	//doFeedPlayer(uid, food)
	int32_t food = (int32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->addDefaultRegeneration(food * 1000);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSendCancel(lua_State *L)
{
	//doSendCancel(uid, text)
	const char * text = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const Player* player = env->getPlayerByUID(cid);
	if(player){
		player->sendCancel(text);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSendDefaultCancel(lua_State *L)
{
	//doPlayerSendDefaultCancel(cid, ReturnValue)
	ReturnValue ret = (ReturnValue)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const Player* player = env->getPlayerByUID(cid);
	if(player){
		player->sendCancelMessage(ret);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaDoTeleportThing(lua_State *L)
{
	//doTeleportThing(uid, newpos)
	PositionEx pos;
	popPosition(L, pos);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Thing* tmp = env->getThingByUID(uid);
	if(tmp){
		if(g_game.internalTeleport(tmp, pos) == RET_NOERROR){
			lua_pushnumber(L, LUA_NO_ERROR);
		}
		else{
			reportErrorFunc("Can not teleport thing.");
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_THING_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoTransformItem(lua_State *L)
{
	//doTransformItem(uid, toitemid, <optional> count/subtype)
	int32_t parameters = lua_gettop(L);

	int32_t count = -1;
	if(parameters > 2){
		count = popNumber(L);
	}

	uint16_t toId = (uint16_t)popNumber(L);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(!item){
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	const ItemType& it = Item::items[toId];
	if(it.stackable && count > 100){
		reportErrorFunc("Stack count cannot be higher than 100.");
		count = 100;
	}

	Item* newItem = g_game.transformItem(item, toId, count);

	if(item->isRemoved()){
		env->removeItemByUID(uid);
	}

	if(newItem && newItem != item){
		env->insertThing(uid, newItem);
	}

	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoCreatureSay(lua_State *L)
{
	//doCreatureSay(cid, text, type)
	uint32_t type = popNumber(L);
	const char * text = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		g_game.internalCreatureSay(creature, (SpeakClasses)type, std::string(text));
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSendMagicEffect(lua_State *L)
{
	//doSendMagicEffect(pos, type)
	uint32_t type = popNumber(L);
	PositionEx pos;
	popPosition(L, pos);

	ScriptEnviroment* env = getScriptEnv();

	if(pos.x == 0xFFFF){
		pos = env->getRealPos();
	}

	g_game.addMagicEffect(pos, type);
	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoChangeTypeItem(lua_State *L)
{
	//doChangeTypeItem(uid, newtype)
	int32_t subtype = (int32_t)popNumber(L);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(!item){
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	Item* newItem = g_game.transformItem(item, item->getID(), subtype);

	if(item->isRemoved()){
		env->removeItemByUID(uid);
	}

	if(newItem && newItem != item){
		env->insertThing(uid, newItem);
	}

	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoPlayerAddSkillTry(lua_State *L)
{
	//doPlayerAddSkillTry(cid, skillid, n)
	uint32_t n = popNumber(L);
	uint32_t skillid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->addSkillAdvance((skills_t)skillid, n);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerAddManaSpent(lua_State *L)
{
	//doPlayerAddManaSpent(cid, mana)
	uint32_t mana = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->addManaSpent(mana);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerAddHealth(lua_State *L)
{
	//doPlayerAddHealth(cid, health)
	int32_t healthChange = (int32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		if(healthChange >= 0){
			g_game.combatChangeHealth(COMBAT_HEALING, NULL, creature, healthChange);
		}
		else{
			g_game.combatChangeHealth(COMBAT_UNDEFINEDDAMAGE, NULL, creature, healthChange);
		}

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerAddMana(lua_State *L)
{
	//doPlayerAddMana(cid, mana)
	int32_t manaChange = (int32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		g_game.combatChangeMana(NULL, player, manaChange);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerAddItem(lua_State *L)
{
	//doPlayerAddItem(cid, itemid, <optional> count/subtype)
	int32_t parameters = lua_gettop(L);

	uint32_t count = 0;
	if(parameters > 2){
		count = popNumber(L);
	}

	uint32_t itemId = (uint32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(!player){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	const ItemType& it = Item::items[itemId];
	if(it.stackable && count > 100){
		reportErrorFunc("Stack count cannot be higher than 100.");
		count = 100;
	}

	Item* newItem = Item::CreateItem(itemId, count);

	if(!newItem){
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	ReturnValue ret = g_game.internalPlayerAddItem(player, newItem);

	if(ret != RET_NOERROR){
		delete newItem;
		reportErrorFunc("Could not add item");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(newItem->getParent()){
		uint32_t uid = env->addThing((Thing*)newItem);
		lua_pushnumber(L, uid);
	}
	else{
		//stackable item stacked with existing object, newItem will be released
		lua_pushnumber(L, LUA_NULL);
	}

	return 1;
}

int LuaScriptInterface::luaDoPlayerAddItemEx(lua_State *L)
{
	//doPlayerAddItemEx(cid, uid, <optional: default: 0> canDropOnMap)
	int32_t parameters = lua_gettop(L);

	bool canDropOnMap = false;
	if(parameters > 2){
		canDropOnMap = popNumber(L) == 1;
	}

	uint32_t uid = (uint32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(!player){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Item* item = env->getItemByUID(uid);

	if(!item){
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(item->getParent() != VirtualCylinder::virtualCylinder){
		reportErrorFunc("Item already has a parent");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	ReturnValue ret = RET_NOERROR;
	if(canDropOnMap){
		ret = g_game.internalPlayerAddItem(player, item);
	}
	else{
		ret = g_game.internalAddItem(player, item);
	}

	lua_pushnumber(L, ret);
	return 1;
}

int LuaScriptInterface::luaDoTileAddItemEx(lua_State *L)
{
	//doTileAddItemEx(pos, uid)
	uint32_t uid = (uint32_t)popNumber(L);

	PositionEx pos;
	popPosition(L, pos);

	ScriptEnviroment* env = getScriptEnv();
	Tile* tile = g_game.getTile(pos.x, pos.y, pos.z);
	if(!tile){
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Item* item = env->getItemByUID(uid);

	if(!item){
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(item->getParent() != VirtualCylinder::virtualCylinder){
		reportErrorFunc("Item already has a parent");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	ReturnValue ret = g_game.internalAddItem(tile, item);
	lua_pushnumber(L, ret);
	return 1;
}

int LuaScriptInterface::luaDoRelocate(lua_State *L)
{
	//doRelocate(pos, posTo)
	//Moves all moveable objects from pos to posTo

	PositionEx toPos;
	popPosition(L, toPos);

	PositionEx fromPos;
	popPosition(L, fromPos);

	Tile* fromTile = g_game.getTile(fromPos.x, fromPos.y, fromPos.z);
	if(!fromTile){
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Tile* toTile = g_game.getTile(toPos.x, toPos.y, toPos.z);
	if(!toTile){
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	int32_t thingCount = fromTile->getThingCount();
	for(int32_t i = thingCount - 1; i >= 0; --i){
		Thing* thing = fromTile->__getThing(i);
		if(thing){
			if(Item* item = thing->getItem()){
				if(item->isPushable()){
					g_game.internalTeleport(item, toPos);
				}
			}
			else if(Creature* creature = thing->getCreature()){
				if(Position::areInRange<1,1>(fromPos, toPos)){
					g_game.internalMoveCreature(creature, fromTile, toTile, true);
				}
				else{
					g_game.internalTeleport(creature, toPos);
				}
			}
		}
	}

	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoPlayerSendTextMessage(lua_State *L)
{
	//doPlayerSendTextMessage(cid, MessageClasses, message)
	std::string text = popString(L);
	uint32_t messageClass = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const Player* player = env->getPlayerByUID(cid);
	if(!player){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	player->sendTextMessage((MessageClasses)messageClass, text);
	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoSendAnimatedText(lua_State *L)
{
	//doSendAnimatedText(pos, text, color)
	uint32_t color = popNumber(L);
	std::string text = popString(L);
	PositionEx pos;
	popPosition(L, pos);

	ScriptEnviroment* env = getScriptEnv();

	SpectatorVec list;
	SpectatorVec::iterator it;

	if(pos.x == 0xFFFF){
		pos = env->getRealPos();
	}

	g_game.addAnimatedText(pos, color, text);
	return 1;
}

int LuaScriptInterface::luaGetPlayerSkill(lua_State *L)
{
	//getPlayerSkill(cid, skillid)
	uint32_t skillid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const Player* player = env->getPlayerByUID(cid);
	if(player){
		if(skillid <= SKILL_LAST){
			uint32_t value = player->skills[skillid][SKILL_LEVEL];
			lua_pushnumber(L, value);
		}
		else{
			reportErrorFunc("No valid skillId");
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetPlayerLossPercent(lua_State *L)
{
	//getPlayerLossPercent(cid, lossType)
	uint8_t lossType = (uint8_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const Player* player = env->getPlayerByUID(cid);
	if(player){
		if(lossType <= LOSS_LAST){
			uint32_t value = player->getLossPercent((lossTypes_t)lossType);
			lua_pushnumber(L, value);
		}
		else{
			reportErrorFunc("No valid lossType");
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerSetLossPercent(lua_State *L)
{
	//doPlayerSetLossPercent(cid, lossType, newPercent)
	uint32_t newPercent = popNumber(L);
	uint8_t lossType = (uint8_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(lossType <= LOSS_LAST){
			if(newPercent <= 100){
				player->setLossPercent((lossTypes_t)lossType, newPercent);
				lua_pushnumber(L, LUA_NO_ERROR);
			}
			else{
				reportErrorFunc("lossPercent value higher than 100");
				lua_pushnumber(L, LUA_ERROR);
			}
		}
		else{
			reportErrorFunc("No valid lossType");
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSetCreatureDropLoot(lua_State *L)
{
	//doSetCreatureDropLoot(cid, doDrop)
	bool doDrop = popNumber(L) == 1;
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		creature->setDropLoot(doDrop);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaDoShowTextWindow(lua_State *L)
{
	//doShowTextWindow(uid, maxlen, canWrite)
	popNumber(L);
	popNumber(L);
	popNumber(L);
	reportErrorFunc("Deprecated function.");
	lua_pushnumber(L, LUA_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoShowTextDialog(lua_State *L)
{
	//doShowTextDialog(cid, itemid, text)
	std::string text = popString(L);
	uint32_t itemId = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->setWriteItem(NULL, 0);
		player->sendTextWindow(itemId, text);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetItemRWInfo(lua_State *L)
{
	//getItemRWInfo(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const Item* item = env->getItemByUID(uid);
	if(item){
		uint32_t rwflags = 0;
		if(item->isReadable())
			rwflags |= 1;

		if(item->canWriteText()){
			rwflags |= 2;
		}

		lua_pushnumber(L, rwflags);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoDecayItem(lua_State *L)
{
	//doDecayItem(uid)
	//Note: to stop decay set decayTo = 0 in items.otb
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(item){
		g_game.startDecay(item);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetThingfromPos(lua_State *L)
{
	//Consider using getTileItemById/getTileItemByType/getTileThingByPos/getTopCreature instead.

	//getThingfromPos(pos)
	//Note:
	//	stackpos = 255. Get the top thing(item moveable or creature)
	//	stackpos = 254. Get MagicFieldtItem
	//	stackpos = 253. Get Creature

	PositionEx pos;
	popPosition(L, pos);

	ScriptEnviroment* env = getScriptEnv();

	Tile* tile = g_game.getMap()->getTile(pos);
	Thing* thing = NULL;

	if(tile){
		if(pos.stackpos == 255){
			thing = tile->getTopCreature();

			if(thing == NULL){
				Item* item = tile->getTopDownItem();
				if(item && !item->isNotMoveable())
					thing = item;
			}
		}
		else if(pos.stackpos == 254){
			thing = tile->getFieldItem();
		}
		else if(pos.stackpos == 253){
			thing = tile->getTopCreature();
		}
		else{
			thing = tile->__getThing(pos.stackpos);
		}

		if(thing){
			uint32_t thingid = env->addThing(thing);
			pushThing(L, thing, thingid);
		}
		else{
			pushThing(L, NULL, 0);
		}
		return 1;

	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		pushThing(L, NULL, 0);
		return 1;
	}
}

int LuaScriptInterface::luaGetTileItemById(lua_State *L)
{
	//getTileItemById(pos, itemId, <optional> subType)
	ScriptEnviroment* env = getScriptEnv();

	uint32_t parameters = lua_gettop(L);

	int32_t subType = -1;
	if(parameters > 2){
		subType = (int32_t)popNumber(L);
	}

	int32_t itemId = (int32_t)popNumber(L);

	PositionEx pos;
	popPosition(L, pos);

	Tile* tile = g_game.getTile(pos.x, pos.y, pos.z);
	if(!tile){
		pushThing(L, NULL, 0);
		return 1;
	}

	Item* item = g_game.findItemOfType(tile, itemId, false, subType);
	if(!item){
		pushThing(L, NULL, 0);
		return 1;
	}

	uint32_t uid = env->addThing(item);
	pushThing(L, item, uid);

	return 1;
}

int LuaScriptInterface::luaGetTileItemByType(lua_State *L)
{
	//getTileItemByType(pos, type)

	ScriptEnviroment* env = getScriptEnv();

	uint32_t rType = (uint32_t)popNumber(L);

	if(rType >= ITEM_TYPE_LAST){
		reportErrorFunc("Not a valid item type");
		pushThing(L, NULL, 0);
		return 1;
	}

	PositionEx pos;
	popPosition(L, pos);

	Tile* tile = g_game.getTile(pos.x, pos.y, pos.z);
	if(!tile){
		pushThing(L, NULL, 0);
		return 1;
	}

	for(uint32_t i = 0; i < tile->getThingCount(); ++i){
		if(Item* item = tile->__getThing(i)->getItem()){
			const ItemType& it = Item::items[item->getID()];
			if(it.type == (ItemTypes_t) rType){
				uint32_t uid = env->addThing(item);
				pushThing(L, item, uid);
				return 1;
			}
		}
	}

	pushThing(L, NULL, 0);
	return 1;
}

int LuaScriptInterface::luaGetTileThingByPos(lua_State *L)
{
	//getTileThingByPos(pos)

	PositionEx pos;
	popPosition(L, pos);

	ScriptEnviroment* env = getScriptEnv();

	Tile* tile = g_game.getTile(pos.x, pos.y, pos.z);
	if(!tile){
		if(pos.stackpos == -1){
			lua_pushnumber(L, -1);
			return 1;
		}
		else{
			pushThing(L, NULL, 0);
			return 1;
		}
	}

	if(pos.stackpos == -1){
		lua_pushnumber(L, tile->getThingCount());
		return 1;
	}

	Thing* thing = tile->__getThing(pos.stackpos);
	if(!thing){
		pushThing(L, NULL, 0);
		return 1;
	}

	uint32_t uid = env->addThing(thing);
	pushThing(L, thing, uid);
	return 1;
}

int LuaScriptInterface::luaGetTopCreature(lua_State *L)
{
	//getTopCreature(pos)

	PositionEx pos;
	popPosition(L, pos);

	ScriptEnviroment* env = getScriptEnv();

	Tile* tile = g_game.getTile(pos.x, pos.y, pos.z);
	if(!tile){
		pushThing(L, NULL, 0);
		return 1;
	}

	Thing* thing = tile->getTopCreature();
	if(!thing || !thing->getCreature()){
		pushThing(L, NULL, 0);
		return 1;
	}

	uint32_t uid = env->addThing(thing);
	pushThing(L, thing, uid);
	return 1;
}

int LuaScriptInterface::luaDoCreateItem(lua_State *L)
{
	//doCreateItem(itemid, <optional> type/count, pos)
	//Returns uid of the created item, only works on tiles.

	uint32_t parameters = lua_gettop(L);

	PositionEx pos;
	popPosition(L, pos);

	uint32_t count = 0;
	if(parameters > 2){
		count = popNumber(L);
	}

	uint32_t itemId = (uint32_t)popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Tile* tile = g_game.getTile(pos.x, pos.y, pos.z);
	if(!tile){
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	const ItemType& it = Item::items[itemId];
	if(it.stackable && count > 100){
		reportErrorFunc("Stack count cannot be higher than 100.");
		count = 100;
	}

	Item* newItem = Item::CreateItem(itemId, count);

	ReturnValue ret = g_game.internalAddItem(tile, newItem, INDEX_WHEREEVER, FLAG_NOLIMIT);
	if(ret != RET_NOERROR){
		delete newItem;
		reportErrorFunc("Can not add Item");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(newItem->getParent()){
		uint32_t uid = env->addThing(newItem);
		lua_pushnumber(L, uid);
	}
	else{
		//stackable item stacked with existing object, newItem will be released
		lua_pushnumber(L, LUA_NULL);
	}
	return 1;
}

int LuaScriptInterface::luaDoCreateItemEx(lua_State *L)
{
	//doCreateItemEx(itemid, <optional> count/subtype)
	//Returns uid of the created item

	int32_t parameters = lua_gettop(L);

	uint32_t count = 0;
	if(parameters > 1){
		count = popNumber(L);
	}

	uint32_t itemId = (uint32_t)popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const ItemType& it = Item::items[itemId];
	if(it.stackable && count > 100){
		reportErrorFunc("Stack count cannot be higher than 100.");
		count = 100;
	}

	Item* newItem = Item::CreateItem(itemId, count);
	if(!newItem){
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	newItem->setParent(VirtualCylinder::virtualCylinder);
	env->addTempItem(newItem);

	uint32_t uid = env->addThing(newItem);
	lua_pushnumber(L, uid);
	return 1;
}

int LuaScriptInterface::luaDoCreateTeleport(lua_State *L)
{
	//doCreateTeleport(teleportID, positionToGo, createPosition)
	PositionEx createPos;
	popPosition(L, createPos);
	PositionEx toPos;
	popPosition(L, toPos);
	uint32_t itemId = (uint32_t)popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Tile* tile = g_game.getMap()->getTile(createPos);
	if(!tile){
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Item* newItem = Item::CreateItem(itemId);
	Teleport* newTp = newItem->getTeleport();

	if(!newTp){
		delete newItem;
		reportErrorFunc("Wrong teleport id");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	newTp->setDestPos(toPos);

	ReturnValue ret = g_game.internalAddItem(tile, newTp, INDEX_WHEREEVER, FLAG_NOLIMIT);
	if(ret != RET_NOERROR){
		delete newItem;
		reportErrorFunc("Can not add Item");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(newItem->getParent()){
		uint32_t uid = env->addThing(newItem);
		lua_pushnumber(L, uid);
	}
	else{
		//stackable item stacked with existing object, newItem will be released
		lua_pushnumber(L, LUA_NULL);
	}
	return 1;
}

int LuaScriptInterface::luaGetPlayerStorageValue(lua_State *L)
{
	//getPlayerStorageValue(cid, valueid)
	uint32_t key = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const Player* player = env->getPlayerByUID(cid);
	if(player){
		int32_t value;
		if(player->getStorageValue(key, value)){
			lua_pushnumber(L, value);
		}
		else{
			lua_pushnumber(L, -1);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetPlayerStorageValue(lua_State *L)
{
	//setPlayerStorageValue(cid, valueid, newvalue)
	int32_t value = (int32_t)popNumber(L);
	uint32_t key = popNumber(L);
	uint32_t cid = popNumber(L);
	if(IS_IN_KEYRANGE(key, RESERVED_RANGE)){
		std::stringstream error_str;
		error_str << "Accesing to reserverd range: "  << key;
		reportErrorFunc(error_str.str());
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->addStorageValue(key,value);
		lua_pushnumber(L, 0);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSetItemActionId(lua_State *L)
{
	//doSetItemActionId(uid, actionid)
	uint32_t actionid = popNumber(L);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(item){
		item->setActionId(actionid);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSetItemText(lua_State *L)
{
	//doSetItemText(uid, text)
	const char *text = popString(L);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(item){
		std::string str(text);
		item->setText(str);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSetItemSpecialDescription(lua_State *L)
{
	//doSetItemSpecialDescription(uid, desc)
	const char *desc = popString(L);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(item){
		std::string str(desc);
		if(str != ""){
			item->setSpecialDescription(str);
		}
		else{
			item->resetSpecialDescription();
		}
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetTilePzInfo(lua_State *L)
{
	//getTilePzInfo(pos)
	PositionEx pos;
	popPosition(L, pos);

	Tile *tile = g_game.getMap()->getTile(pos);

	if(tile){
		if(tile->hasFlag(TILESTATE_PROTECTIONZONE)){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetTileHouseInfo(lua_State *L)
{
	//getTileHouseInfo(pos)
	PositionEx pos;
	popPosition(L, pos);

	Tile *tile = g_game.getMap()->getTile(pos);
	if(tile){
		if(HouseTile* houseTile = dynamic_cast<HouseTile*>(tile)){
			House* house = houseTile->getHouse();
			if(house){
				lua_pushnumber(L, house->getHouseId());
			}
			else{
				lua_pushnumber(L, LUA_NULL);
			}
		}
		else{
			lua_pushnumber(L, LUA_NULL);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSummonCreature(lua_State *L)
{
	//doSummonCreature(name, pos)
	PositionEx pos;
	popPosition(L, pos);
	const char* name = popString(L);

	ScriptEnviroment* env = getScriptEnv();

	Monster* monster = Monster::createMonster(name);

	if(!monster){
		std::string error_str = (std::string)"Monster name(" + name + (std::string)") not found";
		reportErrorFunc(error_str);
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(!g_game.placeCreature(monster, pos)){
		delete monster;
		std::string error_str = (std::string)"Can not summon monster: " + name;
		reportErrorFunc(error_str);
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	uint32_t cid = env->addThing((Thing*)monster);

	lua_pushnumber(L, cid);
	return 1;
}

#ifdef __SUMMON_CLONE_DZOJO__
int LuaScriptInterface::luaDoPlayerSummonClone(lua_State *L)
{
	//doSummonClone(cid, name, position)
	Position pos;
	uint32_t stackpos;
	popPosition(L, pos, stackpos);
	const char *name = popString(L);
	uint32_t cid = popNumber(L);
	
	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
    Outfit_t newOutfit;
	
	Monster* monster = Monster::createMonster(name);
	         monster->setName(std::string(player->getName()));
	         monster->setName2(std::string(player->getName()));

	if(!monster){
		std::string error_str = (std::string)"Monster name(" + name + (std::string)") not found";
		reportErrorFunc(error_str);
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}
	
	if(!g_game.placeCreature(monster, (Position&)pos)){
		delete monster;
		std::string error_str = (std::string)"Can not summon monster: " + name;
		reportErrorFunc(error_str);
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	player->addSummon(monster);
	
             newOutfit.lookType = player->currentOutfit.lookType;
		     newOutfit.lookHead = player->currentOutfit.lookHead;
		     newOutfit.lookBody = player->currentOutfit.lookBody;
		     newOutfit.lookLegs = player->currentOutfit.lookLegs;
		     newOutfit.lookFeet = player->currentOutfit.lookFeet;
		     newOutfit.lookAddons = player->currentOutfit.lookAddons;

             g_game.internalCreatureChangeOutfit(monster, newOutfit);
	
	lua_pushnumber(L, cid);
	return 1;	
}
#endif

int LuaScriptInterface::luaDoPlayerSummonCreature(lua_State *L)
{
	//doPlayerSummonCreature(cid, name, pos)
	PositionEx pos;
	popPosition(L, pos);
	const char* name = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		Monster* monster = Monster::createMonster(name);
		if(!monster){
			std::string error_str = (std::string)"Monster name(" + name + (std::string)") not found";
			reportErrorFunc(error_str);
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}

		player->addSummon(monster);
		if(!g_game.placeCreature(monster, pos)){
			player->removeSummon(monster);
			std::string error_str = (std::string)"Can not summon monster: " + name;
			reportErrorFunc(error_str);
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}

		uint32_t uid = env->addThing(monster);
		lua_pushnumber(L, uid);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoRemoveCreature(lua_State *L)
{
	//doRemoveCreature(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		//Players will get kicked without restrictions
		Player* player = creature->getPlayer();
		if(player){
			player->kickPlayer();
		}
		//Monsters/NPCs will get removed
		else{
			g_game.removeCreature(creature);
		}
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerRemoveMoney(lua_State *L)
{
	//doPlayerRemoveMoney(cid, money)
	uint32_t money = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(g_game.removeMoney(player, money)){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerAddMoney(lua_State *L)
{
	//doPlayerAddMoney(cid, money)
	uint32_t money = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(g_game.addMoney(player, money)){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerWithdrawMoney(lua_State *L)
{
	//doPlayerWithdrawMoney(cid, money)
	uint32_t money = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(player->withdrawMoney(money)){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerDepositMoney(lua_State *L)
{
	//doPlayerDepositMoney(cid, money)
	uint32_t money = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(player->depositMoney(money)){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerTransferMoneyTo(lua_State *L)
{
	//doPlayerTransferMoneyTo(cid, target, money)
	uint32_t money = popNumber(L);
	std::string target = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(player->transferMoneyTo(target, money)){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerSetMasterPos(lua_State *L)
{
	//doPlayerSetMasterPos(cid, pos)
	PositionEx pos;
	popPosition(L, pos);
	popNumber(L);

	reportErrorFunc("Deprecated function. Use doPlayerSetTown");
	lua_pushnumber(L, LUA_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoPlayerSetTown(lua_State *L)
{
	//doPlayerSetTown(cid, towind)
	uint32_t townid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		Town* town = Towns::getInstance().getTown(townid);
		if(town){
			player->masterPos = town->getTemplePosition();
			player->setTown(townid);
			lua_pushnumber(L, LUA_NO_ERROR);
		}
		else{
			reportErrorFunc("Not found townid");
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerSetVocation(lua_State *L)
{
	//doPlayerSetVocation(cid, voc)
	uint32_t voc = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->setVocation(voc);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDebugPrint(lua_State *L)
{
	//debugPrint(text)
	const char * text = popString(L);
	reportErrorFunc(std::string(text));
	return 0;
}

int LuaScriptInterface::luaDoPlayerAddSoul(lua_State *L)
{
	//doPlayerAddSoul(cid, soul)
	int32_t addsoul = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->changeSoul(addsoul);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetPlayerItemCount(lua_State *L)
{
	//getPlayerItemCount(cid, itemid)
	uint32_t itemId = (uint32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	const Player* player = env->getPlayerByUID(cid);
	if(player){
		uint32_t n = player->__getItemTypeCount(itemId);
		lua_pushnumber(L, n);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetHouseOwner(lua_State *L)
{
	//getHouseOwner(houseid)
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		uint32_t owner = house->getHouseOwner();
		lua_pushnumber(L, owner);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetHouseName(lua_State *L)
{
	//getHouseName(houseid)
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		lua_pushstring(L, house->getName().c_str());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnil(L);
	}
	return 1;
}

int LuaScriptInterface::luaGetHouseEntry(lua_State *L)
{
	//getHouseEntry(houseid)
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		pushPosition(L, house->getEntryPosition(), 0);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnil(L);
	}
	return 1;
}

int LuaScriptInterface::luaGetHouseRent(lua_State *L)
{
	//getHouseRent(houseid)
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		lua_pushnumber(L, house->getRent());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnil(L);
	}
	return 1;
}

int LuaScriptInterface::luaGetHouseTown(lua_State *L)
{
	//getHouseTown(houseid)
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		lua_pushnumber(L, house->getTownId());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnil(L);
	}
	return 1;
}

int LuaScriptInterface::luaGetHouseAccessList(lua_State *L)
{
	//getHouseAccessList(houseid, listid)
	uint32_t listid = popNumber(L);
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		std::string list;
		if(house->getAccessList(listid, list)){
			lua_pushstring(L, list.c_str());
		}
		else{
			reportErrorFunc("No valid listid.");
			lua_pushnil(L);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnil(L);
	}
	return 1;
}

int LuaScriptInterface::luaGetHouseByPlayerGUID(lua_State *L)
{
	//getHouseByPlayerGUID(playerGUID)
	uint32_t guid = popNumber(L);

	House* house = Houses::getInstance().getHouseByPlayerId(guid);
	if(house){
		lua_pushnumber(L, house->getHouseId());
	}
	else{
		lua_pushnil(L);
	}
	return 1;
}

int LuaScriptInterface::luaGetHouseTilesSize(lua_State *L)
{
	//getHouseTilesSize(houseid)
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		lua_pushnumber(L, house->getHouseTileSize());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetHouseAccessList(lua_State *L)
{
	//setHouseAccessList(houseid, listid, listtext)
	std::string list = popString(L);
	uint32_t listid = popNumber(L);
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		house->setAccessList(listid, list);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetHouseOwner(lua_State *L)
{
	//setHouseOwner(houseid, owner)
	uint32_t owner = popNumber(L);
	uint32_t houseid = popNumber(L);

	House* house = Houses::getInstance().getHouse(houseid);
	if(house){
		house->setHouseOwner(owner);
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_HOUSE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetWorldType(lua_State* L)
{
	//setWorldType(type)
	WorldType_t type = (WorldType_t)popNumber(L);

	if(type >= WORLD_TYPE_NO_PVP && type <= WORLD_TYPE_PVP_ENFORCED)
	{
		g_game.setWorldType(type);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else
	{
		reportErrorFunc("Bad worldType type.");
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetWorldType(lua_State *L)
{
	//getWorldType()
	switch(g_game.getWorldType()){
	case WORLD_TYPE_NO_PVP:
		lua_pushnumber(L, 1);
		break;
	case WORLD_TYPE_PVP:
		lua_pushnumber(L, 2);
		break;
	case WORLD_TYPE_PVP_ENFORCED:
		lua_pushnumber(L, 3);
		break;
	default:
		lua_pushnumber(L, LUA_ERROR);
		break;
	}
	return 1;
}

int LuaScriptInterface::luaGetWorldTime(lua_State *L)
{
	//getWorldTime()
	uint32_t time = g_game.getLightHour();
	lua_pushnumber(L, time);
	return 1;
}

int LuaScriptInterface::luaGetWorldLight(lua_State *L)
{
	//getWorldLight()
	LightInfo lightInfo;
	g_game.getWorldLightInfo(lightInfo);

	lua_pushnumber(L, lightInfo.level);
	lua_pushnumber(L, lightInfo.color);
	return 2;
}

int LuaScriptInterface::luaGetWorldCreatures(lua_State *L)
{
	//getWorldCreatures(type)
	//0 players, 1 monsters, 2 npcs, 3 all
	uint32_t type = popNumber(L);
	uint32_t value;
	switch(type){
	case 0:
		value = g_game.getPlayersOnline();
		break;
	case 1:
		value = g_game.getMonstersOnline();
		break;
	case 2:
		value = g_game.getNpcsOnline();
		break;
	case 3:
		value = g_game.getCreaturesOnline();
		break;
	default:
		reportErrorFunc("Wrong creature type.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
		break;
	}
	lua_pushnumber(L, value);
	return 1;
}

int LuaScriptInterface::luaGetWorldUpTime(lua_State *L)
{
	//getWorldUpTime()
	uint32_t uptime = 0;

	Status* status = Status::instance();
	if(status){
		uptime = status->getUptime();
	}

	lua_pushnumber(L, uptime);
	return 1;
}

int LuaScriptInterface::luaGetPlayersOnlineList(lua_State *L)
{
	//getPlayersOnlineList()
	ScriptEnviroment* env = getScriptEnv();

	AutoList<Player>::listiterator it = Player::listPlayer.list.begin();
	lua_newtable(L);
	for(uint32_t i = 1; it != Player::listPlayer.list.end(); ++it, ++i){
		uint32_t cid = env->addThing(it->second);
		lua_pushnumber(L, i);
		lua_pushnumber(L, cid);
		lua_settable(L, -3);
	}

	return 1;
}

int LuaScriptInterface::luaBroadcastMessage(lua_State *L)
{
	//broadcastMessage(<optional> messageClass, message)
	int32_t parameters = lua_gettop(L);

	std::string message = popString(L);
	uint32_t type = 0x12;
	if(parameters >= 2){
		type = popNumber(L);
	}

	if((type >= 0x11 && type <= 0x19) || type == 0x01 || type == 0x04){
		g_game.anonymousBroadcastMessage((MessageClasses)type, message);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc("Not valid messageClass.");
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetPlayerLight(lua_State *L)
{
	//getPlayerLight(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	const Player* player = env->getPlayerByUID(cid);
	if(player){
		LightInfo lightInfo;
		player->getCreatureLight(lightInfo);
		lua_pushnumber(L, lightInfo.level);
		lua_pushnumber(L, lightInfo.color);//color
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}
	return 2;
}

int LuaScriptInterface::luaDoPlayerAddExp(lua_State *L)
{
	//doPlayerAddExp(cid, exp)
	int32_t exp = (int32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(exp > 0){
			player->addExperience(exp);
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetPlayerSlotItem(lua_State *L)
{
	//getPlayerSlotItem(cid, slot)
	uint32_t slot = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	const Player* player = env->getPlayerByUID(cid);
	if(player){
		Thing* thing = player->__getThing(slot);
		if(thing){
			uint32_t uid = env->addThing(thing);
			pushThing(L, thing, uid);
		}
		else{
			pushThing(L, NULL, 0);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		pushThing(L, NULL, 0);
	}
	return 1;
}

int LuaScriptInterface::luaGetPlayerItemById(lua_State *L)
{
	//getPlayerItemById(cid, deepSearch, itemId, <optional> subType)
	ScriptEnviroment* env = getScriptEnv();

	uint32_t parameters = lua_gettop(L);

	int32_t subType = -1;
	if(parameters > 3){
		subType = (int32_t)popNumber(L);
	}

	int32_t itemId = (int32_t)popNumber(L);
	bool deepSearch = popNumber(L) == 1;
	uint32_t cid = popNumber(L);

	Player* player = env->getPlayerByUID(cid);
	if(!player){
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		pushThing(L, NULL, 0);
		return 1;
	}

	Item* item = g_game.findItemOfType(player, itemId, deepSearch, subType);
	if(!item){
		pushThing(L, NULL, 0);
		return 1;
	}

	uint32_t uid = env->addThing(item);
	pushThing(L, item, uid);
	return 1;
}

int LuaScriptInterface::luaGetThing(lua_State *L)
{
	//getThing(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Thing* thing = env->getThingByUID(uid);
	if(thing){
		pushThing(L, thing, uid);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_THING_NOT_FOUND));
		pushThing(L, NULL, 0);
	}
	return 1;
}

int LuaScriptInterface::luaQueryTileAddThing(lua_State *L)
{
	//queryTileAddThing(uid, pos, <optional> flags)
	int32_t parameters = lua_gettop(L);

	uint32_t flags = 0;
	if(parameters > 2){
		flags = popNumber(L);
	}

	PositionEx pos;
	popPosition(L, pos);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Tile* tile = g_game.getTile(pos.x, pos.y, pos.z);
	if(!tile){
		reportErrorFunc(getErrorDesc(LUA_ERROR_TILE_NOT_FOUND));
		lua_pushnumber(L, (uint32_t)RET_NOTPOSSIBLE);
		return 1;
	}

	Thing* thing = env->getThingByUID(uid);
	if(!thing){
		reportErrorFunc(getErrorDesc(LUA_ERROR_THING_NOT_FOUND));
		lua_pushnumber(L, (uint32_t)RET_NOTPOSSIBLE);
		return 1;
	}

	ReturnValue ret = tile->__queryAdd(0, thing, 1, flags);
	lua_pushnumber(L, (uint32_t)ret);
	return 1;
}

int LuaScriptInterface::luaGetThingPos(lua_State *L)
{
	//getThingPos(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Thing* thing = env->getThingByUID(uid);
	Position pos(0, 0, 0);
	uint32_t stackpos = 0;
	if(thing){
		pos = thing->getPosition();
		if(Tile* tile = thing->getTile()){
			stackpos = tile->__getIndexOfThing(thing);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_THING_NOT_FOUND));
	}

	pushPosition(L, pos, stackpos);
	return 1;
}

int LuaScriptInterface::luaCreateCombatObject(lua_State *L)
{
	//createCombatObject()
	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Combat* combat = new Combat;

	if(!combat){
		reportErrorFunc(getErrorDesc(LUA_ERROR_COMBAT_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	uint32_t newCombatId = env->addCombatObject(combat);
	lua_pushnumber(L, newCombatId);
	return 1;
}

bool LuaScriptInterface::getArea(lua_State *L, std::list<uint32_t>& list, uint32_t& rows)
{
	rows = 0;
	uint32_t i = 0, j = 0;
	lua_pushnil(L);  // first key //

	while(lua_next(L, -2) != 0){
		lua_pushnil(L);
		while(lua_next(L, -2) != 0){
			list.push_back((uint32_t)lua_tonumber(L, -1));

			lua_pop(L, 1);  // removes `value'; keeps `key' for next iteration //
			j++;
		}

		++rows;

		j = 0;
		lua_pop(L, 1);  // removes `value'; keeps `key' for next iteration //
		i++;
	}

	lua_pop(L, 1);
	return (rows != 0);
}

int LuaScriptInterface::luaCreateCombatArea(lua_State *L)
{
	//createCombatArea( {area}, <optional> {extArea} )
	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	int32_t parameters = lua_gettop(L);

	AreaCombat* area = new AreaCombat;

	if(parameters > 1){
		//has extra parameter with diagonal area information

		uint32_t rowsExtArea;
		std::list<uint32_t> listExtArea;
		getArea(L, listExtArea, rowsExtArea);

		/*setup all possible rotations*/
		area->setupExtArea(listExtArea, rowsExtArea);
	}

	uint32_t rowsArea = 0;
	std::list<uint32_t> listArea;
	getArea(L, listArea, rowsArea);

	/*setup all possible rotations*/
	area->setupArea(listArea, rowsArea);

	uint32_t newAreaId = env->addCombatArea(area);

	lua_pushnumber(L, newAreaId);
	return 1;
}

int LuaScriptInterface::luaCreateConditionObject(lua_State *L)
{
	//createConditionObject(type)
	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	ConditionType_t type = (ConditionType_t)popNumber(L);

	Condition* condition = Condition::createCondition(CONDITIONID_COMBAT, type, 0, 0);
	if(condition){
		uint32_t newConditionId = env->addConditionObject(condition);
		lua_pushnumber(L, newConditionId);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaSetCombatArea(lua_State *L)
{
	//setCombatArea(combat, area)
	uint32_t areaId = popNumber(L);
	uint32_t combatId = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Combat* combat = env->getCombatObject(combatId);

	if(!combat){
		reportErrorFunc(getErrorDesc(LUA_ERROR_COMBAT_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	const AreaCombat* area = env->getCombatArea(areaId);
	if(!area){
		reportErrorFunc(getErrorDesc(LUA_ERROR_AREA_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	combat->setArea(new AreaCombat(*area));

	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaSetCombatCondition(lua_State *L)
{
	//setCombatCondition(combat, condition)
	uint32_t conditionId = popNumber(L);
	uint32_t combatId = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Combat* combat = env->getCombatObject(combatId);

	if(!combat){
		reportErrorFunc(getErrorDesc(LUA_ERROR_COMBAT_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	const Condition* condition = env->getConditionObject(conditionId);
	if(!condition){
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	combat->setCondition(condition);

	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaSetCombatParam(lua_State *L)
{
	//setCombatParam(combat, key, value)
	uint32_t value = popNumber(L);
	CombatParam_t key = (CombatParam_t)popNumber(L);
	uint32_t combatId = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Combat* combat = env->getCombatObject(combatId);

	if(combat){
		combat->setParam(key, value);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_COMBAT_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetConditionParam(lua_State *L)
{
	//setConditionParam(condition, key, value)
	int32_t value = (int32_t)popNumber(L);
	ConditionParam_t key = (ConditionParam_t)popNumber(L);
	uint32_t conditionId = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Condition* condition = env->getConditionObject(conditionId);

	if(condition){
		condition->setParam(key, value);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaAddDamageCondition(lua_State *L)
{
	//addDamageCondition(condition, rounds, time, value)
	int32_t value = (int32_t)popNumber(L);
	int32_t time = (int32_t)popNumber(L);
	int32_t rounds  = (int32_t)popNumber(L);
	uint32_t conditionId = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	ConditionDamage* condition = dynamic_cast<ConditionDamage*>(env->getConditionObject(conditionId));

	if(condition){
		condition->addDamage(rounds, time, value);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaAddOutfitCondition(lua_State *L)
{
	//addOutfitCondition(condition, lookTypeEx, lookType, lookHead, lookBody, lookLegs, lookFeet)
	Outfit_t outfit;
	outfit.lookFeet = popNumber(L);
	outfit.lookLegs = popNumber(L);
	outfit.lookBody = popNumber(L);
	outfit.lookHead = popNumber(L);
	outfit.lookType = popNumber(L);
	outfit.lookTypeEx = popNumber(L);
	uint32_t conditionId = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	ConditionOutfit* condition = dynamic_cast<ConditionOutfit*>(env->getConditionObject(conditionId));

	if(condition){
		condition->addOutfit(outfit);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetCombatCallBack(lua_State *L)
{
	//setCombatCallBack(combat, key, function_name)
	const char* function = popString(L);
	std::string function_str(function);
	CallBackParam_t key = (CallBackParam_t)popNumber(L);
	uint32_t combatId = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Combat* combat = env->getCombatObject(combatId);

	if(!combat){
		reportErrorFunc(getErrorDesc(LUA_ERROR_COMBAT_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	LuaScriptInterface* scriptInterface = env->getScriptInterface();

	combat->setCallback(key);
	CallBack* callback = combat->getCallback(key);
	if(!callback){
		std::stringstream ss;
		ss << (uint32_t)key << " is not a valid callback key";
		reportError(__FUNCTION__, ss.str());
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(!callback->loadCallBack(scriptInterface, function_str)){
		reportError(__FUNCTION__, "Can not load callback");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaSetCombatFormula(lua_State *L)
{
	//setCombatFormula(combat, type, mina, minb, maxa, maxb)
	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	double maxb = popFloatNumber(L);
	double maxa = popFloatNumber(L);
	double minb = popFloatNumber(L);
	double mina = popFloatNumber(L);

	formulaType_t type = (formulaType_t)popNumber(L);
	uint32_t combatId = popNumber(L);

	Combat* combat = env->getCombatObject(combatId);

	if(combat){
		combat->setPlayerCombatValues(type, mina, minb, maxa, maxb);

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_COMBAT_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetConditionFormula(lua_State *L)
{
	//setConditionFormula(condition, mina, minb, maxa, maxb)
	ScriptEnviroment* env = getScriptEnv();

	if(env->getScriptId() != EVENT_ID_LOADING){
		reportError(__FUNCTION__, "This function can only be used while loading the script.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	double maxb = popFloatNumber(L);
	double maxa = popFloatNumber(L);
	double minb = popFloatNumber(L);
	double mina = popFloatNumber(L);

	uint32_t conditionId = popNumber(L);

	ConditionSpeed* condition = dynamic_cast<ConditionSpeed*>(env->getConditionObject(conditionId));

	if(condition){
		condition->setFormulaVars(mina, minb, maxa, maxb);

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoCombat(lua_State *L)
{
	//doCombat(cid, combat, param)
	ScriptEnviroment* env = getScriptEnv();

	LuaVariant var = popVariant(L);
	uint32_t combatId = (uint32_t)popNumber(L);
	uint32_t cid = (uint32_t)popNumber(L);

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);

		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	const Combat* combat = env->getCombatObject(combatId);

	if(!combat){
		reportErrorFunc(getErrorDesc(LUA_ERROR_COMBAT_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	if(var.type == VARIANT_NONE){
		reportErrorFunc(getErrorDesc(LUA_ERROR_VARIANT_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	switch(var.type){
		case VARIANT_NUMBER:
		{
			Creature* target = g_game.getCreatureByID(var.number);

			if(!target){
				lua_pushnumber(L, LUA_ERROR);
				return 1;
			}

			if(combat->hasArea()){
				combat->doCombat(creature, target->getPosition());
				//std::cout << "Combat->hasArea()" << std::endl;
			}
			else{
				combat->doCombat(creature, target);
			}
			break;
		}

		case VARIANT_POSITION:
		{
			combat->doCombat(creature, var.pos);
			break;
		}

		case VARIANT_TARGETPOSITION:
		{
			if(combat->hasArea()){
				combat->doCombat(creature, var.pos);
			}
			else{
				combat->postCombatEffects(creature, var.pos);
				g_game.addMagicEffect(var.pos, NM_ME_PUFF);
			}
			break;
		}

		case VARIANT_STRING:
		{
			Player* target = g_game.getPlayerByName(var.text);
			if(!target){
				lua_pushnumber(L, LUA_ERROR);
				return 1;
			}

			combat->doCombat(creature, target);
			break;
		}

		default:
		{
			reportErrorFunc(getErrorDesc(LUA_ERROR_VARIANT_UNKNOWN));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
			break;
		}
	}

	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoAreaCombatHealth(lua_State *L)
{
	//doAreaCombatHealth(cid, type, pos, area, min, max, effect)
	uint8_t effect = (uint8_t)popNumber(L);
	int32_t maxChange = (int32_t)popNumber(L);
	int32_t minChange = (int32_t)popNumber(L);
	uint32_t areaId = popNumber(L);

	PositionEx pos;
	popPosition(L, pos);

	CombatType_t combatType = (CombatType_t)popNumber(L);
	uint32_t cid = (uint32_t)popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);

		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	const AreaCombat* area = env->getCombatArea(areaId);
	if(area || areaId == 0){
		CombatParams params;
		params.combatType = combatType;
		params.impactEffect = effect;
		Combat::doCombatHealth(creature, pos, area, minChange, maxChange, params);

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_AREA_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaDoTargetCombatHealth(lua_State *L)
{
	//doTargetCombatHealth(cid, target, type, min, max, effect)
	uint8_t effect = (uint8_t)popNumber(L);
	int32_t maxChange = (int32_t)popNumber(L);
	int32_t minChange = (int32_t)popNumber(L);
	CombatType_t combatType = (CombatType_t)popNumber(L);
	uint32_t targetCid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);

		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	Creature* target = env->getCreatureByUID(targetCid);
	if(target){
		CombatParams params;
		params.combatType = combatType;
		params.impactEffect = effect;
		Combat::doCombatHealth(creature, target, minChange, maxChange, params);

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoAreaCombatMana(lua_State *L)
{
	//doAreaCombatMana(cid, pos, area, min, max, effect)
	uint8_t effect = (uint8_t)popNumber(L);
	int32_t maxChange = (int32_t)popNumber(L);
	int32_t minChange = (int32_t)popNumber(L);
	uint32_t areaId = popNumber(L);

	PositionEx pos;
	popPosition(L, pos);

	uint32_t cid = (uint32_t)popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);

		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	const AreaCombat* area = env->getCombatArea(areaId);
	if(area || areaId == 0){
		CombatParams params;
		params.impactEffect = effect;
		Combat::doCombatMana(creature, pos, area, minChange, maxChange, params);

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_AREA_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoTargetCombatMana(lua_State *L)
{
	//doTargetCombatMana(cid, target, min, max, effect)
	uint8_t effect = (uint8_t)popNumber(L);
	int32_t maxChange = (int32_t)popNumber(L);
	int32_t minChange = (int32_t)popNumber(L);
	uint32_t targetCid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);

		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	Creature* target = env->getCreatureByUID(targetCid);
	if(target){
		CombatParams params;
		params.impactEffect = effect;
		Combat::doCombatMana(creature, target, minChange, maxChange, params);

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoAreaCombatCondition(lua_State *L)
{
	//doAreaCombatCondition(cid, pos, area, condition, effect)
	uint8_t effect = (uint8_t)popNumber(L);
	uint32_t conditionId = popNumber(L);
	uint32_t areaId = popNumber(L);
	PositionEx pos;
	popPosition(L, pos);
	uint32_t cid = (uint32_t)popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);
		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	const Condition* condition = env->getConditionObject(conditionId);
	if(condition){

		const AreaCombat* area = env->getCombatArea(areaId);

		if(area || areaId == 0){
			CombatParams params;
			params.impactEffect = effect;
			params.condition = condition;
			Combat::doCombatCondition(creature, pos, area, params);

			lua_pushnumber(L, LUA_NO_ERROR);
		}
		else{
			reportErrorFunc(getErrorDesc(LUA_ERROR_AREA_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoTargetCombatCondition(lua_State *L)
{
	//doTargetCombatCondition(cid, target, condition, effect)
	uint8_t effect = (uint8_t)popNumber(L);
	uint32_t conditionId = popNumber(L);
	uint32_t targetCid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);

		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	Creature* target = env->getCreatureByUID(targetCid);
	if(target){
		const Condition* condition = env->getConditionObject(conditionId);
		if(condition){
			CombatParams params;
			params.impactEffect = effect;
			params.condition = condition;
			Combat::doCombatCondition(creature, target, params);

			lua_pushnumber(L, LUA_NO_ERROR);
		}
		else{
			reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoAreaCombatDispel(lua_State *L)
{
	//doAreaCombatDispel(cid, pos, area, type, effect)
	uint8_t effect = (uint8_t)popNumber(L);
	ConditionType_t dispelType = (ConditionType_t)popNumber(L);
	uint32_t areaId = popNumber(L);
	PositionEx pos;
	popPosition(L, pos);
	uint32_t cid = (uint32_t)popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);

		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	const AreaCombat* area = env->getCombatArea(areaId);
	if(area || areaId == 0){
		CombatParams params;
		params.impactEffect = effect;
		params.dispelType = dispelType;
		Combat::doCombatDispel(creature, pos, area, params);

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_AREA_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoTargetCombatDispel(lua_State *L)
{
	//doTargetCombatDispel(cid, target, type, effect)
	uint8_t effect = (uint8_t)popNumber(L);
	ConditionType_t dispelType = (ConditionType_t)popNumber(L);
	uint32_t targetCid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = NULL;

	if(cid != 0){
		creature = env->getCreatureByUID(cid);

		if(!creature){
			reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
	}

	Creature* target = env->getCreatureByUID(targetCid);
	if(target){
		CombatParams params;
		params.impactEffect = effect;
		params.dispelType = dispelType;
		Combat::doCombatDispel(creature, target, params);

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaDoChallengeCreature(lua_State *L)
{
	//doChallengeCreature(cid, target)
	uint32_t targetCid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);

	if(!creature){
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Creature* target = env->getCreatureByUID(targetCid);
	if(target){
		target->challengeCreature(creature);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaDoConvinceCreature(lua_State *L)
{
	//doConvinceCreature(cid, target)
	uint32_t targetCid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);

	if(!creature){
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Creature* target = env->getCreatureByUID(targetCid);
	if(target){
		target->convinceCreature(creature);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaDoAddCondition(lua_State *L)
{
	//doAddCondition(cid, condition)

	uint32_t conditionId = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(!creature){
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Condition* condition = env->getConditionObject(conditionId);
	if(!condition){
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONDITION_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	creature->addCondition(condition->clone());
	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaNumberToVariant(lua_State *L)
{
	//numberToVariant(number)
	LuaVariant var;
	var.type = VARIANT_NUMBER;
	var.number = popNumber(L);

	LuaScriptInterface::pushVariant(L, var);
	return 1;
}

int LuaScriptInterface::luaStringToVariant(lua_State *L)
{
	//stringToVariant(string)
	LuaVariant var;
	var.type = VARIANT_STRING;
	var.text = popString(L);

	LuaScriptInterface::pushVariant(L, var);
	return 1;
}

int LuaScriptInterface::luaPositionToVariant(lua_State *L)
{
	//positionToVariant(pos)
	LuaVariant var;
	var.type = VARIANT_POSITION;
	popPosition(L, var.pos);

	LuaScriptInterface::pushVariant(L, var);
	return 1;
}

int LuaScriptInterface::luaTargetPositionToVariant(lua_State *L)
{
	//targetPositionToVariant(pos)
	LuaVariant var;
	var.type = VARIANT_TARGETPOSITION;
	popPosition(L, var.pos);

	LuaScriptInterface::pushVariant(L, var);
	return 1;
}

int LuaScriptInterface::luaVariantToNumber(lua_State *L)
{
	//variantToNumber(var)
	LuaVariant var = popVariant(L);

	uint32_t number = 0;
	if(var.type == VARIANT_NUMBER){
		number = var.number;
	}

	lua_pushnumber(L, number);
	return 1;
}

int LuaScriptInterface::luaVariantToString(lua_State *L)
{
	//variantToString(var)
	LuaVariant var = popVariant(L);

	std::string text = "";
	if(var.type == VARIANT_STRING){
		text = var.text;
	}

	lua_pushstring(L, text.c_str());
	return 1;
}

int LuaScriptInterface::luaVariantToPosition(lua_State *L)
{
	//luaVariantToPosition(var)
	LuaVariant var = popVariant(L);

	PositionEx pos(0, 0, 0, 0);
	if(var.type == VARIANT_POSITION || var.type == VARIANT_TARGETPOSITION){
		pos = var.pos;
	}

	pushPosition(L, pos, pos.stackpos);
	return 1;
}

int LuaScriptInterface::luaDoChangeSpeed(lua_State *L)
{
	//doChangeSpeed(cid, delta)
	int32_t delta = (int32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);

	if(creature){
		g_game.changeSpeed(creature, delta);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoRemoveCondition(lua_State *L)
{
	//DoRemoveCondition(cid, type)

	uint32_t id = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);

	if(creature){
        if (id == 1){  
        creature->removeCondition(CONDITION_POISON);
        }
        if (id == 2){  
        creature->removeCondition(CONDITION_FIRE);
        } 
        if (id == 3){  
        creature->removeCondition(CONDITION_ENERGY);
        } 
        if (id == 4){  
        creature->removeCondition(CONDITION_LIFEDRAIN);
        } 
        if (id == 5){  
        creature->removeCondition(CONDITION_PARALYZE);
        } 
        if (id == 6){  
        creature->removeCondition(CONDITION_OUTFIT);
        } 
        if (id == 7){  
        creature->removeCondition(CONDITION_INVISIBLE);
        } 
        if (id == 8){  
        creature->removeCondition(CONDITION_LIGHT);
        } 
        if (id == 9){  
        creature->removeCondition(CONDITION_MANASHIELD);
        } 
        if (id == 10){  
        creature->removeCondition(CONDITION_INFIGHT);
        } 
        if (id == 11){  
        creature->removeCondition(CONDITION_DRUNK);
        } 
        if (id == 12){  
        creature->removeCondition(CONDITION_REGENERATION);
        } 
        if (id == 13){  
        creature->removeCondition(CONDITION_SOUL);
        }
        if (id == 14){  
        creature->removeCondition(CONDITION_DROWN);
        } 
        if (id == 15){  
        creature->removeCondition(CONDITION_MUTED);
        }   
        if (id == 16){  
        creature->removeCondition(CONDITION_ATTRIBUTES);
        } 
        if (id == 17){  
        creature->removeCondition(CONDITION_CURSED);
        }
        if (id == 18){  
        creature->removeCondition(CONDITION_FREEZING);
        } 
        if (id == 19){  
        creature->removeCondition(CONDITION_DAZZLED);
        } 
        if (id == 20){  
        creature->removeCondition(CONDITION_POISON);
        creature->removeCondition(CONDITION_FIRE); 
        creature->removeCondition(CONDITION_ENERGY);
        creature->removeCondition(CONDITION_LIFEDRAIN);
        creature->removeCondition(CONDITION_PARALYZE); 
        creature->removeCondition(CONDITION_OUTFIT); 
        creature->removeCondition(CONDITION_INVISIBLE); 
        creature->removeCondition(CONDITION_LIGHT);  
        creature->removeCondition(CONDITION_MANASHIELD);  
        creature->removeCondition(CONDITION_INFIGHT); 
        creature->removeCondition(CONDITION_DRUNK);  
        creature->removeCondition(CONDITION_REGENERATION); 
        creature->removeCondition(CONDITION_SOUL);  
        creature->removeCondition(CONDITION_DROWN); 
        creature->removeCondition(CONDITION_MUTED);
        creature->removeCondition(CONDITION_ATTRIBUTES); 
        creature->removeCondition(CONDITION_CURSED);
        creature->removeCondition(CONDITION_FREEZING);
        creature->removeCondition(CONDITION_DAZZLED);
        }                                                     
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetCreatureOutfit(lua_State *L)
{
	//doSetCreatureOutfit(cid, outfit, time)
	int32_t time = (int32_t)popNumber(L);
	Outfit_t outfit;
	outfit.lookType = getField(L, "lookType");
	outfit.lookHead = getField(L, "lookHead");
	outfit.lookBody = getField(L, "lookBody");
	outfit.lookLegs = getField(L, "lookLegs");
	outfit.lookFeet = getField(L, "lookFeet");
	outfit.lookAddons = getField(L, "lookAddons");
	lua_pop(L, 1);

	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);

	if(creature){
		ReturnValue ret = Spell::CreateIllusion(creature, outfit, time);
		if(ret == RET_NOERROR){
			lua_pushnumber(L, LUA_NO_ERROR);
		}
		else{
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetCreatureOutfit(lua_State *L)
{
	//getCreatureOutfit(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		const Outfit_t outfit = creature->getCurrentOutfit();

		lua_newtable(L);
		setField(L, "lookType", outfit.lookType);
		setField(L, "lookHead", outfit.lookHead);
		setField(L, "lookBody", outfit.lookBody);
		setField(L, "lookLegs", outfit.lookLegs);
		setField(L, "lookFeet", outfit.lookFeet);
		setField(L, "lookAddons", outfit.lookAddons);

		return 1;
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

#ifdef __XID_SEPERATE_ADDONS__
int LuaScriptInterface::luaDoPlayerAddAddon(lua_State* L)
{
	uint32_t addon = popNumber(L);
	uint32_t lookType = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	
	if(player){
		player->addAddon(lookType, addon);
		lua_pushnumber(L, LUA_NO_ERROR);
	}           
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaGetPlayerOutfitAddon(lua_State* L)
{
	uint32_t lookType = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	
	if(player){
		lua_pushnumber(L, player->getOutfitAddon(lookType));
	}           
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}
#endif

int LuaScriptInterface::luaSetMonsterOutfit(lua_State *L)
{
	//doSetMonsterOutfit(cid, name, time)
	int32_t time = (int32_t)popNumber(L);
	std::string name = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);

	if(creature){
		ReturnValue ret = Spell::CreateIllusion(creature, name, time);
		if(ret == RET_NOERROR){
			lua_pushnumber(L, LUA_NO_ERROR);
		}
		else{
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaSetItemOutfit(lua_State *L)
{
	//doSetItemOutfit(cid, item, time)
	int32_t time = (int32_t)popNumber(L);
	uint32_t item = (uint32_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);

	if(creature){
		ReturnValue ret = Spell::CreateIllusion(creature, item, time);
		if(ret == RET_NOERROR){
			lua_pushnumber(L, LUA_NO_ERROR);
		}
		else{
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetGlobalStorageValue(lua_State *L)
{
	//getGlobalStorageValue(valueid)
	uint32_t key = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	int32_t value;
	if(env->getGlobalStorageValue(key, value)){
		lua_pushnumber(L, value);
	}
	else{
		lua_pushnumber(L, -1);
	}
	return 1;
}

int LuaScriptInterface::luaSetGlobalStorageValue(lua_State *L)
{
	//setGlobalStorageValue(valueid, newvalue)
	int32_t value = (int32_t)popNumber(L);
	uint32_t key = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	env->addGlobalStorageValue(key,value);
	lua_pushnumber(L,0);
	return 1;
}

int LuaScriptInterface::luaGetPlayerDepotItems(lua_State *L)
{
	//getPlayerDepotItems(cid, depotid)
	uint32_t depotid = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		const Depot* depot = player->getDepot(depotid, true);
		if(depot){
			lua_pushnumber(L, depot->getItemHoldingCount());
		}
		else{
			reportErrorFunc("Depot not found");
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerSetGuildRank(lua_State *L)
{
	//doPlayerSetGuildRank(cid, rank)
	const char* rank = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->setGuildRank(std::string(rank));
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerSetGuildNick(lua_State *L)
{
	//doPlayerSetGuildNick(cid, nick)
	const char* nick = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->setGuildNick(std::string(nick));
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetGuildId(lua_State *L)
{
	//getGuildId(guild_name)
	const char* name = popString(L);

	uint32_t guildId;
	if(IOPlayer::instance()->getGuildIdByName(guildId, std::string(name))){
		lua_pushnumber(L, guildId);
	}
	else{
		reportErrorFunc("Guild not found");
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoMoveCreature(lua_State *L)
{
	//doMoveCreature(cid, direction)
	uint32_t direction = popNumber(L);
	uint32_t cid = popNumber(L);

	switch(direction){
		case NORTH:
		case SOUTH:
		case WEST:
		case EAST:
		case SOUTHWEST:
		case NORTHWEST:
		case NORTHEAST:
		case SOUTHEAST:
			break;
		default:
			reportErrorFunc("No valid direction");
			lua_pushnumber(L, LUA_ERROR);
			return 1;
	}

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		ReturnValue ret = g_game.internalMoveCreature(creature, (Direction)direction, true);
		lua_pushnumber(L, ret);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaIsPlayer(lua_State *L)
{
	//isPlayer(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getPlayerByUID(cid)){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int LuaScriptInterface::luaIsCreature(lua_State *L)
{
	//isCreature(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getCreatureByUID(cid)){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int LuaScriptInterface::luaIsContainer(lua_State *L)
{
	//isContainer(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(env->getContainerByUID(uid)){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int LuaScriptInterface::luaIsMoveable(lua_State *L)
{
	//isMoveable(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Thing* thing = env->getThingByUID(uid);

	if(thing && thing->isPushable()){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}

	return 1;
}

int LuaScriptInterface::luaGetPlayerByName(lua_State *L)
{
	//getPlayerByName(name)
	const char* name = popString(L);

	ScriptEnviroment* env = getScriptEnv();

	if(Player* player = g_game.getPlayerByName(name)){
		uint32_t cid = env->addThing(player);
		lua_pushnumber(L, cid);
	}
	else{
		lua_pushnumber(L, LUA_NULL);
	}
	return 1;

}

int LuaScriptInterface::luaGetPlayerGUIDByName(lua_State *L)
{
	//getPlayerGUIDByName(name)
	const char* name = popString(L);

	Player* player = g_game.getPlayerByName(name);
	uint32_t value = LUA_NULL;

	if(player){
		value = player->getGUID();
	}
	else{
		uint32_t guid;
		std::string strName(name);
		if(IOPlayer::instance()->getGuidByName(guid, strName)){
			value = guid;
		}
	}

	lua_pushnumber(L, value);
	return 1;
}

int LuaScriptInterface::luaRegisterCreatureEvent(lua_State *L)
{
	//registerCreatureEvent(cid, name)
	const char* name = popString(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		creature->registerCreatureEvent(name);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaGetContainerSize(lua_State *L)
{
	//getContainerSize(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(Container* container = env->getContainerByUID(uid)){
		lua_pushnumber(L, container->size());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONTAINER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetContainerCap(lua_State *L)
{
	//getContainerCap(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(Container* container = env->getContainerByUID(uid)){
		lua_pushnumber(L, container->capacity());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONTAINER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetContainerItem(lua_State *L)
{
	//getContainerItem(uid, slot)
	uint32_t slot = popNumber(L);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	if(Container* container = env->getContainerByUID(uid)){
		Item* item = container->getItem(slot);
		if(item){
			uint32_t uid = env->addThing(item);
			pushThing(L, item, uid);
		}
		else{
			pushThing(L, NULL, 0);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONTAINER_NOT_FOUND));
		pushThing(L, NULL, 0);
	}
	return 1;

}

int LuaScriptInterface::luaDoAddContainerItem(lua_State *L)
{
	//doAddContainerItem(uid, itemid, <optional> count/subtype)
	int32_t parameters = lua_gettop(L);

	uint32_t count = 0;
	if(parameters > 2){
		count = popNumber(L);
	}

	uint16_t itemId = (uint16_t)popNumber(L);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Container* container = env->getContainerByUID(uid);
	if(container){
		const ItemType& it = Item::items[itemId];
		if(it.stackable && count > 100){
			reportErrorFunc("Stack count cannot be higher than 100.");
			count = 100;
		}

		Item* newItem = Item::CreateItem(itemId, count);

		ReturnValue ret = g_game.internalAddItem(container, newItem);
		if(ret != RET_NOERROR){
			delete newItem;
			reportErrorFunc("Could not add item");
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}

		if(newItem->getParent()){
			uint32_t new_uid = env->addThing((Thing*)newItem);
			lua_pushnumber(L, new_uid);
			return 1;
		}
		else{
			//stackable item stacked with existing object, newItem will be released
			lua_pushnumber(L, LUA_NULL);
			return 1;
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONTAINER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}
}

int LuaScriptInterface::luaGetDepotId(lua_State *L)
{
	//getDepotId(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Container* container = env->getContainerByUID(uid);
	if(container){
		Depot* depot = container->getDepot();
		if(depot){
			lua_pushnumber(L, depot->getDepotId());
		}
		else{
			reportErrorFunc("Depot not found.");
			lua_pushnumber(L, LUA_ERROR);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CONTAINER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaIsInArray(lua_State *L)
{
	//isInArray(array, value)
	int32_t value = (int32_t)popNumber(L);
	if(lua_istable(L, -1) == 0){
		lua_pop(L, 1);
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	int i = 1;
	while(1){
		lua_pushnumber(L, i);
		lua_gettable(L, -2);
		if(lua_isnil(L, -1) == 1){
			lua_pop(L, 2);
			lua_pushnumber(L, LUA_FALSE);
			return 1;
		}
		else if(lua_isnumber(L, -1) == 1){
			int32_t array_value = (int32_t)popNumber(L);
			if(array_value == value){
				lua_pop(L, 1);
				lua_pushnumber(L, LUA_TRUE);
				return 1;
			}
		}
		else{
			lua_pop(L, 2);
			lua_pushnumber(L, LUA_ERROR);
			return 1;
		}
		++i;
	}
}

int LuaScriptInterface::luaDoPlayerAddOutfit(lua_State *L)
{
	//doPlayerAddOutfit(cid, looktype, addon)
	uint32_t addon = popNumber(L);
	uint32_t looktype = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->addOutfit(looktype, addon);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerRemOutfit(lua_State *L)
{
	//doPlayerRemOutfit(cid, looktype, addon)
	uint32_t addon = popNumber(L);
	uint32_t looktype = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		player->remOutfit(looktype, addon);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaCanPlayerWearOutfit(lua_State *L)
{
	//canPlayerWearOutfit(cid, looktype, addon)
	uint32_t addon = popNumber(L);
	uint32_t looktype = popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		lua_pushnumber(L, (player->canWear(looktype, addon)? LUA_TRUE : LUA_FALSE));
		return 1;
	}

	reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
	lua_pushnumber(L, LUA_ERROR);
	return 1;
}

int LuaScriptInterface::luaDoCreatureChangeOutfit(lua_State *L)
{
	//doCreatureChangeOutfit(cid, outfit)
	Outfit_t outfit;
	outfit.lookType = getField(L, "lookType");
	outfit.lookHead = getField(L, "lookHead");
	outfit.lookBody = getField(L, "lookBody");
	outfit.lookLegs = getField(L, "lookLegs");
	outfit.lookFeet = getField(L, "lookFeet");
	outfit.lookAddons = getField(L, "lookAddons");
	lua_pop(L, 1);

	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		creature->defaultOutfit = outfit;
		g_game.internalCreatureChangeOutfit(creature, outfit);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoSetCreatureLight(lua_State *L)
{
	//doSetCreatureLight(cid, lightLevel, lightColor, time)
	uint32_t time = popNumber(L);
	uint8_t color = (uint8_t)popNumber(L);
	uint8_t level = (uint8_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		Condition* condition = Condition::createCondition(CONDITIONID_COMBAT, CONDITION_LIGHT, time, level | (color << 8));

		creature->addCondition(condition);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetCreaturePosition(lua_State *L)
{
	//getCreaturePosition(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		Position pos = creature->getPosition();
		uint32_t stackpos = 0;
		if(Tile* tile = creature->getTile()){
			stackpos = tile->__getIndexOfThing(creature);
		}
		pushPosition(L, pos, stackpos);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetCreatureName(lua_State *L)
{
	//getCreatureName(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		lua_pushstring(L, creature->getName().c_str());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaIsItemStackable(lua_State *L)
{
	//isItemStackable(itemid)
	uint32_t itemid = popNumber(L);
	const ItemType& it = Item::items[itemid];
	if(it.stackable){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int LuaScriptInterface::luaIsItemRune(lua_State *L)
{
	//isItemRune(itemid)
	uint32_t itemid = popNumber(L);
	const ItemType& it = Item::items[itemid];
	if(it.isRune()){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int LuaScriptInterface::luaIsItemDoor(lua_State *L)
{
	//isItemDoor(itemid)
	uint32_t itemid = popNumber(L);
	const ItemType& it = Item::items[itemid];
	if(it.isDoor()){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int LuaScriptInterface::luaIsItemContainer(lua_State *L)
{
	//isItemContainer(itemid)
	uint32_t itemid = popNumber(L);
	const ItemType& it = Item::items[itemid];
	if(it.isContainer()){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int LuaScriptInterface::luaIsItemFluidContainer(lua_State *L)
{
	//isItemFluidContainer(itemid)
	uint32_t itemid = popNumber(L);
	const ItemType& it = Item::items[itemid];
	if(it.isFluidContainer()){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int LuaScriptInterface::luaIsItemMoveable(lua_State *L)
{
	uint32_t itemid = popNumber(L);
	const ItemType& it = Item::items[itemid];
	if(it.moveable){
		lua_pushnumber(L, LUA_TRUE);
	}
	else{
		lua_pushnumber(L, LUA_FALSE);
	}
	return 1;
}

int32_t LuaScriptInterface::luaDoPlayerAddPremiumDays(lua_State* L)
{
	//doPlayerAddPremiumDays(cid, days)
	int32_t days = popNumber(L);
	uint32_t cid = popNumber(L);
	ScriptEnviroment* env = getScriptEnv();
	if(Player* player = env->getPlayerByUID(cid))
	{
		Account account = IOAccount::instance()->loadAccount(player->getAccount());
		if(player->premiumDays < 65535)
		{
			if(days >= 0)
			{
				account.premiumDays = std::min((uint32_t)65535, uint32_t(account.premiumDays + (uint32_t)days));
				player->premiumDays = std::min((uint32_t)65535, uint32_t(player->premiumDays + (uint32_t)days));
			}
			else
			{
				account.premiumDays = std::max((uint32_t)0, uint32_t(account.premiumDays + (int32_t)days));
				player->premiumDays = std::max((uint32_t)0, uint32_t(player->premiumDays + (int32_t)days));
			}
			IOAccount::instance()->saveAccount(account);
		}
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else
	{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetItemName(lua_State *L)
{
	//getItemName(itemid)
	uint32_t itemid = popNumber(L);
	const ItemType& it = Item::items[itemid];
	lua_pushstring(L, it.name.c_str());
	return 1;
}

int LuaScriptInterface::luaGetItemDescriptions(lua_State *L)
{
	//getItemDescriptions(itemid)
	//returns the name, the article and the plural name of the item
	uint32_t itemid = popNumber(L);
	const ItemType& it = Item::items[itemid];

	lua_newtable(L);
	setField(L, "name", it.name.c_str());
	setField(L, "article", it.article.c_str());
	setField(L, "plural", it.pluralName.c_str());
	return 1;
}

int LuaScriptInterface::luaGetItemWeight(lua_State *L)
{
	//getItemWeight(uid)
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(!item){
		lua_pushnumber(L, LUA_ERROR);
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		return 1;
	}

	lua_pushnumber(L, item->getWeight());
	return 1;
}

int LuaScriptInterface::luaAddEvent(lua_State *L)
{
	//addEvent(callback, delay, ...)
	ScriptEnviroment* env = getScriptEnv();

	LuaScriptInterface* script_interface = env->getScriptInterface();
	if(!script_interface){
		reportError(__FUNCTION__, "No valid script interface!");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	int32_t parameters = lua_gettop(L);
	if(lua_isfunction(L, -parameters) == 0){ //-parameters means the first parameter from left to right
		reportError(__FUNCTION__, "callback parameter should be a function.");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	LuaTimerEventDesc eventDesc;
	std::list<int> params;
	for(int32_t i = 0; i < parameters-2; ++i){ //-2 because addEvent needs at least two parameters
		params.push_back(luaL_ref(L, LUA_REGISTRYINDEX));
	}
	eventDesc.parameters = params;

	uint32_t delay = std::max((uint32_t)100, popNumber(L));
	eventDesc.function = luaL_ref(L, LUA_REGISTRYINDEX);

	eventDesc.scriptId = env->getScriptId();

	script_interface->m_lastEventTimerId++;
	script_interface->m_timerEvents[script_interface->m_lastEventTimerId] = eventDesc;

	Scheduler::getScheduler().addEvent(createSchedulerTask(delay, boost::bind(&LuaScriptInterface::executeTimerEvent, script_interface, script_interface->m_lastEventTimerId)));

	lua_pushnumber(L, script_interface->m_lastEventTimerId);
	return 1;
}

int LuaScriptInterface::luaStopEvent(lua_State *L)
{
	//stopEvent(eventid)
	uint32_t eventId = popNumber(L);
	ScriptEnviroment* env = getScriptEnv();

	LuaScriptInterface* script_interface = env->getScriptInterface();
	if(!script_interface){
		reportError(__FUNCTION__, "No valid script interface!");
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	LuaTimerEvents::iterator it = script_interface->m_timerEvents.find(eventId);
	if(it != script_interface->m_timerEvents.end()){
		for(std::list<int>::iterator lt = it->second.parameters.begin(); lt != it->second.parameters.end(); ++lt){
			luaL_unref(script_interface->m_luaState, LUA_REGISTRYINDEX, *lt);
		}
		it->second.parameters.clear();
		luaL_unref(script_interface->m_luaState, LUA_REGISTRYINDEX, it->second.function);
		script_interface->m_timerEvents.erase(it);
		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaGetDataDirectory(lua_State *L)
{
	//getDataDir()
	std::string datadir = g_config.getString(ConfigManager::DATA_DIRECTORY);
	lua_pushstring(L, datadir.c_str());
	return 1;
}

int LuaScriptInterface::luaGetCreatureSpeed(lua_State *L)
{
	//getCreatureSpeed(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		lua_pushnumber(L, creature->getSpeed());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetCreatureBaseSpeed(lua_State *L)
{
	//getCreatureBaseSpeed(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		lua_pushnumber(L, creature->getBaseSpeed());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetCreatureTarget(lua_State *L)
{
	//getCreatureTarget(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		Creature* target = creature->getAttackedCreature();
		if(target){
			uint32_t targetCid = env->addThing(target);
			lua_pushnumber(L, targetCid);
		}
		else{
			lua_pushnumber(L, 0);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaGetCreatureHealth(lua_State *L)
{
	//getCreatureHealth(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		lua_pushnumber(L, creature->getHealth());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaGetCreatureMaxHealth(lua_State *L)
{
	//getCreatureMaxHealth(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		lua_pushnumber(L, creature->getMaxHealth());
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaIsPremium(lua_State *L)
{
	//isPremium(cid)
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();
	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(player->isPremium()){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaHasCondition(lua_State *L)
{
	//hasCondition(cid, conditionid)
	ConditionType_t conditionType = (ConditionType_t)popNumber(L);
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(creature){
		if(creature->hasCondition(conditionType)){
			lua_pushnumber(L, LUA_TRUE);
		}
		else{
			lua_pushnumber(L, LUA_FALSE);
		}
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}

	return 1;
}

int LuaScriptInterface::luaHasProperty(lua_State *L)
{
	//hasProperty(uid, prop)
	uint32_t prop = popNumber(L);
	uint32_t uid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Item* item = env->getItemByUID(uid);
	if(!item){
        reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	//Check if the item is a tile, so we can get more accurate properties
	bool hasProp = item->hasProperty((ITEMPROPERTY)prop);
	if(item->getTile() && item->getTile()->ground == item){
		hasProp = item->getTile()->hasProperty((ITEMPROPERTY)prop);
	}

	lua_pushnumber(L, hasProp? LUA_TRUE : LUA_FALSE);
	return 1;
}

int LuaScriptInterface::luaDoSendDistanceShoot(lua_State *L)
{
	//doSendDistanceShoot(frompos, topos, type)
	uint8_t type = (uint8_t)popNumber(L);
	PositionEx toPos;
	popPosition(L, toPos);
	PositionEx fromPos;
	popPosition(L, fromPos);

	ScriptEnviroment* env = getScriptEnv();

	if(fromPos.x == 0xFFFF){
		fromPos = env->getRealPos();
	}
	if(toPos.x == 0xFFFF){
		toPos = env->getRealPos();
	}

	g_game.addDistanceEffect(fromPos, toPos, type);
	lua_pushnumber(L, LUA_NO_ERROR);
	return 1;
}

int LuaScriptInterface::luaGetCreatureMaster(lua_State *L)
{
	//getCreatureMaster(cid)
	//returns the creature's master or itself if the creature isn't a summon
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(!creature){
        reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	Creature* master = creature->getMaster();
	if(!master){
		lua_pushnumber(L, cid);
		return 1;
	}

	uint32_t masterId = env->addThing(master);
	lua_pushnumber(L, masterId);
	return 1;
}

int LuaScriptInterface::luaGetCreatureSummons(lua_State *L)
{
	//getCreatureSummons(cid)
	//returns a table with all the summons of the creature
	uint32_t cid = popNumber(L);

	ScriptEnviroment* env = getScriptEnv();

	Creature* creature = env->getCreatureByUID(cid);
	if(!creature){
		reportErrorFunc(getErrorDesc(LUA_ERROR_CREATURE_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	lua_newtable(L);
	const std::list<Creature*>& summons = creature->getSummons();
	std::list<Creature*>::const_iterator it = summons.begin();
	for(uint32_t i = 1; it != summons.end(); ++it, ++i){
		uint32_t summonCid = env->addThing(*it);
		lua_pushnumber(L, i);
		lua_pushnumber(L, summonCid);
		lua_settable(L, -3);
	}

	return 1;
}

int LuaScriptInterface::luaGetItemIdByName(lua_State *L)
{
	//getItemIdByName(name)
	std::string name = popString(L);

	int32_t itemid = Item::items.getItemIdByName(name);
	if(itemid == -1){
		reportErrorFunc(getErrorDesc(LUA_ERROR_ITEM_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
		return 1;
	}

	lua_pushnumber(L, itemid);
	return 1;
}

int32_t LuaScriptInterface::luaCleanMap(lua_State* L)
{
	//cleanMap()
	lua_pushnumber(L, g_game.getMap()->clean());
	return 1;
}

#ifdef __CHANGE_MAX__
int LuaScriptInterface::luaDoPlayerAddHealthMax(lua_State *L)
{
	//doPlayerAddHealthMax(uid,health)
	int32_t healthChange = (int32_t)popNumber(L);
	uint32_t cid = popNumber(L);
	
	ScriptEnviroment* env = getScriptEnv();
	
	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(healthChange >= 0){
			player->changeHealthMax(healthChange);
		}

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}

int LuaScriptInterface::luaDoPlayerAddManaMax(lua_State *L)
{
	//doPlayerAddHealthMax(uid,health)
	int32_t manaChange = (int32_t)popNumber(L);
	uint32_t cid = popNumber(L);
	
	ScriptEnviroment* env = getScriptEnv();
	
	Player* player = env->getPlayerByUID(cid);
	if(player){
		if(manaChange >= 0){
			player->changeManaMax(manaChange);
		}

		lua_pushnumber(L, LUA_NO_ERROR);
	}
	else{
		reportErrorFunc(getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND));
		lua_pushnumber(L, LUA_ERROR);
	}
	return 1;
}
#endif

const luaL_Reg LuaScriptInterface::luaBitReg[] =
{
	//{"cast", LuaScriptInterface::luaBitCast},
	{"bnot", LuaScriptInterface::luaBitNot},
	{"band", LuaScriptInterface::luaBitAnd},
	{"bor", LuaScriptInterface::luaBitOr},
	{"bxor", LuaScriptInterface::luaBitXor},
	{"lshift", LuaScriptInterface::luaBitLeftShift},
	{"rshift", LuaScriptInterface::luaBitRightShift},
	//{"arshift", LuaScriptInterface::luaBitArithmeticalRightShift},
	{NULL,NULL}
};

int LuaScriptInterface::luaBitNot(lua_State *L)
{
	int number = popNumber(L);
	lua_pushnumber(L, ~number);
	return 1;
}

#define MULTIOP(name, op) \
	int LuaScriptInterface::luaBit##name(lua_State *L) { \
		int n = lua_gettop(L), i, w = popNumber(L); \
		for(i = 2; i <= n; ++i){ \
			w op popNumber(L); \
		} \
		lua_pushnumber(L, w); \
		return 1; \
	}

MULTIOP(And, &=)
MULTIOP(Or, |=)
MULTIOP(Xor, ^=)

#define SHIFTOP(name, op) \
	int LuaScriptInterface::luaBit##name(lua_State *L) { \
		int n2 = popNumber(L), n1 = popNumber(L); \
		lua_pushnumber(L, (n1 op n2)); \
		return 1; \
	}

SHIFTOP(LeftShift, <<)
SHIFTOP(RightShift, >>)
