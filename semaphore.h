#ifndef _SEMAPHORE_H_
#define _SEMAPHORE_H_   1

/**
    @file semaphore.h
    @brief POSIX Semaphore Definitions and Routines
*/

/**
    @defgroup sem POSIX Semaphore Definitions and Routines
    @{
*/

#include <errno.h> /* Adding definition of EINVAL, ETIMEDOUT, ..., etc. */
#include <fcntl.h> /* Adding O_CREAT definition. */
#include <stdio.h>
#include <winsock.h>

#ifndef PTHREAD_PROCESS_SHARED
#define PTHREAD_PROCESS_PRIVATE	0
#define PTHREAD_PROCESS_SHARED	1
#endif

/* Support POSIX.1b semaphores.  */
#ifndef _POSIX_SEMAPHORES
#define _POSIX_SEMAPHORES       200809L
#endif

#ifndef SEM_VALUE_MAX
#define SEM_VALUE_MAX           INT_MAX
#endif

#ifndef SEM_FAILED
#define SEM_FAILED              NULL
#endif

#define UNUSED(x)				(void)(x)

#ifndef ETIMEDOUT
#define ETIMEDOUT				138 /* This is the value in VC 2010. */
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void  *sem_t;

#ifndef _MODE_T_
typedef unsigned short _mode_t;
#define _MODE_T_  1

#ifndef NO_OLDNAMES
typedef _mode_t mode_t;
#endif
#endif  /* _MODE_T_ */

typedef struct {
	HANDLE handle;
	} arch_sem_t;

#ifndef _TIMESPEC_DEFINED
struct timespec {
	time_t  tv_sec;       /* Seconds */
	long    tv_nsec;      /* Nanoseconds */
	};

struct itimerspec {
	struct timespec  it_interval; /* Timer period */
	struct timespec  it_value;    /* Timer expiration */
	};
#define _TIMESPEC_DEFINED       1
#endif  /* _TIMESPEC_DEFINED */

int sem_init(sem_t *sem, int pshared, unsigned int value);
int sem_wait(sem_t *sem);
int sem_trywait(sem_t *sem);
int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout);
int sem_post(sem_t *sem);
int sem_getvalue(sem_t *sem, int *value);
int sem_destroy(sem_t *sem);
sem_t *sem_open(const char *name, int oflag, mode_t mode, unsigned int value);
int sem_close(sem_t *sem);
int sem_unlink(const char *name);

#ifdef __cplusplus
	}
#endif

/** @} */

#endif /* _SEMAPHORE_H_ */
