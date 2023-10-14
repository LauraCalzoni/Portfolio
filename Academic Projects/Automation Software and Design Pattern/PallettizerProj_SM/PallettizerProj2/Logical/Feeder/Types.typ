
TYPE
	FeederStateType : 
		(
		WaitStart,
		WaitConv,
		PusherBox,
		BoxCounting,
		BackwardCarriage,
		WaitingBack,
		WaitSyncCrane,
		StopFeeder
		);
	FeederStruct : 	STRUCT 
		State : FeederStateType;
		Start : BOOL;
		Conveyor_if : GenericDevice;
		Conveyor_if_enable_request : BOOL;
		Conveyor_if_disable_request : BOOL;
		Conveyor_if_EnableTime : INT := 20;
		Conveyor_if_DisableTime : INT := 20;
		Conveyor_turn1 : GenericDevice;
		Conveyor_turn1_disable_request : BOOL;
		Conveyor_turn1_enable_request : BOOL;
		Conveyor_turn1_EnableTime : INT := 20;
		Conveyor_turn1_DisableTime : INT := 20;
		Pusher : GenericDevice;
		Pusher_disable_request : BOOL;
		Pusher_enable_request : BOOL;
		PusherEnableTime : INT := 60;
		PusherDisableTime : INT := 60;
		Conveyor_end : GenericDevice;
		Conveyor_end_disable_request : BOOL;
		Conveyor_end_enable_request : BOOL;
		Conveyor_end_EnableTime : INT := 20;
		Conveyor_end_DisableTime : INT := 20;
		Turnpusher : GenericDevice;
		Turnpusher_enable_request : BOOL;
		Turnpusher_disable_request : BOOL;
		TurnpusherEnableTime : INT := 60;
		TurnpusherDisableTime : INT := 60;
		Carriage : GenericAxis;
		CarriagePositionReached : BOOL;
	END_STRUCT;
END_TYPE
