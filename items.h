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


#ifndef __OTSERV_ITEMS_H__
#define __OTSERV_ITEMS_H__


#include "definitions.h"
#include "const.h"
#include "enums.h"
#include "itemloader.h"
#include <map>


//[ added for beds system
#include "position.h"
//]


#define SLOTP_WHEREEVER 0xFFFFFFFF
#define SLOTP_HEAD 1
#define	SLOTP_NECKLACE 2
#define	SLOTP_BACKPACK 4
#define	SLOTP_ARMOR 8
#define	SLOTP_RIGHT 16
#define	SLOTP_LEFT 32
#define	SLOTP_LEGS 64
#define	SLOTP_FEET 128
#define	SLOTP_RING 256
#define	SLOTP_AMMO 512
#define	SLOTP_DEPOT 1024
#define	SLOTP_TWO_HAND 2048

enum ItemTypes_t {
	ITEM_TYPE_NONE = 0,
	ITEM_TYPE_DEPOT,
	ITEM_TYPE_MAILBOX,
	ITEM_TYPE_TRASHHOLDER,
	ITEM_TYPE_CONTAINER,
	ITEM_TYPE_DOOR,
	ITEM_TYPE_MAGICFIELD,
	ITEM_TYPE_TELEPORT,
	ITEM_TYPE_BED,
	ITEM_TYPE_KEY,
	ITEM_TYPE_LAST
};

struct Abilities{
	Abilities()
	{
		absorbPercentAll = 0;
		absorbPercentPhysical = 0;
		absorbPercentFire = 0;
		absorbPercentEnergy = 0;
		absorbPercentEarth = 0;
		absorbPercentLifeDrain = 0;
		absorbPercentManaDrain = 0;
		absorbPercentDrown = 0;
		absorbPercentIce = 0;
		absorbPercentHoly = 0;
		absorbPercentDeath = 0;

		memset(skills, 0, sizeof(skills));

		memset(stats, 0 , sizeof(stats));
		memset(statsPercent, 0, sizeof(statsPercent));

		speed = 0;
#ifdef __CHANGE_MAX__
		addHp = 0;
		addMana = 0;
#endif
		manaShield = false;
		invisible = false;
		conditionImmunities = 0;
		conditionSuppressions = 0;

		regeneration = false;
		healthGain = 0;
		healthTicks = 0;

		manaGain = 0;
		manaTicks = 0;
	};

	//damage abilities modifiers
	int16_t absorbPercentAll;
	int16_t absorbPercentPhysical;
	int16_t absorbPercentFire;
	int16_t absorbPercentEnergy;
	int16_t absorbPercentEarth;
	int16_t absorbPercentLifeDrain;
	int16_t absorbPercentManaDrain;
	int16_t absorbPercentDrown;
	int16_t absorbPercentIce;
	int16_t absorbPercentHoly;
	int16_t absorbPercentDeath;

	//extra skill modifiers
	int32_t skills[SKILL_LAST + 1];

	//stats modifiers
	int32_t stats[STAT_LAST + 1];
	int32_t statsPercent[STAT_LAST + 1];

	int32_t speed;
#ifdef __CHANGE_MAX__
	int32_t addHp;
	int32_t addMana;
#endif
	bool manaShield;
	bool invisible;

	bool regeneration;
	uint32_t healthGain;
	uint32_t healthTicks;

	uint32_t manaGain;
	uint32_t manaTicks;

	uint32_t conditionImmunities;
	uint32_t conditionSuppressions;
};

class Condition;

class ItemType {
private:
	//It is private because calling it can cause unexpected results
	ItemType(const ItemType& it){};

public:
	ItemType();
	~ItemType();

	itemgroup_t group;
	ItemTypes_t type;

	bool isGroundTile() const {return (group == ITEM_GROUP_GROUND);}
	bool isContainer() const {return (group == ITEM_GROUP_CONTAINER);}
	bool isSplash() const {return (group == ITEM_GROUP_SPLASH);}
	bool isFluidContainer() const {return (group == ITEM_GROUP_FLUID);}

    bool isDoor() const {return (type == ITEM_TYPE_DOOR);}
    bool isMagicField() const {return (type == ITEM_TYPE_MAGICFIELD);}
    bool isTeleport() const {return (type == ITEM_TYPE_TELEPORT);}
	bool isKey() const {return (group == ITEM_GROUP_KEY);}
	bool isRune() const {return clientCharges;}
	bool isDepot() const {return (type == ITEM_TYPE_DEPOT);}
	bool isMailbox() const {return (type == ITEM_TYPE_MAILBOX);}
	bool isTrashHolder() const {return (type == ITEM_TYPE_TRASHHOLDER);}
	bool hasSubType() const {return (isFluidContainer() || isSplash() || stackable || charges != 0);}

	//[ added for beds system
	bool isBed() const {return type == ITEM_TYPE_BED;}

	Direction bedPartnerDir;
	uint16_t maleSleeperID;
	uint16_t femaleSleeperID;
	uint16_t noSleeperID;
	//]

	uint16_t id;
	uint16_t clientId;

	std::string    name;
	std::string    article;
	std::string    pluralName;
	std::string    description;
	unsigned short maxItems;
	float          weight;
	bool           showCount;
	WeaponType_t   weaponType;
	Ammo_t         amuType;
	ShootType_t    shootType;
	MagicEffectClasses magicEffect;
	int            attack;
	int            defence;
	int            extraDef;
	int            armor;
	uint16_t       slot_position;
	bool           isVertical;
	bool           isHorizontal;
	bool           isHangable;
	bool           allowDistRead;
	bool           clientCharges;
	uint16_t       speed;
	int32_t        decayTo;
	uint32_t       decayTime;
	bool           stopTime;
	RaceType_t     corpseType;

	bool            canReadText;
	bool            canWriteText;
	unsigned short  maxTextLen;
	unsigned short  writeOnceItemId;

	bool            stackable;
	bool            useable;
	bool            moveable;
	bool            alwaysOnTop;
	int             alwaysOnTopOrder;
	bool            pickupable;
	bool            rotable;
	int             rotateTo;

	int             runeMagLevel;
	int             runeLevel;
	std::string     runeSpellName;

    uint32_t        wieldInfo; 
    std::string     vocationString; 
    uint32_t                minReqLevel; 
    uint32_t        minReqMagicLevel; 

	int lightLevel;
	int lightColor;

	bool floorChangeDown;
	bool floorChangeNorth;
	bool floorChangeSouth;
	bool floorChangeEast;
	bool floorChangeWest;
	bool hasHeight;

	bool blockSolid;
	bool blockPickupable;
	bool blockProjectile;
	bool blockPathFind;

	unsigned short transformEquipTo;
	unsigned short transformDeEquipTo;
	bool showDuration;
	bool showCharges;
	uint32_t charges;
	int32_t breakChance;
	int32_t hitChance;
	int32_t maxHitChance;
	uint32_t shootRange;
	AmmoAction_t ammoAction;
	int32_t fluidSource;
	
	int attackSpeedAdd;
	int attackSpeedRemove;
	
	Abilities abilities;

	Condition* condition;
	CombatType_t combatType;
	bool replaceable;
};

template<typename A>
class Array{
public:
	Array(uint32_t n);
	~Array();

	A getElement(uint32_t id);
	const A getElement(uint32_t id) const;
	void addElement(A a, uint32_t pos);

	uint32_t size() {return m_size;}

private:
	A* m_data;
	uint32_t m_size;
};



class Items{
public:
	Items();
	~Items();

	bool reload();
	void clear();

	int loadFromOtb(std::string);

	const ItemType& operator[](int32_t id) const {return getItemType(id);}
	const ItemType& getItemType(int32_t id) const;
	ItemType& getItemType(int32_t id);
	const ItemType& getItemIdByClientId(int32_t spriteId) const;

	int32_t getItemIdByName(const std::string& name);

	static uint32_t dwMajorVersion;
	static uint32_t dwMinorVersion;
	static uint32_t dwBuildNumber;

	bool loadFromXml(const std::string& datadir);

	void addItemType(ItemType* iType);
	
	const ItemType* getElement(uint32_t id) const {return items.getElement(id);}

	uint32_t size() {return items.size();}

protected:
	typedef std::map<int32_t, int32_t> ReverseItemMap;
	ReverseItemMap reverseItemMap;

	Array<ItemType*> items;
	std::string m_datadir;
};

#endif
