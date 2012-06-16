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
function abort_if {
    if [ $? -ne 0 ]; then
        echo `date +'[ %H:%M:%S ]'`'[ ERROR ] '$1 2>&1
        exit 1
    fi      
    return 0
}

function test_function {
    start_time=`date +'%s.%N'`
    SQL_QUERY='select '"$1"'(m_num) from UDFSimpleBencmark;'
    $VSQL -c '"'${SQL_QUERY}'"' >/dev/null
    end_time=`date +'%s.%N'`
    execution_time=`echo ${end_time} - ${start_time} | bc`
    return $execution_time
}

## create cpp library
g++ -D HAVE_LONG_INT_64 -I /opt/vertica/sdk/include -Wall -shared -Wno-unused-value \
	-fPIC -o MonthNameLib.so MonthName.cpp /opt/vertica/sdk/include/Vertica.cpp
abort_if 'compilation failed'


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


## 
echo -e "SQL month name DECODE bench:\n"
avg=0
for i in `seq 1 $ATTEMPS`;do
	avg=$avg+`test_func ${DEC_FUNC}`
done
avg=`echo ${avg} / 5 | bc`


echo -e "\\\timing\n\\o /dev/null\nselect month_name_decode(m_num) from UDFSimpleBencmark;" | \
	$VSQL | sed 's/^Time:.\+All rows formatted: \([^ ]\+\).\+/\1/'

echo -e "\n---\n"

echo -e "SQL month name CASE bench:\n"
echo -e "\\\timing\n\\o /dev/null\nselect month_name_case(m_num) from UDFSimpleBencmark;" | \
	        $VSQL | sed 's/^Time:.\+All rows formatted: \([^ ]\+\).\+/\1/'

echo -e "\n---\n"


echo -e "SQL month name CPP bench:\n"
echo -e "\\\timing\n\\o /dev/null\nselect month_name_cpp(m_num) from UDFSimpleBencmark;" | \
	                $VSQL | sed 's/^Time:.\+All rows formatted: \([^ ]\+\).\+/\1/'
echo -e "\n---\n"

$VSQL -c "drop table if exists UDFSimpleBencmark"
rm -f /tmp/int_1mil.dat


