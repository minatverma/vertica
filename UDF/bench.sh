#!/bin/bash

VSQL=/opt/vertica/bin/vsql
DATA=/tmp/bench.data
LOG=/tmp/bench.log
LINES=1000000
ATTEMPS=5

CPP_FUNC='month_name_cpp'
CASE_FUNC='month_name_case'
DEC_FUNC='month_name_decode'
RFUNC='month_name_rfunc'


## abort function - more readable
## [ $? -ne 0 ] && echo 'ERROR' 2>&1 && exit 1
function abort_if 
{
    if [ $? -ne 0 ]; then
        echo `date +'[ %H:%M:%S ]'`'[ ERROR ] '$1 2>&1
        exit 1
    fi      
}


## since I do avg I don't use in Bash::time or /sbin/time
function test_function 
{
    sql_query='select '"$1"'(m_num) from UDFSimpleBencmark;'
    
    start_time=`date +'%s.%N'`
    $VSQL -c '"'${sql_query}'"' >/dev/null
    end_time=`date +'%s.%N'`
    
    echo ${end_time} - ${start_time} | bc
}


function test_avg 
{
    echo -e "TEST function : "${1}"\n"
    avg=0
    for i in `seq 1 $ATTEMPS`;do
        avg=${avg}+`test_func ${1}`
    done
    avg=`echo ${avg} | sed -e 's/\(+[0-9]\+.[0-9][0-9]\)[0-9]\+/\1/g' -e 's/^0+//'`
    echo -e "Execution time for ${ATTEMPS} :\n"
    for attemp in `echo ${avg} | sed 's/+/\n/g'`; do
        echo $attemp
    done
    echo -e "-------------\n"
    echo -e ${avg} / 5 | bc
}

## create cpp library
g++ -D HAVE_LONG_INT_64                         \ 
	-I /opt/vertica/sdk/include             \
	-Wall -shared -Wno-unused-value -fPIC   \
	-o MonthNameLib.so MonthName.cpp /opt/vertica/sdk/include/Vertica.cpp
abort_if 'failed to compile'


## load library to Vertica 
$VSQL -c "create library MonthNameLib AS '/home/dbadmin/MonthNameLib.so'"
abort_if 'failed create cpp library'


## create function 
$VSQL -c "create function month_name_cpp as language 'C++' name 'MonthNameFactory' library MonthNameLib;"
abort_if 'failed create cpp function'


## create random data
for i in `seq 1 $LINES`; do 
	echo `date +'%N'`' % 12 + 1' | bc
done > ${DATA}
abort_if 'failed create data test file'


## create table
$VSQL -c "create table if not exists UDFSimpleBencmark ( m_num int );"
abort_if 'failed create table'


## load data
$VSQL -c "copy UDFSimpleBencmark from '"${DATA}"' direct;"
abort_if 'failed load data to Vertica'


test_avg ${CPP_FUNC}
test_avg ${DEC_FUNC}
test_avg ${CASE_FUNC}

$VSQL -c "drop table if exists UDFSimpleBencmark"
rm -f /tmp/int_1mil.dat


