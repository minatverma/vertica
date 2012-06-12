from ctypes import *

# load library
libtest = cdll.LoadLibrary('./libtest.so.1.0')

# create struct account
class account(Structure):
	_fields_ = [("acc_num", c_int, 4),("balance",c_int, 4)]

# create array of accounts
arr = (account * 2)()                        # equals to: account arr[2]

# do manipulation on array
print libtest.add_accounts(pointer(arr), 1)  # arr[1] <==> second element

# print array via C
libtest.print_accs(pointer(arr), 1)          # arr[1] <==> second element

