/*
 * File         : ConcatRow.cpp
 * Description  : Concatenates columns to single string.
 * Copyright    : Copyright (c) 2015 Daniel Leybovich
 * Author       : Daniel Leybovich
 * Date         : Aug 13, 2012
 */

// STDLIB imports
#include <string>
#include <sstream>
#include <iostream>
#include "Vertica.h"

// GLOBAL CONSTANTS
#define  LENGTH     64000

// NAMESPACE SCOPE
using namespace std;
using namespace Vertica;

class ConcatRow : public ScalarFunction {

        string sep;

        // TODO: get cols data type here
        virtual void setup(ServerInterface &srvInterface, const SizedColumnTypes &argTypes) {
            ParamReader paramReader = srvInterface.getParamReader();
            sep = paramReader.getStringRef("sep").str();
        }
    public:

        virtual void processBlock(ServerInterface &srvInterface, BlockReader &argReader, BlockWriter &resWriter) {
            try {
                const SizedColumnTypes &inTypes = argReader.getTypeMetaData();
                vector<size_t> argCols;
                inTypes.getArgumentColumns(argCols);
                ostringstream oss;
                do {
                    for (uint i = 0; i < argCols.size(); ++i) {
                        const VerticaType &vt = inTypes.getColumnType(i);

                        // VARCHAR/CHAR/VARBINARY/BINARY/LONG VARCHAR/LONG VARBINARY data types
                        if (vt.isStringType()) {
                            oss << argReader.getStringRef(i).str();

                            // INT
                        } else if (vt.isInt()) {
                            oss << argReader.getIntRef(i);

                            // BOOLEAN
                        } else if (vt.isBool()) {
                            oss << (argReader.getBoolRef(i) ? "TRUE" : "FALSE");
                        }

                        // don't append separator after a last column
                        if (i < argCols.size() - 1) {
                            oss << sep;
                        }
                    }
                    VString &summary = resWriter.getStringRef();
                    summary.copy(oss.str());
                    resWriter.next();
                } while (argReader.next());
            } catch(exception& e) {
                vt_report_error(0, "Exception while processing block: [%s]", e.what());
            }
        }
};

class ConcatRowFactory : public ScalarFunctionFactory {

    virtual ScalarFunction *createScalarFunction(ServerInterface &interface) { 
        return vt_createFuncObject<ConcatRow>(interface.allocator); 
    }

    virtual void getPrototype(ServerInterface &interface, ColumnTypes &argTypes, ColumnTypes &returnType) {
        argTypes.addAny();
        returnType.addVarchar();
    }

    virtual void getReturnType(ServerInterface &srvInterface, const SizedColumnTypes &argTypes, SizedColumnTypes &returnType) {
        returnType.addVarchar(LENGTH + 1);
    }

    virtual void getParameterType(ServerInterface &srvInterface, SizedColumnTypes &parameterTypes) {
        parameterTypes.addVarchar(16, "sep");
    }

};

RegisterFactory(ConcatRowFactory);
