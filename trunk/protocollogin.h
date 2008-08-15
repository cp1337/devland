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

#ifndef __OTSERV_PROTOCOL_LOGIN_H__
#define __OTSERV_PROTOCOL_LOGIN_H__

#include "protocol.h"

class NetworkMessage;
class OutputMessage;

class ProtocolLogin : public Protocol
{
public:
	ProtocolLogin(Connection* connection) : Protocol(connection) {}
	virtual ~ProtocolLogin() {}

	virtual void onRecvFirstMessage(NetworkMessage& msg);
	
protected:
	void disconnectClient(uint8_t error, const char* message);
	
	bool parseFirstPacket(NetworkMessage& msg);

	#ifdef __DEBUG_NET_DETAIL__
	virtual void deleteProtocolTask();
	#endif
};

#endif
