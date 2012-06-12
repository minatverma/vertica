#include <stdio.h>

struct account {
	int acc_num;
	int balance;
};


int add_accounts(struct account *acc, int nums) {
	int i = 0;
	for (i = 0; i <= nums; ++i) {
		acc[i].acc_num = 100 + i;
		acc[i].balance = 10000 + i;
	}
	return 0;
}

void print_accs(struct account *acc, int nums) {
	int i = 0;
	for (i = 0; i <= nums; ++i) {
		printf("Acc num:\t %d\n", acc[i].acc_num) ;
		printf("Balance:\t %d\n", acc[i].balance);
	}

}
