/**
 * DESCRIPTION: 
 * AUTHOR     : daniel [at] twingo.co.il (aka sKwa)
 * DATE       : 13/08/2012
 *
 **/
 
 /* COMPILING:
  * g++ -D HAVE_LONG_INT_64 -I /opt/vertica/sdk/include \
  *     -Wall -shared -Wno-unused-value -fPIC \
  *     -o NumberingUDF.so SpellOutNumber.cpp /opt/vertica/sdk/include/Vertica.cpp
  */
 
#include <string>
#include "Vertica.h"

// substitution
#define TEN               10
#define TWENTY            20
#define HUNDRED          100
#define THOUSAND        1000
#define MILLION      1000000
#define BILLION   1000000000

using namespace std;
using namespace Vertica;

// constants
const string ONES[10]  = {"zero", "one"   , "two"   , "three"   , "four"    , "five"   , "six"    , "seven"    , "eight"   , "nine"    };
const string TEENS[10] = {"ten" , "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"};
const string TENS[10]  = {"zero", "ten"   , "twenty", "thirty"  , "forty"   , "fifty"  , "sixty"  , "seventy"  , "eighty"  , "ninety"  }; 


string spell_out(int number)
{
	if (number < TEN)
		return ONES[number % TEN];
	
	if (number < TWENTY)
		return TEENS[number % TEN];
		
	if (number < HUNDRED) 
	{
		if (number % TEN == 0)
			return TENS[number / TEN];
		return TENS[number / TEN ] + "-" + ONES[number % TEN];
	}
	
	if (number < THOUSAND)
	{
		if (number % HUNDRED == 0)
			return ONES[number / HUNDRED] + " hundred";
		return ONES[number / HUNDRED] + " hundred " + spell_out(number % HUNDRED);
	}
	
	if (number < MILLION)
	{
		if (number % THOUSAND == 0)
			return spell_out(number / THOUSAND) + " thousand";
		return spell_out(number / THOUSAND) + " thousand " + spell_out(number % THOUSAND);
	}
	
	if (number < BILLION)
	{
		if (number % MILLION == 0)
			return spell_out(number / MILLION) + " million";
		return spell_out(number / MILLION) + " million " + spell_out(number % MILLION);
	}
	
	return "";
}

class SpellOutNumber : public ScalarFunction
{
	public:
			virtual void processBlock(ServerInterface &srvInterface,
				            BlockReader &arg_reader,
					        BlockWriter &res_writer) {
				if (arg_reader.getNumCols() != 1)
					vt_report_error(0, "Function only accept 1 arguments, but %zu provided", arg_reader.getNumCols());

				// While we have inputs to process
				do {
					const vint num = arg_reader.getIntRef(0);

					// check for valid month number
					if (num > BILLION)
					vt_report_error(0, "ERROR: OUT OF RANGE");

					res_writer.getStringRef().copy(spell_out(num));
					res_writer.next();
				} while (arg_reader.next());					
			}
};


class SpellOutNumberFactory : public ScalarFunctionFactory
{
	virtual ScalarFunction *createScalarFunction(ServerInterface &interface)
	{ 
		return vt_createFuncObj(interface.allocator, SpellOutNumber); 
	}

	virtual void getPrototype(ServerInterface &interface,
							   ColumnTypes &argTypes,
							   ColumnTypes &returnType)
	{
		argTypes.addInt();
		returnType.addVarchar();
	}

	virtual void getReturnType(ServerInterface &srvInterface,
								const SizedColumnTypes &argTypes,
								SizedColumnTypes &returnType)
	{
		returnType.addVarchar(250);
	}

};

RegisterFactory(SpellOutNumberFactory);