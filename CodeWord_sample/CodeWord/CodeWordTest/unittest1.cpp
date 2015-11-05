#include "stdafx.h"
#include "CppUnitTest.h"
#include "../CodeWord/CodeWord.h"

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace CodeWordTest
{		
	TEST_CLASS(UnitTest1)
	{
	public:
		
		TEST_METHOD(Initialize)
		{
			codeword cw;
			(void)cw;
		}

		TEST_METHOD(InitList)
		{
			codeword cw{ 4, 12 };
			Assert::AreEqual((size_t) 4ul, cw.length());
			Assert::AreEqual(12ul, cw.bits());
		}

		TEST_METHOD(Equals)
		{
			codeword cw1{ 4, 12 };
			codeword cw2{ 4, 12 };
			Assert::IsTrue(cw1 == cw2);
		}

		TEST_METHOD(LengthNotEquals)
		{
			codeword cw1{ 4, 12 };
			codeword cw2{ 5, 12 };
			Assert::IsTrue(cw1 != cw2);
		}

		TEST_METHOD(BitsNotEquals)
		{
			codeword cw1{ 5, 13 };
			codeword cw2{ 5, 12 };
			Assert::IsTrue(cw1 != cw2);
		}

		TEST_METHOD(IsFullFalse)
		{
			codeword cw{ 12, 8 };
			Assert::IsTrue(!is_full(cw));
		}

		TEST_METHOD(IsFullTrue)
		{
			codeword cw{ CHAR_BIT * sizeof cw.bits(), 8 };
			Assert::IsTrue(is_full(cw));
		}

		TEST_METHOD(FormatLeading0)
		{
			codeword cw{ 12, 5 };
			Assert::AreEqual((std::string)"000000000101", format(cw));
		}

		TEST_METHOD(FormatLeading1)
		{
			codeword cw{ 12, 2048 + 256 + 4 };
			Assert::AreEqual((std::string)"100100000100", format(cw));
		}

		TEST_METHOD(FormatEmpty)
		{
			codeword cw;
			Assert::AreEqual((std::string)"", format(cw));
		}

		TEST_METHOD(ExtendEmptyWith0)
		{
			auto cw = extend(codeword{}, false);
			Assert::AreEqual((size_t)1ul, cw.length());
			Assert::AreEqual(0ul, cw.bits());
		}

		TEST_METHOD(ExtendEmptyWith1)
		{
			auto cw = extend(codeword{}, true);
			Assert::AreEqual((size_t)1ul, cw.length());
			Assert::AreEqual(1ul, cw.bits());
		}

		TEST_METHOD(ExtendLeading0With0)
		{
			auto cw = extend(codeword{ 8, 3 }, false);
			Assert::AreEqual((size_t)9ul, cw.length());
			Assert::AreEqual(6ul, cw.bits());
		}

		TEST_METHOD(ExtendLeading0With1)
		{
			auto cw = extend(codeword{ 8, 3 }, true);
			Assert::AreEqual((size_t)9ul, cw.length());
			Assert::AreEqual(7ul, cw.bits());
		}

		TEST_METHOD(ExtendLeading1With0)
		{
			auto cw = extend(codeword{ 8, 131 }, false); // 10000011
			Assert::AreEqual((size_t)9ul, cw.length());
			Assert::AreEqual(262ul, cw.bits());
		}

		TEST_METHOD(ExtendLeading1With1)
		{
			auto cw = extend(codeword{ 8, 131 }, true); // 10000011
			Assert::AreEqual((size_t)9ul, cw.length());
			Assert::AreEqual(263ul, cw.bits());
		}

	};
}