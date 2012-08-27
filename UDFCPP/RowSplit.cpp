/* -= TWINGO LTD 2006-2012 (www.twingo.co.il) =- */

/* 
 * Description : Splits a string to rows
 * Author      : daniel@twingo.co.il
 * Create Date : Aug 27, 2012
 */
#include "Vertica.h"
#include <sstream>

using namespace Vertica;
using namespace std;

// in general split a string to rows is a same as to array
class StringTokenizer : public TransformFunction
{
	virtual void processPartition(ServerInterface &srvInterface, 
			PartitionReader &inputReader, 
			PartitionWriter &outputWriter)
	{
		try {
			if (inputReader.getNumCols() != 2)
				vt_report_error(0, "Function only accepts 2 argument, but %zu provided", inputReader.getNumCols());

			do {
				const VString &sentence  = inputReader.getStringRef(0);
				const VString &delimiter = inputReader.getStringRef(1);

				// If input delimiter is NULL, then output is NULL as well
				if (delimiter.isNull()) // todo empty string validation
				{
					VString &word = outputWriter.getStringRef(0);
					if (sentence.isNull())
						word.setNull();
					outputWriter.next();
				}
				else 
				{
					string str = sentence.str();
					string del = delimiter.str();
					string word;
					int    idx = str.find(del, 0);
					int d_size = del.size();

					while (idx != string::npos) {       // while delimiter is found

						word = str.substr(0, idx);  // extract token
						str.erase(0, idx + d_size); // remove token + delimiter
						idx = str.find(del, 0);     // find next

						if (!word.empty()) {        // output result
							VString &out = outputWriter.getStringRef(0);
							out.copy(word);
							outputWriter.next();
						}
					}

					if (!str.empty()) {                 // last token - dirty workaround
						VString &out2 = outputWriter.getStringRef(0);
						out2.copy(str);             // VString::out not local?
						outputWriter.next();
					}
				}
			} while (inputReader.next());
		} catch(exception& e) {
			// Standard exception. Quit.
			vt_report_error(0, "Exception while processing partition: [%s]", e.what());
		}
	}
};

class TokenFactory : public TransformFunctionFactory
{
	// Tell Vertica that we take in a row with 1 string, and return a row with 1 string
	virtual void getPrototype(ServerInterface &srvInterface, ColumnTypes &argTypes, ColumnTypes &returnType)
	{
		argTypes.addVarchar();
		argTypes.addVarchar();
		returnType.addVarchar();
	}

	// Tell Vertica what our return string length will be, given the input
	// string length
	virtual void getReturnType(ServerInterface &srvInterface, 
			const SizedColumnTypes &inputTypes, 
			SizedColumnTypes &outputTypes)
	{
		// Error out if we're called with anything but 1 argument
		if (inputTypes.getColumnCount() != 2)
			vt_report_error(0, "Function only accepts 2 argument, but %zu provided", inputTypes.getColumnCount());

		int input_len = inputTypes.getColumnType(0).getStringLength();

		// Our output size will never be more than the input size
		outputTypes.addVarchar(input_len, "words");
	}

	virtual TransformFunction *createTransformFunction(ServerInterface &srvInterface)
	{ return vt_createFuncObj(srvInterface.allocator, StringTokenizer); }

};

RegisterFactory(TokenFactory);
