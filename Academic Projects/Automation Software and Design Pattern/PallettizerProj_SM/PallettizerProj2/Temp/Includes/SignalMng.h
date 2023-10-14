/* Automation Studio generated header file */
/* Do not edit ! */
/* SignalMng  */

#ifndef _SIGNALMNG_
#define _SIGNALMNG_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Constants */
#ifdef _REPLACE_CONST
 #define ALARM 1
 #define ANOMALY 2
 #define WARNING 3
 #define INFORMATION 4
 #define AUX_RESET 512
 #define UNCONDITIONED_RESET 16384
 #define AUTO_CONDITIONED_RESET 8192
 #define AUTO_PROVISIONAL_RESET 4096
 #define AUTO_PRIORITY_RESET 2048
 #define AUTO_RESET 1024
 #define SIGNAL_TYPE_MASK 7
 #define NONE 0U
 #define EMERGENCY_STOP 1U
 #define IMMEDIATE_STOP 2U
 #define ON_PHASE_STOP 4U
 #define MACHINE_OUT_OF_PHASE 256U
 #define MACHINE_INHIBITION 512U
 #define MATERIALS_RUN_OUT_LAMP 1024U
 #define MATERIALS_RUN_OUT_BUZZER 2048U
 #define IO_DIAGNOSTIC_INHIBITION 32768U
#else
 _GLOBAL_CONST signed long ALARM;
 _GLOBAL_CONST signed long ANOMALY;
 _GLOBAL_CONST signed long WARNING;
 _GLOBAL_CONST signed long INFORMATION;
 _GLOBAL_CONST signed long AUX_RESET;
 _GLOBAL_CONST signed long UNCONDITIONED_RESET;
 _GLOBAL_CONST signed long AUTO_CONDITIONED_RESET;
 _GLOBAL_CONST signed long AUTO_PROVISIONAL_RESET;
 _GLOBAL_CONST signed long AUTO_PRIORITY_RESET;
 _GLOBAL_CONST signed long AUTO_RESET;
 _GLOBAL_CONST signed long SIGNAL_TYPE_MASK;
 _GLOBAL_CONST plcdword NONE;
 _GLOBAL_CONST plcdword EMERGENCY_STOP;
 _GLOBAL_CONST plcdword IMMEDIATE_STOP;
 _GLOBAL_CONST plcdword ON_PHASE_STOP;
 _GLOBAL_CONST plcdword MACHINE_OUT_OF_PHASE;
 _GLOBAL_CONST plcdword MACHINE_INHIBITION;
 _GLOBAL_CONST plcdword MATERIALS_RUN_OUT_LAMP;
 _GLOBAL_CONST plcdword MATERIALS_RUN_OUT_BUZZER;
 _GLOBAL_CONST plcdword IO_DIAGNOSTIC_INHIBITION;
#endif




/* Datatypes and datatypes of function blocks */
typedef enum SMOperationType
{	START_CONFIGURATION,
	START_GENERATION,
	CONFIGURATION,
	GENERATION,
	RUN_SM
} SMOperationType;

#ifdef _BUR_USE_DECLARATION_IN_IEC
typedef struct SignalManagement
{
	/* VAR_INPUT (analog) */
	signed long SignalType;
	plcdword SignalOutput;
	signed short SignalCode;
	enum SMOperationType SignalOperation;
	/* VAR_OUTPUT (analog) */
	plcdword SignalOutputs;
	signed short NumberOfActiveAlarms;
	signed short NumberOfActiveWarning;
	signed short NumberOfActiveAnomalies;
	signed short NumberOfActiveInformation;
	signed short ActiveSignalCodes[20];
	signed short ActiveAlarmCode;
	signed short ActiveSignalCode;
	signed short ActiveAnomalyCode;
	signed short ActiveWarningCode;
	signed short ActiveInformationCode;
	/* VAR (analog) */
	signed short NumberOfAlarms;
	signed short NumberOfAnomalies;
	signed short NumberOfInformation;
	signed short NumberOfWarnings;
	signed short Index;
	signed short BaseIndex;
	signed short i;
	signed short CurrentAlarm;
	signed short CurrentAnomaly;
	signed short CurrentWarning;
	signed short CurrentInformation;
	signed short SignalCodeDefault;
	/* VAR_INPUT (digital) */
	plcbit KeyReset;
	plcbit ActivationSignal;
	plcbit Reset;
	/* VAR_OUTPUT (digital) */
	plcbit ResetEnable;
	plcbit AuxResetEnable;
	/* VAR (digital) */
	plcbit ResetActivation;
	plcbit ResetOld;
	plcbit AuxResetActivation;
	plcbit KeyResetOld;
	plcbit Condition;
	plcbit Signals[23];
	plcbit AuxResetRequired;
} SignalManagement_typ;
#else
/* Data type SignalManagement not declared. Data types with array elements whose starting indexes are not equal to zero cannot be used in ANSI C programs / libraries.*/
#endif



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void SignalManagement(struct SignalManagement* inst);


#ifdef __cplusplus
};
#endif
#endif /* _SIGNALMNG_ */

