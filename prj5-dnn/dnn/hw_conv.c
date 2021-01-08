#include "printf.h"
#include "trap.h"
#include "mul.h"
#include "perf_cnt.h"

#define HW_ACC_START	0x0000
#define HW_ACC_DONE		0x0008
#define HW_BASE_ADDR	0x40040000


int main()
{
	//TODO: Please add your own software to control hardware accelerator
	
	Result res;
	res.msec=0;
	bench_prepare(&res);

	volatile char* base = (void*)HW_BASE_ADDR;
	*(base + HW_ACC_START) = (*(base + HW_ACC_START)) | 0x01;
	int i=0;
	while(1){
		if((*(volatile char*)(base + HW_ACC_DONE)) & 0x01)
			break;
		i++;
	}

	bench_done(&res);
	printf("Cycle Counts: %d\n",res.msec);
	return 0;
}
