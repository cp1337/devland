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

#include "definitions.h"
#include "ioaccount.h"
#include "game.h"

#include <algorithm>
#include <functional>
#include <sstream>

#include "database.h"
#include <iostream>
#include <iomanip>

#include "configmanager.h"

extern ConfigManager g_config;
extern Game g_game;

Account IOAccount::loadAccount(uint32_t accno, bool preLoad /*= false*/)
{
	Account acc;

	Database* db = Database::instance();
	DBQuery query;
	DBResult* result;

	query << "SELECT `id`, `password`, `premdays`, `premend`, `key`, `warnings` FROM `accounts` WHERE `id` = " << accno;
	if((result = db->storeQuery(query.str())))
	{
		acc.accnumber = result->getDataInt("id");
		acc.password = result->getDataString("password");
		acc.premiumDays = result->getDataInt("premdays");
		acc.premEnd = result->getDataInt("premend");
		acc.recoveryKey = result->getDataString("key");
		acc.warnings = result->getDataInt("warnings");
		query.str("");
		db->freeResult(result);
		if(preLoad)
			return acc;

		query << "SELECT `name` FROM `players` WHERE `account_id` = " << accno;
		if((result = db->storeQuery(query.str())))
		{
			do
			{
				std::string ss = result->getDataString("name");
				acc.charList.push_back(ss.c_str());
			}
			while(result->next());
			db->freeResult(result);
			acc.charList.sort();
		}
	}
	return acc;
}

bool IOAccount::saveAccount(Account acc)
{
	Database* db = Database::instance();
	DBQuery query;
	query << "UPDATE `accounts` SET `premdays` = " << acc.premiumDays << ", `warnings` = " << acc.warnings << ", `premend` = " << acc.premEnd << " WHERE `id` = " << acc.accnumber;
	return db->executeQuery(query.str());
}

bool IOAccount::removePremium(Account account)
{
	uint64_t timeNow = time(NULL);
	if(account.premiumDays > 0 && account.premiumDays < 65535)
	{
		uint32_t days = (uint32_t)std::ceil((timeNow - account.premEnd) / 86400);
		if(days > 0)
		{
			if(account.premiumDays < days)
				account.premiumDays = 0;
			else
				account.premiumDays -= days;

			account.premEnd = timeNow;
		}
	}
	else
		account.premEnd = timeNow;

	if(!saveAccount(account))
		std::cout << "> ERROR: Failed to save account: " << account.accnumber << "!" << std::endl;
}

bool IOAccount::updatePremiumDays()
{
	Database* db = Database::instance();
	//Start the transaction
	DBTransaction trans(db);
	if(!trans.begin())
		return false;

	DBResult* result;
	DBQuery query;

	query << "SELECT `id` FROM `accounts` WHERE `premend` <= " << time(NULL) - 86400;
	if(result = db->storeQuery(query.str()))
	{
		do
			removePremium(loadAccount(result->getDataInt("id"), true));
		while(result->next());
		db->freeResult(result);
		query.str("");
	}
	//End the transaction
	return trans.commit();
}

bool IOAccount::getPassword(uint32_t accno, const std::string &name, std::string &password)
{
	Database* db = Database::instance();
	DBQuery query;
	DBResult* result;

	query << "SELECT `accounts`.`password` AS `password` FROM `accounts`, `players` WHERE `accounts`.`id` = " << accno << " AND `accounts`.`id` = `players`.`account_id` AND `players`.`name` = " << db->escapeString(name);
	if((result = db->storeQuery(query.str()))){
		password = result->getDataString("password");
		db->freeResult(result);
		return true;
	}

	return false;
}
