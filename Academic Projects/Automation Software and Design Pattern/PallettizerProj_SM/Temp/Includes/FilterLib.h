/* Automation Studio generated header file */
/* Do not edit ! */
/* FilterLib  */

#ifndef _FILTERLIB_
#define _FILTERLIB_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Datatypes and datatypes of function blocks */
typedef struct MyFilterFB
{
	/* VAR_INPUT (analog) */
	signed short OperationType;
	unsigned long ActivationDelay;
	unsigned long DeactivationDelay;
	/* VAR (analog) */
	unsigned long Delay;
	/* VAR_INPUT (digital) */
	plcbit Clock;
	plcbit Signal;
	/* VAR_OUTPUT (digital) */
	plcbit DelayedSignal;
} MyFilterFB_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void MyFilterFB(struct MyFilterFB* inst);


#ifdef __cplusplus
};
#endif
#endif /* _FILTERLIB_ */

