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

PWD=`pwd`
echo ''>$LOG

## abort function - more readable
## [ $? -ne 0 ] && echo 'ERROR' 2>&1 && exit 1
function abort_if 
{
    if [ ${?} -ne 0 ]; then
        echo `date +'[ %H:%M:%S ]'`'[ ERROR ] '${1} 2>&1
        exit 1
    fi      
}


## since I do avg I don't use in Bash::time or /sbin/time
function test_function 
{
    start_time=`date +'%s.%N'`
    $VSQL -o /dev/null -c "select "${1}"(m_num) from UDFSimpleBencmark;"
    end_time=`date +'%s.%N'`
    echo ${end_time}'-'${start_time} | bc
    return;
}


function test_avg 
{
    fname=${1}
    echo -e "\nTEST function : ${fname}"
    avg=0
    for i in `seq 1 ${ATTEMPS}`;do
        avg=${avg}+`test_function ${fname}`
    done
    avg=`echo ${avg} | sed -e 's/\(+[0-9]\+.[0-9][0-9]\)[0-9]\+/\1/g' -e 's/^0+//'`
    echo -e "Execution time for ${ATTEMPS} attemps:"
    echo -e "---"
    for attemp in `echo ${avg} | sed 's/+/\n/g'`; do
        echo $attemp
    done 
    echo -e "---"
    echo 'AVG: '`echo 'print (' $avg')/'5 | python`' [sec]'
    echo -e "\n"
    return;
}

## create cpp library
g++ -D HAVE_LONG_INT_64   \
	-I /opt/vertica/sdk/include             \
	-Wall -shared -Wno-unused-value -fPIC   \
	-o MonthNameLib.so ./MonthName.cpp /opt/vertica/sdk/include/Vertica.cpp
abort_if 'failed to compile'


## load library to Vertica 
$VSQL -o /dev/null -c "create library MonthNameLib AS '"${PWD}/MonthNameLib.so"';"
abort_if 'failed create cpp library'


## create function 
$VSQL -o /dev/null -c "create function month_name_cpp as language 'C++' name 'MonthNameFactory' library MonthNameLib;"
abort_if 'failed create cpp function'


## sql func
$VSQL -f ${PWD}/MonthName.sql >> $LOG

## create random data
echo '     
import random
import sys

for i in range('$LINES'):
    print random.randint(1,12)

' | python > ${DATA}

cat ${DATA} > ${DATA}_foo
cat ${DATA}_foo >> ${DATA}
cat ${DATA} >> ${DATA}_foo
cat ${DATA}_foo >> ${DATA}
abort_if 'failed create data test file'


## create table
$VSQL -c "create table UDFSimpleBencmark( m_num int );" >>$LOG
abort_if 'failed create table'


## load data
$VSQL -c "copy UDFSimpleBencmark from '"${DATA}"' direct;">>$LOG
abort_if 'failed load data to Vertica'

## test functions
test_avg ${CPP_FUNC}
test_avg ${DEC_FUNC}
test_avg ${CASE_FUNC}

## clear
echo -n 'Clear working directory..........'
$VSQL -c "drop library MonthNameLib cascade;" >> $LOG
$VSQL -c "drop table UDFSimpleBencmark;">>$LOG
$VSQL -c "drop function month_name_case(int);">>$LOG
$VSQL -c "drop function month_name_decode(int);">>$LOG
rm -rf MonthNameLib.so
echo -e "DONE"
rm -f ${DATA}
rm -f ${DATA}_foo

