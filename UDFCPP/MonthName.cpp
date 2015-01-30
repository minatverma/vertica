/* 
 * File         : MonthName.cpp
 * Description  : Returns name of month.
 * Copyright    : Copyright (c) 2012 Daniel Leybovich
 * Date         : May 29, 2012
 * Author       : Daniel Leybovich
 * Status	: Obsolete, use in "select to_char(date('2015-03-01'), 'Month'); => March"
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

class MonthName : public ScalarFunction {
    
	public:
	
	virtual void processBlock(ServerInterface &srvInterface, BlockReader &arg_reader, BlockWriter &res_writer) {
	    
		if (arg_reader.getNumCols() != 1) {
			vt_report_error(0, "Function only accept 1 arguments, but %zu provided", arg_reader.getNumCols());
		}
		
		do {
			const vint month_num = arg_reader.getIntRef(0);
			if (month_num < 1 || month_num > 12) {
				vt_report_error(0, "Invalid month number");
			}

			res_writer.getStringRef().copy(month[month_num - 1]);
			res_writer.next();
		} while (arg_reader.next());
	}
};

class MonthNameFactory : public ScalarFunctionFactory {
	
	virtual ScalarFunction *createScalarFunction(ServerInterface &interface) {
		return vt_createFuncObj(interface.allocator, MonthName);
	}

	virtual void getPrototype(ServerInterface &interface, ColumnTypes &argTypes, ColumnTypes &returnType) {
		argTypes.addInt();
		returnType.addVarchar();
	}

	virtual void getReturnType(ServerInterface &srvInterface, const SizedColumnTypes &argTypes, SizedColumnTypes &returnType) {
		returnType.addVarchar(10);
	}

};

RegisterFactory(MonthNameFactory);
