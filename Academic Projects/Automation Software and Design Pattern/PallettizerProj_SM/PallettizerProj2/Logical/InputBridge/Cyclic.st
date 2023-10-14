
PROGRAM _CYCLIC

	(*Feeder*)
	LASER_SENSOR_IR	:= ComTCP_SimInputs.laser_sensor_IR; (*box present at the end of the first conveyor (conveyor_if)*)
	LASER_SENSOR_2_IR := ComTCP_SimInputs.laser_sensor2_IR;(*product passing from conveyor_turn1 and conveyor_end*)
	CARRIAGE_2_AXIS	:= ComTCP_SimInputs.carriage_2_AXIS;(*actual position of the box group pusher*)
	CARRIAGE_2_RCHD	:= ComTCP_SimInputs.carriage_2_RCHD; (*box group pusher target position reached*)
	PUSHER_LBK	:= ComTCP_SimInputs.pusher_LBK; (*pusher in backward position*)
	PUSHER_LFR	:= ComTCP_SimInputs.pusher_LFR; (*pusher in forward position*)
	TURNPUSHER_LBK := ComTCP_SimInputs.turnpusher_LBK; (*turnpusher in backward position*)
	TURNPUSHER_LFR	:= ComTCP_SimInputs.turnpusher_LFR; (*turnpusher in forward position*)
	
	(*Crane*)
	
	VACUUM_BOX_CRANE	:= ComTCP_SimInputs.vaccum_box_crane_VACUUM; (* BOOL vaccum_box_crane_VACUUM *)
	
	BOX_CRANE_AXIS	:= ComTCP_SimInputs.box_crane_AXIS; (* REAL box_crane_AXIS *)
	GANTRY_CRANE_AXIS	:= ComTCP_SimInputs.gantry_crane_AXIS; (* REAL gantry_crane_AXIS *)
	//CARTBOARD_TRIG := ComTCP_SimOutputs.cartboard_TRIG;
	
	(*Pallet Handler*)
	
	PALLET_FORK_LEFT_FB	:= ComTCP_SimInputs.pallet_fork_left_FB; (* BOOL pallet_fork_left_FB *)
	PALLET_LIGHT_BARRIER_1_IR	:= ComTCP_SimInputs.pallet_light_barrier_1_IR; (* BOOL pallet_light_barrier_1_IR *)
	PALLET_LIGHT_BARRIER_2_IR	:= ComTCP_SimInputs.pallet_light_barrier_2_IR; (* BOOL pallet_light_barrier_2_IR *)

	PALLET_LIFTER_AXIS	:= ComTCP_SimInputs.pallet_lifter_AXIS; (* REAL pallet_lifter_AXIS *)

	
	
	
END_PROGRAM
