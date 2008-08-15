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


#ifndef __OTSERV_CREATURE_H__
#define __OTSERV_CREATURE_H__

#include "definitions.h"

#include "templates.h"
#include "position.h"
#include "condition.h"
#include "const.h"
#include "tile.h"
#include "enums.h"
#include "creatureevent.h"

#define EVENT_CREATURE_INTERVAL 500

#include <list>

typedef std::list<Condition*> ConditionList;

enum slots_t {
	SLOT_WHEREEVER = 0,
	SLOT_FIRST = 1,
	SLOT_HEAD = SLOT_FIRST,
	SLOT_NECKLACE = 2,
	SLOT_BACKPACK = 3,
	SLOT_ARMOR = 4,
	SLOT_RIGHT = 5,
	SLOT_LEFT = 6,
	SLOT_LEGS = 7,
	SLOT_FEET = 8,
	SLOT_RING = 9,
	SLOT_AMMO = 10,
	SLOT_DEPOT = 11,
	SLOT_LAST = SLOT_DEPOT
};

struct FindPathParams{
	bool fullPathSearch;
	bool needReachable;
	uint32_t targetDistance;
};

enum ZoneType_t{
	ZONE_PROTECTION,
	ZONE_NOPVP,
	ZONE_PVP,
	ZONE_NOLOGOUT,
	ZONE_NORMAL
};

class Map;
class Thing;
class Container;
class Player;
class Monster;
class Npc;
class Item;

//////////////////////////////////////////////////////////////////////
// Defines the Base class for all creatures and base functions which
// every creature has

class Creature : public AutoID, virtual public Thing
{
protected:
	Creature();
public:
	virtual ~Creature();

	virtual Creature* getCreature() {return this;};
	virtual const Creature* getCreature()const {return this;};
	virtual Player* getPlayer() {return NULL;};
	virtual const Player* getPlayer() const {return NULL;};
	virtual Npc* getNpc() {return NULL;};
	virtual const Npc* getNpc() const {return NULL;};
	virtual Monster* getMonster() {return NULL;};
	virtual const Monster* getMonster() const {return NULL;};

    #ifdef __PB_GMINVISIBLE__
	virtual bool isGmInvis() const {return false;}
    #endif

	virtual const std::string& getName() const = 0;
	virtual const std::string& getNameDescription() const = 0;
	virtual std::string getDescription(int32_t lookDistance) const;

	void setID(){this->id = auto_id | this->idRange();}
	void setRemoved() {isInternalRemoved = true;}

	virtual uint32_t idRange() = 0;
	uint32_t getID() const { return id; }
	virtual void removeList() = 0;
	virtual void addList() = 0;

	virtual bool canSee(const Position& pos) const;
	virtual bool canSeeCreature(const Creature* creature) const;

	virtual RaceType_t getRace() const {return RACE_NONE;}
	Direction getDirection() const { return direction;}
	void setDirection(Direction dir) { direction = dir;}

	const Position& getMasterPos() const { return masterPos;}
	void setMasterPos(const Position& pos, uint32_t radius = 1) { masterPos = pos; masterRadius = radius;}

	virtual int getThrowRange() const {return 1;};
	virtual bool isPushable() const {return (getSleepTicks() <= 0);};
	virtual bool isRemoved() const {return isInternalRemoved;};
	virtual bool canSeeInvisibility() const { return false;}

	int64_t getSleepTicks() const{
		int64_t delay;
		int stepDuration = getStepDuration();
		if(lastMove != 0)
			delay = (((int64_t)(lastMove)) + ((int64_t)(stepDuration))) - ((int64_t)(OTSYS_TIME()));
		else
			delay = 0;
		return delay;
	}

	int64_t getEventStepTicks() const;
	int getStepDuration() const;

	uint32_t getSpeed() const {int32_t n = baseSpeed + varSpeed; return std::max(n, (int32_t)1);}
	void setSpeed(int32_t varSpeedDelta){ varSpeed = varSpeedDelta; }

	void setBaseSpeed(uint32_t newBaseSpeed) {baseSpeed = newBaseSpeed;}
	int getBaseSpeed() {return baseSpeed;}

	virtual int32_t getHealth() const {return health;}
	virtual int32_t getMaxHealth() const {return healthMax;}
	virtual int32_t getMana() const {return mana;}
	virtual int32_t getMaxMana() const {return manaMax;}

	const Outfit_t getCurrentOutfit() const {return currentOutfit;}
	const void setCurrentOutfit(Outfit_t outfit) {currentOutfit = outfit;}
	const Outfit_t getDefaultOutfit() const {return defaultOutfit;}
	bool isInvisible() const {return hasCondition(CONDITION_INVISIBLE);}
	ZoneType_t getZone() const {
		const Tile* tile = getTile();
		if(tile->hasFlag(TILESTATE_PROTECTIONZONE)){
			return ZONE_PROTECTION;
		}
		else if(tile->hasFlag(TILESTATE_NOPVPZONE)){
			return ZONE_NOPVP;
		}
		else if(tile->hasFlag(TILESTATE_PVPZONE)){
			return ZONE_PVP;
		}
		else{
			return ZONE_NORMAL;
		}
	}

	//walk functions
	bool startAutoWalk(std::list<Direction>& listDir);
	void addEventWalk();
	void stopEventWalk();

	//walk events
	void onWalk(Direction& dir);
	virtual void onWalkAborted() {};
	virtual void onWalkComplete() {};

	//follow functions
	virtual const Creature* getFollowCreature() { return followCreature; };
	virtual bool setFollowCreature(Creature* creature, bool fullPathSearch = false);

	//follow events
	virtual void onFollowCreature(const Creature* creature) {};

	//combat functions
	Creature* getAttackedCreature() { return attackedCreature; }
	virtual bool setAttackedCreature(Creature* creature);
	virtual BlockType_t blockHit(Creature* attacker, CombatType_t combatType, int32_t& damage,
		bool checkDefense = false, bool checkArmor = false);

	void setMaster(Creature* creature) {master = creature;}
	Creature* getMaster() {return master;}
	bool hasMaster() const {return master != NULL;}
	const Creature* getMaster() const {return master;}

	void setSummon(bool _summon) { summon = _summon;}
	bool isSummon() const {return summon;}

	virtual void addSummon(Creature* creature);
	virtual void removeSummon(const Creature* creature);
	const std::list<Creature*>& getSummons() {return summons;}

	virtual int32_t getArmor() const {return 0;}
	virtual int32_t getDefense() const {return 0;}

	bool addCondition(Condition* condition);
	bool addCombatCondition(Condition* condition);
	void removeCondition(ConditionType_t type, ConditionId_t id);
	void removeCondition(ConditionType_t type);
	void removeCondition(Condition* condition);
	void removeCondition(const Creature* attacker, ConditionType_t type);
	Condition* getCondition(ConditionType_t type, ConditionId_t id) const;
	void executeConditions(uint32_t interval);
	bool hasCondition(ConditionType_t type) const;
	virtual bool isImmune(ConditionType_t type) const;
	virtual bool isImmune(CombatType_t type) const;
	virtual bool isSuppress(ConditionType_t type) const;
	virtual uint32_t getDamageImmunities() const { return 0; }
	virtual uint32_t getConditionImmunities() const { return 0; }
	virtual uint32_t getConditionSuppressions() const { return 0; }
	virtual bool isAttackable() const { return true;};

	virtual void changeHealth(int32_t healthChange);
	virtual void changeMana(int32_t manaChange);

    #ifdef __CHANGE_MAX__
    virtual void changeHealthMax(int32_t healthChangeMax);
	virtual void changeManaMax(int32_t manaChangeMax);
	#endif

	virtual void drainHealth(Creature* attacker, CombatType_t combatType, int32_t damage);
	virtual void drainMana(Creature* attacker, int32_t manaLoss);

	virtual bool challengeCreature(Creature* creature) {return false;};
	virtual bool convinceCreature(Creature* creature) {return false;};

	virtual void onDie();
	virtual int32_t getGainedExperience(Creature* attacker) const;
	virtual bool addDamagePoints(Creature* attacker, int32_t damagePoints);
	bool hasBeenAttacked(uint32_t attackerId);

	//combat event functions
	virtual void onAddCondition(ConditionType_t type);
	virtual void onAddCombatCondition(ConditionType_t type);
	virtual void onEndCondition(ConditionType_t type);
	virtual void onTickCondition(ConditionType_t type, bool& bRemove);
	virtual void onCombatRemoveCondition(const Creature* attacker, Condition* condition);
	virtual void onAttackedCreature(Creature* target);
	virtual void onAttacked();
	virtual void onAttackedCreatureDrainHealth(Creature* target, int32_t points);
	virtual void onAttackedCreatureKilled(Creature* target);
	virtual void onKilledCreature(Creature* target);
	virtual void onGainExperience(int32_t gainExperience);
	virtual void onGainSharedExperience(int32_t gainExp);
	virtual void onAttackedCreatureBlockHit(Creature* target, BlockType_t blockType);
	virtual void onBlockHit(BlockType_t blockType);
	virtual void onChangeZone(ZoneType_t zone);
	virtual void onAttackedCreatureChangeZone(ZoneType_t zone);

	virtual void getCreatureLight(LightInfo& light) const;
	virtual void setNormalCreatureLight();
	void setCreatureLight(LightInfo& light) {internalLight = light;}

	void addEventThink();
	void stopEventThink();
	virtual void onThink(uint32_t interval);
	virtual void onAttacking(uint32_t interval);
	virtual void onWalk();
	virtual bool getNextStep(Direction& dir);

	virtual void onAddTileItem(const Position& pos, const Item* item);
	virtual void onUpdateTileItem(const Position& pos, uint32_t stackpos,
		const Item* oldItem, const ItemType& oldType, const Item* newItem, const ItemType& newType);
	virtual void onRemoveTileItem(const Position& pos, uint32_t stackpos, const Item* item);
	virtual void onUpdateTile(const Position& pos);

	virtual void onCreatureAppear(const Creature* creature, bool isLogin);
	virtual void onCreatureDisappear(const Creature* creature, uint32_t stackpos, bool isLogout);
	virtual void onCreatureMove(const Creature* creature, const Position& newPos, const Position& oldPos,
		uint32_t oldStackPos, bool teleport);

	virtual void onAttackedCreatureDissapear(bool isLogout) {};
	virtual void onFollowCreatureDissapear(bool isLogout) {};

	virtual void onCreatureTurn(const Creature* creature, uint32_t stackPos) { };
	virtual void onCreatureSay(const Creature* creature, SpeakClasses type, const std::string& text) { };

	virtual void onCreatureChangeOutfit(const Creature* creature, const Outfit_t& outfit) { };
	virtual void onCreatureChangeVisible(const Creature* creature, bool visible);

	virtual void onPlacedCreature() {};
	virtual void onRemovedCreature() {};

	virtual WeaponType_t getWeaponType() {return WEAPON_NONE;}
	virtual bool getCombatValues(int32_t& min, int32_t& max) {return false;}
	int32_t getAttackStrength() const {return attackStrength;}
	int32_t getDefenseStrength() const {return defenseStrength;}

	uint32_t getSummonCount() const {return summons.size();}
	void setDropLoot(bool _lootDrop) {lootDrop = _lootDrop;}

	//creature script events
	bool registerCreatureEvent(const std::string& name);
	
	//corpse functions
    #ifdef __CORPSE_SYSTEM__ 
    int ownerBody;
    int moveTicks;
    #endif

protected:
	int32_t health, healthMax;
	int32_t mana, manaMax;
	int32_t attackStrength;
	int32_t defenseStrength;

	Outfit_t currentOutfit;
	Outfit_t defaultOutfit;

	Position masterPos;
	int32_t masterRadius;
	uint64_t lastMove;
	uint32_t lastStepCost;
	uint32_t baseSpeed;
	int32_t varSpeed;
	bool lootDrop;

	Direction direction;

	uint32_t eventCheck;

	Creature* master;
	bool summon;
	std::list<Creature*> summons;

	ConditionList conditions;

	//creature script events
	uint32_t scriptEventsBitField;
	bool hasEventRegistered(CreatureEventType_t event){
		return (0 != (scriptEventsBitField & ((uint32_t)1 << event)));
	}
	typedef std::list<CreatureEvent*> CreatureEventList;
	CreatureEventList eventsList;
	CreatureEventList::iterator findEvent(CreatureEventType_t type);
	CreatureEvent* getCreatureEvent(CreatureEventType_t type);

	//follow variables
	Creature* followCreature;
	uint32_t eventWalk;
	std::list<Direction> listWalkDir;
	bool internalUpdateFollow;
	bool internalValidatePath;

	//combat variables
	Creature* attackedCreature;

	struct damageBlock_t{
		int32_t total;
		int64_t ticks;
	};

	typedef std::map<uint32_t, damageBlock_t> DamageMap;
	DamageMap damageMap;
	uint32_t lastHitCreature;
	uint32_t blockCount;
	uint32_t blockTicks;

	void onCreatureDisappear(const Creature* creature, bool isLogout);
	virtual void doAttacking(uint32_t interval) {};

	LightInfo internalLight;
	void validateWalkPath();
	virtual int32_t getLostExperience() const { return 0; };
	virtual double getDamageRatio(Creature* attacker) const;
	bool getKillers(Creature** lastHitCreature, Creature** mostDamageCreature);
	virtual void dropLoot(Container* corpse) {};
	virtual uint16_t getLookCorpse() const { return 0; }
	virtual void getPathSearchParams(const Creature* creature, FindPathParams& fpp) const;
	virtual void die() {};
	virtual void dropCorpse();
	virtual Item* getCorpse();

	friend class Game;
	friend class Map;
	friend class Commands;
	friend class LuaScriptInterface;

	uint32_t id;
	bool isInternalRemoved;
};


#endif
