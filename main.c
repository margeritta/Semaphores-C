#include "stdafx.h"

#include "semaphore.h"
#include <assert.h>

int number = 0;

int main(int argc, char **argv) 
{
	sem_t *sem = sem_open("example_semaphore", O_CREAT | O_EXCL, 0, 1);
	
	/*check if semaphore failed*/
	if (sem == SEM_FAILED) 
	{
		printf("Failed to acquire semaphore\n");
		return -1;
	}

	sem_wait(sem);
    
	/*Critical Code Block 1*/
	++number;
	printf("In critical code block 1. Number = %d\n", number);
	sem_post(sem);
    
	/*Normal Block 1*/
	--number;
	printf("Normal code block 1. Number = %d\n", number);	
	sem_wait(sem);
    
	/*Critical Code Block 2*/
	++number;
	printf("In critical code block 2. Number = %d\n", number);
	sem_post(sem);
    
	/*Normal Block 2*/
	--number;
	printf("Normal code block 2. Number = %d\n\n", number);
	
	
    /*clean up*/
	sem_unlink("example_semaphore");
	sem_close(sem);

	assert(number == 0);
	return 0;
}
