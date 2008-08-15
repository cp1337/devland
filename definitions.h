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


#ifndef __OTSERV_DEFINITIONS_H__
#define __OTSERV_DEFINITIONS_H__

#include "exception.h"

#if defined(WIN32) && !defined(__WINDOWS__)
#define __WINDOWS__
#endif

#ifdef XML_GCC_FREE
	#define xmlFreeOTSERV(s)	free(s)
#else
	#define xmlFreeOTSERV(s)	xmlFree(s)
#endif

#ifdef __DEBUG_EXCEPTION_REPORT__
	#define DEBUG_REPORT int *a = NULL; *a = 1;
#else
	#ifdef __EXCEPTION_TRACER__
		#define DEBUG_REPORT ExceptionHandler::dumpStack();
	#else
		#define DEBUG_REPORT
	#endif
#endif

#ifdef __USE_SQLITE__
#define SINGLE_SQL_DRIVER
#endif

#ifdef __USE_MYSQL__
#ifdef SINGLE_SQL_DRIVER
#define MULTI_SQL_DRIVERS
#else
#define SINGLE_SQL_DRIVER
#endif
#endif

#ifdef __USE_ODBC__
#ifdef SINGLE_SQL_DRIVER
#define MULTI_SQL_DRIVERS
#else
#define SINGLE_SQL_DRIVER
#endif
#endif

#ifdef __USE_PGSQL__
#ifdef SINGLE_SQL_DRIVER
#define MULTI_SQL_DRIVERS
#else
#define SINGLE_SQL_DRIVER
#endif
#endif

enum passwordType_t{
	PASSWORD_TYPE_PLAIN = 0,
	PASSWORD_TYPE_MD5,
	PASSWORD_TYPE_SHA1,
};

#ifdef __WINDOWS__

#ifndef __FUNCTION__
	#define	__FUNCTION__ __func__
#endif

#define OTSYS_THREAD_RETURN  void
#ifndef EWOULDBLOCK
#define EWOULDBLOCK WSAEWOULDBLOCK
#endif

#ifdef _WIN32_WINNT
#undef _WIN32_WINNT
#endif
//Windows 2000	0x0500
//Windows Xp	0x0501
//Windows 2003	0x0502
//Windows Vista	0x0600
#define _WIN32_WINNT 0x0501

#ifdef __GNUC__
	#include <ext/hash_map>
	#include <ext/hash_set>
	#include <assert.h>
	#define OTSERV_HASH_MAP __gnu_cxx::hash_map
	#define OTSERV_HASH_SET __gnu_cxx::hash_set
	#define ATOI64 atoll

#else
	typedef unsigned long long uint64_t;

	#ifndef NOMINMAX
		#define NOMINMAX
	#endif

	#include <hash_map>
	#include <hash_set>
	#include <limits>
	#include <assert.h>
	#include <time.h>

	#define OTSERV_HASH_MAP stdext::hash_map
	#define OTSERV_HASH_SET stdext::hash_set

	#include <cstring>
	inline int strcasecmp(const char *s1, const char *s2)
	{
		return ::_stricmp(s1, s2);
	}

	inline int strncasecmp(const char *s1, const char *s2, size_t n)
	{
		return ::_strnicmp(s1, s2, n);
	}

	typedef signed long long int64_t;
	typedef unsigned long uint32_t;
	typedef signed long int32_t;
	typedef unsigned short uint16_t;
	typedef signed short int16_t;
	typedef unsigned char uint8_t;

	#define ATOI64 _atoi64

	#pragma warning(disable:4786) // msvc too long debug names in stl
	#pragma warning(disable:4250) // 'class1' : inherits 'class2::member' via dominance
	#pragma warning(disable:4244)
	#pragma warning(disable:4267)
	#pragma warning(disable:4018)

#endif

//*nix systems
#else
	#define OTSYS_THREAD_RETURN void*

	#include <stdint.h>
	#include <string.h>
	#include <ext/hash_map>
	#include <ext/hash_set>
	#include <assert.h>

	#define OTSERV_HASH_MAP __gnu_cxx::hash_map
	#define OTSERV_HASH_SET __gnu_cxx::hash_set

	#define ATOI64 atoll

#endif

#endif
