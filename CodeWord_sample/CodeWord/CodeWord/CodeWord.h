// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the CODEWORD_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// CODEWORD_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef CODEWORD_EXPORTS
#define CODEWORD_API __declspec(dllexport)
#else
#define CODEWORD_API __declspec(dllimport)
#endif

#include <cstddef>
#include <string>

// This class is exported from the CodeWord.dll
class CODEWORD_API codeword {
public:
	codeword(size_t length, unsigned long bits);
	codeword() : codeword{ 0, 0 }
	{ }

	size_t length() { return length_; }
	unsigned long bits() { return bits_; }
private:
	size_t length_;
	unsigned long bits_;
};

//extern CODEWORD_API int nCodeWord;

CODEWORD_API bool operator==(codeword, codeword);
CODEWORD_API bool operator!=(codeword, codeword);
CODEWORD_API std::string format(codeword);
CODEWORD_API bool is_full(codeword);
CODEWORD_API codeword extend(codeword, bool);