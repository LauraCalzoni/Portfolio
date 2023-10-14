/* Automation Studio generated header file */
/* Do not edit ! */

#ifndef _BUR_1689519971_1_
#define _BUR_1689519971_1_

#include <bur/plctypes.h>

/* Constants */
#ifdef _REPLACE_CONST
#else
#endif


/* Variables */
_GLOBAL plcbit CarriageFaultHMI;
_GLOBAL plcbit CarriageFault;
_GLOBAL plcbit ConveyorEndFaultHMI;
_GLOBAL plcbit ConveyorEndFault;
_GLOBAL plcbit PusherFaultHMI;
_GLOBAL plcbit PusherFault;
_GLOBAL plcbit TurnPusherFaultHMI;
_GLOBAL plcbit TurnPusherFault;
_GLOBAL plcbit ConveyorTurnFaultHMI;
_GLOBAL plcbit ConveyorTurnFault;
_GLOBAL plcbit ConveyorIfFaultHMI;
_GLOBAL plcbit ConveyorIfFault;
_GLOBAL plcbit EmergencyStop;
_GLOBAL plcbit ImmediateStop;
_GLOBAL plcbit OnPhaseStop;
_GLOBAL plcbit NoMorePallet;
_GLOBAL plcbit ImmediateStopHMI;
_GLOBAL plcbit Reset;
_GLOBAL plcbit AuxReset;
_GLOBAL plcbit OnPhaseStopHMI;
_GLOBAL plcbit ComTCP_SimActive;
_GLOBAL plctime ComTCP_SimSendCycleTime;
_GLOBAL unsigned short ComTCP_SimServerPort;
_GLOBAL plcstring ComTCP_SimServerAddress[16];
_GLOBAL struct ComTCP_OUTPUTS_32BIT ComTCP_SimOutputs;
_GLOBAL struct ComTCP_INPUTS_32BIT ComTCP_SimInputs;





__asm__(".section \".plc\"");

/* Used IEC files */
__asm__(".ascii \"iecfile \\\"Logical/MNG_Package.var\\\" scope \\\"global\\\"\\n\"");

/* Exported library functions and function blocks */

__asm__(".previous");


#endif /* _BUR_1689519971_1_ */

