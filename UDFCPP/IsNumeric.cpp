/****************************************************************************
 * Scientific notation  1e10    10000000000
 * BINARY scaling       1p10    1024
 * Hexadecimal          0x0abc  2748
 * Float                0.1     0.1
 *
 * Special cases:
 *  - NAN
 *  - INF/INFINITY
 *
 ****************************************************************************/
#include "Vertica.h"

using namespace std;
using namespace Vertica;

class IsNumeric : public ScalarFunction {

    public:
        virtual void processBlock(ServerInterface &srvInterface, BlockReader &argReader, BlockWriter &resWriter) {
            try {
                if (argReader.getNumCols() != 1) {
                    vt_report_error(0, "Function only accept 1 arguments, but %zu provided", argReader.getNumCols());
                }
                do {
                    string value = argReader.getStringRef(0).str();
                    char* pointer;
                    strtod(value.c_str(), &pointer);
                    vbool isNum = (*pointer == 0);
                    resWriter.setBool(isNum);
                    resWriter.next();
                } while (argReader.next());
            } catch(std::exception& e) {
                vt_report_error(0, "Exception while processing block: [%s]", e.what());
            }
        }
};

class IsNumericFactory : public ScalarFunctionFactory {

    virtual ScalarFunction *createScalarFunction(ServerInterface &interface) {
        return vt_createFuncObject<IsNumeric>(interface.allocator); 
    }

    virtual void getPrototype(ServerInterface &interface, ColumnTypes &argTypes, ColumnTypes &returnType) {
        argTypes.addVarchar();
        returnType.addBool();
    }

    virtual void getReturnType(ServerInterface &srvInterface, const SizedColumnTypes &argTypes, SizedColumnTypes &returnType) {
        returnType.addBool("IS_NUMERIC");
    }
};

RegisterFactory(IsNumericFactory);

// daniel=> select str, DECODE(is_numeric(str), 't', 'TRUE', 'f', 'FALSE') from nums ;
//     str    | case  
// -----------+-------
//  0X0DEAD   | TRUE
//  0x0abc    | TRUE
//  1 foo bar | FALSE
//  1P10      | FALSE    <----- err
//  1e10      | TRUE
//  1p10      | FALSE    <----- err
//  40        | TRUE
//  45.0      | TRUE
//  999.999   | TRUE
//  INFINITY  | TRUE
//  Infinity  | TRUE
//  NAN       | TRUE
//  bar       | FALSE
//  egg 4     | FALSE
//  iNf       | TRUE
//  nAn       | TRUE
// (16 rows)
