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


#ifndef __OTSERV_RSA_H__
#define __OTSERV_RSA_H__

#include "otsystem.h"

#include "gmp.h"

class RSA{
public:
	RSA();
	~RSA();
	void setKey(const char* p, const char* q, const char* d);
	bool setKey(const std::string& file);
	bool decrypt(char* msg, int32_t size);
	
	int32_t getKeySize();
	void getPublicKey(char* buffer);
	
protected:
	
	bool m_keySet;
	
	OTSYS_THREAD_LOCKVAR rsaLock;
	
	//use only GMP
	mpz_t m_p, m_q, m_u, m_d, m_dp, m_dq, m_mod;
};

#endif
