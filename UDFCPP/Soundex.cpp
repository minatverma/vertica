#include "Vertica.h"

using namespace Vertica;
using namespace std;

const char LIST1[] = "bfpv";
const char LIST2[] = "cgjkqsxz";
const char LIST3[] = "dt";
const char LIST4[] = "l";
const char LIST5[] = "mn";
const char LIST6[] = "r";


bool is_from_group(const char list[], const char c){

  int len = strlen(list);

  for (int i = 0; i < len; i++){
    if (list[i] == c){
      return true;
    }
  }

  return false;
}


int get_soundex_code(const char c){

  if (is_from_group(LIST1, c)) return 1;
  if (is_from_group(LIST2, c)) return 2;
  if (is_from_group(LIST3, c)) return 3;
  if (is_from_group(LIST4, c)) return 4;
  if (is_from_group(LIST5, c)) return 5;
  if (is_from_group(LIST6, c)) return 6;

  return -1;
}

void encode(const char name[], char* soundex){

  // check which soundex code the letter belongs to
  // store the previous result and count the number of soundex

  int prev_code; // soundex code of previous letter
  int tmp_code; // temporary soundex code
  int i = 0; // counter for name
  int j = 0; // counter for soundex
  int len = strlen(name); // length of surname

  // start of soundex code is always the first letter
  soundex[0] = toupper(name[0]);

  // for every letter except the first one
  for (i = 1; i < len; i++){

    // if we got 3 characters in the soudex code, retun the function
    if (j>=3){
      soundex[4] = '\0';
      return;
    }

    // get the soudex and assign to tmp_code
    tmp_code = get_soundex_code(name[i]);

    // if the soudex exists, and its not the same as previous soudex
    if ((tmp_code != -1) && (tmp_code != prev_code)){
      soundex[++j] = tmp_code+'0';
      prev_code = tmp_code;
    }
  }

  // fill the rest with zeros if not enough digits to make a 4 char soudex
  if (j <= 3){
    for (int k = j+1; k < 4; k++){
      soundex[k] = '0';
    }
    soundex[4] = '\0';
  }

}


class Soundex : public ScalarFunction
{
public:

    virtual void processBlock(ServerInterface &srvInterface,
                              BlockReader &argReader,
                              BlockWriter &resWriter)
    {
        try {
            if (argReader.getNumCols() != 1)
                vt_report_error(0, "Function only accept 1 arguments, but %zu provided",
                                argReader.getNumCols());

            do {
                string inStr = argReader.getStringRef(0).str();
                char soundex[6];
                const char *src = inStr.c_str();
                encode(src, soundex);
                soundex[5] = '\0';
                resWriter.getStringRef().copy(soundex);
                resWriter.next();
            } while (argReader.next());
        } catch(exception& e) {
            vt_report_error(0, "Exception while processing block: [%s]", e.what());
        }
    }
};

class SoundexFactory : public ScalarFunctionFactory
{
    virtual ScalarFunction *createScalarFunction(ServerInterface &interface)
    { return vt_createFuncObj(interface.allocator, Soundex); }

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
        returnType.addVarchar(5);
    }
};

RegisterFactory(SoundexFactory);
