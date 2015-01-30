/*
 * File         : PolymorphicUnpivot.cpp
 * Description  : The UNPIVOT function rotates data from columns into rows.
 * Copyright    : Copyright (c) 2012 Daniel Leybovich
 * Author       : Daniel Leybovich
 * Date         : Sep 12, 2013
 */
#include "Vertica.h"

using namespace Vertica;
using namespace std;

// Global constants block
const int MIN_COLS = 2;
const int MAX_COL_NAME_LEN = 128;              // vertica limitations
const string COL_NAME_ARG = "name";
const string DEFAULT_COL_NAME = "UNPIVOT_COL";


void validateArguments(PartitionReader const &inputReader) {

    const size_t numCols = inputReader.getNumCols();
    const SizedColumnTypes &inputTypes = inputReader.getTypeMetaData();
    const VerticaType &firstColType = inputTypes.getColumnType(0);

    if (numCols < MIN_COLS) {
        vt_report_error(0, "Function must get 2 and more arguments, but %zu provided.", numCols);
    }

    for (size_t i = 0; i < numCols; i++) {
        if (firstColType.getTypeStr() != inputTypes.getColumnType(i).getTypeStr()) {
            vt_report_error(0, "All fields must be same data type(except length/scale/persition).");
        }
    }
}

void unpivot(PartitionReader &inputReader, PartitionWriter &outputWriter) {
    do {
        for (size_t i = 0; i < inputReader.getNumCols(); i++) {
            if (inputReader.getStringRef(i).isNull()) {
                outputWriter.setNull(i);
            } else {
                outputWriter.copyFromInput(0, inputReader, i);
            }
            outputWriter.next();
        }
    } while (inputReader.next());
}


class PolymorphicUnpivot : public TransformFunction {

    virtual void processPartition(ServerInterface &srvInterface, PartitionReader &inputReader, PartitionWriter &outputWriter) {
        try {

            validateArguments(inputReader);

            unpivot(inputReader, outputWriter);

        } catch (exception& e) {
            vt_report_error(0, "Exception while processing partition: [%s]", e.what());
        }
    }
};


class PolymorphicUnpivotFactory : public TransformFunctionFactory {

    virtual void getPrototype(ServerInterface &srvInterface, ColumnTypes &argTypes, ColumnTypes &returnType) {
        argTypes.addAny();
        returnType.addAny();
    }

    virtual void getReturnType(ServerInterface &srvInterface, const SizedColumnTypes &inputTypes, SizedColumnTypes &outputTypes) {
        size_t obj_idx = 0;
        int32 max_size = 0;
        for (size_t i = 0; i < inputTypes.getColumnCount(); i++) {
            int32 candidate = inputTypes.getColumnType(i).getMaxSize();
            if (candidate > max_size) {
                max_size = candidate;
                obj_idx = i;
            }
        }
        string colName = DEFAULT_COL_NAME;
        ParamReader paramReader = srvInterface.getParamReader();
        if (paramReader.containsParameter(COL_NAME_ARG)) {
            colName = paramReader.getStringRef(COL_NAME_ARG).str();
        }
        outputTypes.addArg(inputTypes.getColumnType(obj_idx), colName);
    }

    virtual void getParameterType(ServerInterface &srvInterface, SizedColumnTypes &parameterTypes) {
        parameterTypes.addVarchar(MAX_COL_NAME_LEN, COL_NAME_ARG);
    }

    virtual TransformFunction *createTransformFunction(ServerInterface &srvInterface) {
        return vt_createFuncObj(srvInterface.allocator, PolymorphicUnpivot); 
    }
};

RegisterFactory(PolymorphicUnpivotFactory);
