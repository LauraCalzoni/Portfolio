
PROGRAM _CYCLIC

	(*Feeder*)
	ComTCP_SimOutputs.conveyor_if_FWD	:= CONVEYOR_IF_FWD; (*box conveyor (conveyor_if) activation*)
	ComTCP_SimOutputs.conveyer_turn1_FWD	:= CONVEYOR_TURN_1_FWD; (*second conveyor activation*)
	ComTCP_SimOutputs.conveyer_end_FWD	:= CONVEYOR_END_FWD; (*third conveyor activation*)
	ComTCP_SimOutputs.pusher_FW	:= PUSHER_FW; (*pusher activation*)
	ComTCP_SimOutputs.turnpusher_BWD	:= TURNPUSHER_BWD; (*move turnpusher in backward position*)
	ComTCP_SimOutputs.turnpusher_FWD	:= TURNPUSHER_FWD; (*move turnpusher in forward position*)
	
	ComTCP_SimOutputs.carriage_2_TGT_POS	:= CARRIAGE_2_TGT_POS; (*target position for the box group pusher*)
	
	(*Crane*)

	ComTCP_SimOutputs.vaccum_box_crane_GRIP	:= VACUUM_BOX_CRANE_GRIP; (* BOOL vaccum_box_crane_GRIP *)
	ComTCP_SimOutputs.slide_rail_right_EN	:= SLIDE_RAIL_RIGHT_EN; (* BOOL slide_rail_right_EN *)
	ComTCP_SimOutputs.pusher_x_EN	:= PUSHER_X_EN; (* BOOL pusher_x_EN *)
	ComTCP_SimOutputs.pusher_z_EN	:= PUSHER_Z_EN; (* BOOL pusher_z_EN *)
	ComTCP_SimOutputs.cartboard_TRIG	:= CARTBOARD_TRIG; (* BOOL cartboard_TRIG *)
	
	ComTCP_SimOutputs.gantry_crane_TGT_POS	:= GANTRY_CRANE_TGT_POS; (* REAL gantry_crane_TGT_POS *)
	ComTCP_SimOutputs.box_crane_TGT_POS	:= BOX_CRANE_TGT_POS;
	
	(*Pallet Handler*)
	ComTCP_SimOutputs.pallet_fork_left_EN	:= PALLET_FORK_LEFT_EN; (* BOOL pallet_fork_left_EN *)
	ComTCP_SimOutputs.pallet_conveyor_1_FWD	:= PALLET_CONVEYOR_1_FWD; (* BOOL pallet_conveyor_1_FWD *)
	
	ComTCP_SimOutputs.pallet_conveyor_2_ACT_VEL	:= PALLET_CONVEYOR_2_ACT_VEL; (* REAL pallet_conveyor_2_ACT_VEL *)
	ComTCP_SimOutputs.pallet_lifter_TGT_POS	:= PALLET_LIFTER_TGT_POS; (* REAL pallet_lifter_TGT_POS *)
	

	
	
	
		
END_PROGRAM

