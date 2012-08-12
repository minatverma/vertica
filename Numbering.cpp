#include "Vertica.h"
#include <string>

using namespace std;
using namespace Vertica;


const std::string DIGITS[][10] = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};
const std::string TWENTY[][10] = {"ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"};

std::string numbering_digit(int num) {
	return DIGITS[0][num % 10];
}

std::string numbering_tens(int num) {
	switch(num % 100) {
		case 20:
			return "twenty";
		case 30:
			return "thirty";
		case 40:
			return "forty";
		case 50:
			return "fifty";
		case 60:
			return "sixty";
		case 70:
			return "seventy";
		case 80:
			return "eighty";
		case 90:
			return "ninety";
		default:
			return "";
	}
}

std::string numbering_tens_helper(int num) {
	num = num % 100;
	if (num > 9 and num < 20)
		return TWENTY[0][num % 10];
	return numbering_tens(num);
}

std::string hundred_helper(int n) {
	std::string res = " ";
	int hundreds = n / 100;
	int tens     = n % 100;
	int digits   = n % 10;
	if (hundreds)
		res += numbering_digit(hundreds) + " hundred ";
	if (tens  > 9) {
		if (tens < 20)
			return res +=  numbering_tens_helper(tens) + " ";
		res += numbering_tens(tens - digits) + " ";
	}
	if (digits)
		res += numbering_digit(digits) + " ";
	return res;
}

std::string numbering(int num) {
	if (num < 10)
		return numbering_digit(num);
	if (num < 1000)
		return hundred_helper(num);
	else if (num < 1000000)
		return numbering(num/1000) + " thousand " + numbering(num%1000);
	else if (num < 1000000000)
		return numbering(num/1000000) + " million " + numbering(num%1000000);
	else
		return "ERROR: OUT OF BOUNDS";
}

class DigitNumbering : public ScalarFunction
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

			// check for valid number
			if (num > 1000000000)
				vt_report_error(0, "ERROR: OUT OF BOUNDS");

			res_writer.getStringRef().copy(numbering(num));
			res_writer.next();
		} while (arg_reader.next());                                  
	}
};

class DigitNumberingFactory : public ScalarFunctionFactory
{
	virtual ScalarFunction *createScalarFunction(ServerInterface &interface)
	{
		return vt_createFuncObj(interface.allocator, DigitNumbering);
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
		returnType.addVarchar(500);
	}

};

RegisterFactory(DigitNumberingFactory);
