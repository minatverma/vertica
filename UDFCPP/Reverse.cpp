#include <algorithm>
#include <string>
#include "Vertica.h"


using namespace std;
using namespace Vertica;

string _reverse(string str) {
        reverse(str.begin(), str.end());
        return str;
}

class ReverseString : public ScalarFunction
{
        public:
        virtual void processBlock(ServerInterface &srvInterface,
                        BlockReader &arg_reader,
                        BlockWriter &res_writer) {
                if (arg_reader.getNumCols() != 1)
                        vt_report_error(0, "Function only accept 1 arguments, but %zu provided", arg_reader.getNumCols());

                // While we have inputs to process
                do {
                        std::string  inStr = arg_reader.getStringRef(0).str();
                        res_writer.getStringRef().copy(_reverse(inStr));
                        res_writer.next();
                } while (arg_reader.next());
        }
};


class ReverseStringFactory : public ScalarFunctionFactory
{
    virtual ScalarFunction *createScalarFunction(ServerInterface &interface)
    { return vt_createFuncObj(interface.allocator, ReverseString); }

    virtual void getPrototype(ServerInterface &interface,
                              ColumnTypes &argTypes,
                              ColumnTypes &returnType)
    {
        argTypes.addVarchar();
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

RegisterFactory(ReverseStringFactory);

