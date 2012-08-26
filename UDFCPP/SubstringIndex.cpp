/*
 * The SUBSTRING_INDEX function searches a character string for a specified 
 * delimiter string, and returns a substring of the leading or trailing characters, 
 * based on a count of a delimiter that you specify as an argument to the function.
 *
 * dbadmin=> select substring_index('www.example.com', '.', 2);
 *  substring_index 
 *  -----------------
 *   www.example
 *   (1 row)
 *
 *   dbadmin=> select substring_index('www.example.com', '.', -2);
 *    substring_index 
 *    -----------------
 *     example.com
 *     (1 row)
 *
 */
#include <algorithm>
#include <string>
#include "Vertica.h"

using namespace Vertica;
using namespace std;

int min(int a, int b) {
	return a > b ? b : a;
}


/*
 *
 */
class SubstringIndex : public ScalarFunction
{
	public:
	virtual void processBlock(ServerInterface &srvInterface,
			BlockReader &arg_reader,
			BlockWriter &res_writer) {
		if (arg_reader.getNumCols() != 3)
			vt_report_error(0, "Function only accept 1 arguments, but %zu provided", arg_reader.getNumCols());

		const string delim = arg_reader.getStringRef(1).str();
		const vint occur   = arg_reader.getIntRef(2); 
		// While we have inputs to process
		do {
			std::string src = arg_reader.getStringRef(0).str();
			int  len = src.size();
			int  idx = min(src.find(delim), len);
			int  cnt = 0; 
			int  tot = occur;
			char str[idx + 1];
			if (occur < 0) {
				reverse(src.begin(), src.end());
				tot = -occur;
			}

			while (idx < len && ++cnt < tot)
				idx = min(src.find(delim, idx + 1), len);

			for (int i = 0; i < idx; i++)
				str[i] = src[i];
			str[idx] = 0;

			string result = string(str);
			if (occur < 0)
				reverse(result.begin(), result.end());

			res_writer.getStringRef().copy(result);
			res_writer.next();
		} while (arg_reader.next());
	}
};


class SubstringIndexFactory : public ScalarFunctionFactory
{
	virtual ScalarFunction *createScalarFunction(ServerInterface &interface)
	{ return vt_createFuncObj(interface.allocator, SubstringIndex); }

	virtual void getPrototype(ServerInterface &interface,
			ColumnTypes &argTypes,
			ColumnTypes &returnType)
	{
		argTypes.addVarchar();
		argTypes.addVarchar();
		argTypes.addInt();
		returnType.addVarchar();
	}

	virtual void getReturnType(ServerInterface &srvInterface,
			const SizedColumnTypes &argTypes,
			SizedColumnTypes &returnType)
	{
		const VerticaType &t = argTypes.getColumnType(0);
		returnType.addVarchar(t.getStringLength());
	}
};

RegisterFactory(SubstringIndexFactory);
