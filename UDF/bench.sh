#!/bin/bash

VSQL=/opt/vertica/bin/vsql
DATA=/tmp/bench.data
LOG=/tmp/bench.log
LINES=1000000

FUNC_NAME='month_name'
CPP_FUNC='_cpp'
CASE_FUNC='_case'
DEC_FUNC='_decode'
RFUNC='_rfunc'
LAST_COMAND=''

# [ $? -ne 0 ] && echo 'ERROR' 2>&1 && exit -1
function abort 
{
    if [ $? -ne 0 ]; then
        echo `date +'[ %H:%M:%S ]'`'[ ERROR ] '$1
        exit 1
    fi      
    return 0
}

##
## create cpp library
##
g++ -D HAVE_LONG_INT_64 -I /opt/vertica/sdk/include -Wall -shared -Wno-unused-value \
	-fPIC -o MonthNameLib.so MonthName.cpp /opt/vertica/sdk/include/Vertica.cpp
abort 'compilation failed'


##
## load library create Vertica UFF cpp function
##
$VSQL -c "create library MonthNameLib AS '/home/dbadmin/MonthNameLib.so'"
abort 'failed create cpp library'

$VSQL -c "create function month_name_cpp as language 'C++' name 'MonthNameFactory' library MonthNameLib;"
abort 'failed create cpp function'


##
## create random data
##
for i in `seq 1 $LINES`; do 
	echo `date +'%N'`' % 12 + 1' | bc
done > ${DATA}

##
## create table
##
$VSQL -c "create table if not exists UDFSimpleBencmark ( m_num int );"

##
## load data
##
$VSQL -c "copy UDFSimpleBencmark from '"${DATA}"' direct;"


# measurement
echo -e "SQL month name DECODE bench:\n"
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


