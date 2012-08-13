/* 
 * Description: returns month date name
 * when 'January' is a first in order.
 *
 * Create Date: May 29, 2012
 * Author     : daniel@twingo.co.il
 * Comiling   :
 * g++ -D HAVE_LONG_INT_64 -I /opt/vertica/sdk/include \
 * -Wall -shared -Wno-unused-value -fPIC               \
 * -o MonthNameUDF.so MonthName.cpp /opt/vertica/sdk/include/Vertica.cpp
 */
#include "Vertica.h"
#include <string>

using namespace Vertica;

const std::string month[] = { 
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
};

/*
 * Converts month number to name.
 */
class MonthName : public ScalarFunction
{
	public:

	/*
	 * This method processes a block of rows in a single invocation.
	 *
	 * The inputs are retrieved via arg_reader
	 * The outputs are returned via arg_writer
	 */
	virtual void processBlock(ServerInterface &srvInterface,
			BlockReader &arg_reader,
			BlockWriter &res_writer)
	{
		// Basic error checking
		if (arg_reader.getNumCols() != 1)
			vt_report_error(0, "Function only accept 1 arguments, but %zu provided", 
					arg_reader.getNumCols());

		// While we have inputs to process
		do {
			const vint month_num = arg_reader.getIntRef(0);

			// check for valid month number
			if (month_num < 1 || month_num > 12)
				vt_report_error(0, "Wrong month");

			res_writer.getStringRef().copy(month[month_num - 1]);
			res_writer.next();
		} while (arg_reader.next());
	}
};

class MonthNameFactory : public ScalarFunctionFactory
{
	// return an instance of MonthName to perform the actual addition.
	virtual ScalarFunction *createScalarFunction(ServerInterface &interface)
	{ return vt_createFuncObj(interface.allocator, MonthName); }

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
		returnType.addVarchar(10);
	}

};

RegisterFactory(MonthNameFactory);
