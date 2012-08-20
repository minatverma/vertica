#include <string>
#include <stdlib.h>
#include <time.h>

#include "Vertica.h"

using namespace Vertica;

const char alphanum[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";


class RandomString : public ScalarFunction
{
        public:
        virtual void processBlock(ServerInterface &srvInterface,
                        BlockReader &arg_reader,
                        BlockWriter &res_writer) {
                if (arg_reader.getNumCols() != 1)
                        vt_report_error(0, "Function only accept 1 arguments, but %zu provided", arg_reader.getNumCols());
                
                const vint len = arg_reader.getIntRef(0);
                // While we have inputs to process
                do {
                        char s[len + 1];
			for (int i = 0; i < len; ++i) 
				s[i] = alphanum[rand() % (sizeof(alphanum) - 1)];
			s[len] = 0;
			std::string mystring = std::string(s);
                        res_writer.getStringRef().copy(mystring);
                        res_writer.next();
                } while (arg_reader.next());
        }
};


class RandomStringFactory : public ScalarFunctionFactory
{
    virtual ScalarFunction *createScalarFunction(ServerInterface &interface)
    { return vt_createFuncObj(interface.allocator, RandomString); }

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
        returnType.addVarchar(256);
    }
};

RegisterFactory(RandomStringFactory);
