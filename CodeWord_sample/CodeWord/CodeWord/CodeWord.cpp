// CodeWord.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "CodeWord.h"
#include <climits>


// This is an example of an exported variable
//CODEWORD_API int nCodeWord=0;

CODEWORD_API bool operator==(codeword cw1, codeword cw2)
{
	return cw1.length() == cw2.length() && cw1.bits() == cw2.bits();
}

CODEWORD_API bool operator!=(codeword cw1, codeword cw2)
{
	return !(cw1 == cw2);
}

CODEWORD_API bool is_full(codeword cw)
{
	return cw.length() == CHAR_BIT * sizeof(cw.bits());
}

std::string format(codeword cw)
{
	std::string result;

	auto mask = 1 << (cw.length() - 1);

	for (size_t index = 0; index < cw.length(); ++index) {
		if (cw.bits() & mask)
			result += '1';
		else
			result += '0';

		mask >>= 1;
	}

	return result;
}

codeword extend(codeword old, bool bit)
{
//	Expects(!is_full(old));

	return codeword{ old.length() + 1, (old.bits() << 1) + bit };
}

// This is the constructor of a class that has been exported.
// see CodeWord.h for the class definition
codeword::codeword(size_t length, unsigned long bits)
	: length_{ length }, bits_{ bits }
{
    return;
}
