#!/bin/bash

VSQL=/opt/vertica/bin/vsql
DATA=/tmp/bench.data
LOG=/tmp/bench.log


CPP='_cpp'
CASE='_case'
DECODE='_decode'

##
## compile MonthName.cpp
##
g++ -D HAVE_LONG_INT_64 -I /opt/vertica/sdk/include -Wall -shared -Wno-unused-value \
	-fPIC -o MonthNameLib.so MonthName.cpp /opt/vertica/sdk/include/Vertica.cpp

##
## create random data
##
echo -e '
import random
for i in xrange(1000000):
    print random.randint(1,12)
' | python $DATA

##
## create table
##
$VSQL -c "create table if not exists UDFSimpleBencmark ( m_num int )"

##
## load data
##
$VSQL -c "copy UDFSimpleBencmark from '/tmp/int_1mil.dat' direct"

##
## create C++ shared library
##
$VSQL -c "create library MonthNameLib AS '/home/dbadmin/MonthNameLib.so'"
$VSQL -c "create function month_name_cpp as language 'C++' name 'MonthNameFactory' library MonthNameLib;"

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


