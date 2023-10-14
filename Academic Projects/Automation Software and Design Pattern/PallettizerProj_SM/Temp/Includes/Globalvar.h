/* Automation Studio generated header file */
/* Do not edit ! */

#ifndef _BUR_1689585650_1_
#define _BUR_1689585650_1_

#include <bur/plctypes.h>

/* Constants */
#ifdef _REPLACE_CONST
 #define RUN 1
 #define INIT 0
#else
 _GLOBAL_CONST signed short RUN;
 _GLOBAL_CONST signed short INIT;
#endif


/* Variables */
_GLOBAL signed short OperationType;
_GLOBAL float PALLET_CONVEYOR_2_ACT_VEL;
_GLOBAL float PALLET_LIFTER_TGT_POS;
_GLOBAL float GANTRY_CRANE_TGT_POS;
_GLOBAL float CARRIAGE_2_TGT_POS;
_GLOBAL float BOX_CRANE_TGT_POS;
_GLOBAL float PALLET_LIFTER_AXIS;
_GLOBAL float GANTRY_CRANE_AXIS;
_GLOBAL float BOX_CRANE_AXIS;
_GLOBAL plcbit CARRIAGE_2_RCHD;
_GLOBAL float CARRIAGE_2_AXIS;
_GLOBAL plcbit PALLET_CONVEYOR_1_FWD;
_GLOBAL plcbit PALLET_FORK_LEFT_EN;
_GLOBAL plcbit PUSHER_X_EN;
_GLOBAL plcbit PUSHER_Z_EN;
_GLOBAL plcbit SLIDE_RAIL_RIGHT_EN;
_GLOBAL plcbit CARTBOARD_TRIG;
_GLOBAL plcbit VACUUM_BOX_CRANE_GRIP;
_GLOBAL plcbit TURNPUSHER_BWD;
_GLOBAL plcbit TURNPUSHER_FWD;
_GLOBAL plcbit CONVEYOR_END_FWD;
_GLOBAL plcbit PUSHER_FW;
_GLOBAL plcbit CONVEYOR_TURN_1_FWD;
_GLOBAL plcbit CONVEYOR_IF_FWD;
_GLOBAL plcbit PALLET_FORK_LEFT_FB;
_GLOBAL plcbit TURNPUSHER_LBK;
_GLOBAL plcbit TURNPUSHER_LFR;
_GLOBAL plcbit PUSHER_LFR;
_GLOBAL plcbit PUSHER_LBK;
_GLOBAL plcbit laser_sensor2;
_GLOBAL plcbit laser_sensor;
_GLOBAL plcbit pallet_light_barrier_2;
_GLOBAL plcbit pallet_light_barrier_1;
_GLOBAL plcbit LASER_SENSOR_2_IR;
_GLOBAL plcbit VACUUM_BOX_CRANE;
_GLOBAL plcbit LASER_SENSOR_IR;
_GLOBAL plcbit PALLET_LIGHT_BARRIER_2_IR;
_GLOBAL plcbit PALLET_LIGHT_BARRIER_1_IR;
_GLOBAL plcbit CraneHomed;
_GLOBAL plcbit PushLayer;
_GLOBAL plcbit FullPalletReady;
_GLOBAL plcbit PalletExpultion;
_GLOBAL plcbit LayerPositioned;
_GLOBAL plcbit MoveCrane;
_GLOBAL plcbit PalletPositioned;
_GLOBAL plcbit CraneEnabled;
_GLOBAL plcbit START_FEEDER;
_GLOBAL plcbit START_MACHINE;
_GLOBAL plcbit START_PALLET_HANDLER;
_GLOBAL plcbit START_CRANE;





__asm__(".section \".plc\"");

/* Used IEC files */
__asm__(".ascii \"iecfile \\\"Logical/Global.var\\\" scope \\\"global\\\"\\n\"");

/* Exported library functions and function blocks */

__asm__(".previous");


#endif /* _BUR_1689585650_1_ */

