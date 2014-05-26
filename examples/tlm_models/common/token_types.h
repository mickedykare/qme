#ifndef __TOKEN_TYPES_H__
#define __TOKEN_TYPES_H__
#endif
#include "packing_util.h"
#include <iostream>

using namespace packing_util;

/*******************************************
*** Enumerated type containing what TOKEN's 
*** that are available in the system
********************************************/
enum token_type_e {
    TOKEN_TYPE_0 = 0,
    TOKEN_TYPE_1 = 1
	 
};


/**************************************
*** Structs describing each TOKEN that 
*** are available in the system
***************************************/
/*** STRUCT TOKEN_TYPE_0_s ***/
struct token_type_0_s {
	uint32t field1;
	uint32t field2;
	token_type_0_s() {
		field1=0;
		field2=0;
	}
	static const int length_c = 16;
	static const token_type_e type_c = TOKEN_TYPE_0;
};

inline packing_util::pack_base& operator<<(packing_util::pack_base& p, const token_type_0_s& s)
{
	p << packing_util::setwidth(32) << s.field1 << packing_util::setwidth(32) << s.field2;
	return p;
}
 
inline packing_util::pack_base& operator>>(packing_util::pack_base& p, token_type_0_s& s)
{
	p >> packing_util::setwidth(32) >> s.field1 >> packing_util::setwidth(32) >>s.field2;
	return p;
}

inline bool operator==(const token_type_0_s& s1, const token_type_0_s& s2) 
{
	return ((s1.field1==s2.field2) && (s1.field2==s2.field2));
}
inline bool operator!=(const token_type_0_s& s1, const token_type_0_s& s2) 
{
	return !(s1== s2);
}

inline std::ostream& operator<<(std::ostream& os, const token_type_0_s& s)
{
	os << "TOKEN_TYPE_0" << std::endl 
		<< "field1: 0x" << std::hex << s.field1 << std::endl
		<< "field2: 0x" << std::hex << s.field2 << std::endl;
	return os;
}

/*** STRUCT TOKEN_TYPE_1_s ***/
struct token_type_1_s {
	uint32t field1;
	uint32t field2;
	token_type_1_s() {
		field1=0;
		field2=0;
	}
	static const int length_c = 16;
	static const token_type_e type_c = TOKEN_TYPE_1;
};

inline packing_util::pack_base& operator<<(packing_util::pack_base& p, const token_type_1_s& s)
{
	p << s.field1 << s.field2;
 	return p;
}

inline packing_util::pack_base& operator>>(packing_util::pack_base& p, token_type_1_s& s)
{
	p >> packing_util::setwidth(32) >> s.field1 >> packing_util::setwidth(32) >>s.field2;
	return p;
}

inline bool operator==(const token_type_1_s& s1, const token_type_1_s& s2) 
{
	return ((s1.field1== s2.field2) && (s1.field2==s2.field2));
}
inline bool operator!=(const token_type_1_s& s1, const token_type_1_s& s2) 
{
	return !(s1== s2);
}

inline std::ostream& operator<<(std::ostream& os, const token_type_1_s& s)
{
	os << "TOKEN_TYPE_1" << std::endl 
		<< "field1: 0x" << std::hex << s.field1 << std::endl
		<< "field2: 0x" << std::hex << s.field2 << std::endl;
	return os;
}

