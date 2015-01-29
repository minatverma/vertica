/*
 * File         : NormalDistribution.cpp
 * Description  : Gaussian (Normal) Distribution
 * Copyright    : Copyright (c) 2014 Daniel Leybovich
 * Author       : Daniel Leybovich
 * Create Date  : Jan 10, 2014
 * --------------------------------------------------------------------------
 * TODO:
 *   - error handling
 *   - new parameter      -> seed
 *   - column as argument -> return random value per record in col
 */
#include "Vertica.h"
#include <sstream>
#include <random>


using namespace Vertica;
using namespace std;

class NormalDistribution : public TransformFunction {

    vint rows;
    vfloat mean;
    vfloat stddev;

    virtual void setup(ServerInterface &srvInterface, const SizedColumnTypes &argTypes) {
        ParamReader paramReader = srvInterface.getParamReader();
        rows   = paramReader.getIntRef("rows");
        mean   = paramReader.getFloatRef("mean");
        stddev = paramReader.getFloatRef("stddev");
    }

    virtual void processPartition(ServerInterface &srvInterface, PartitionReader &inputReader, PartitionWriter &outputWriter) {

        double rand_val = 0.0;

        try {

            std::default_random_engine generator;
            std::normal_distribution<double> distribution(mean, stddev);

            for (int i = 0; i < rows; i++) {
                rand_val = distribution(generator);
                outputWriter.setFloat(0, rand_val);
                outputWriter.next();
            }

        } catch(exception& e) {
            vt_report_error(0, "Exception while processing partition: [%s]", e.what());
        }
    }
};

class NormalDistributionFactory : public TransformFunctionFactory
{
    virtual void getPrototype(ServerInterface &srvInterface, ColumnTypes &argTypes, ColumnTypes &returnType) {
        returnType.addFloat();
    }

    virtual void getReturnType(ServerInterface &srvInterface, const SizedColumnTypes &inputTypes, SizedColumnTypes &outputTypes) {
        outputTypes.addFloat("RAND_VALUE");
    }

    virtual void getParameterType(ServerInterface &srvInterface, SizedColumnTypes &parameterTypes) {
        parameterTypes.addInt("rows");
        parameterTypes.addFloat("mean");
        parameterTypes.addFloat("stddev");
    }

    virtual TransformFunction *createTransformFunction(ServerInterface &srvInterface) { 
        return vt_createFuncObject<NormalDistribution>(srvInterface.allocator); 
    }

};

RegisterFactory(NormalDistributionFactory);
