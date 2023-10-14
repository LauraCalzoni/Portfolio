
TYPE
	CraneStateType : 
		(
		WaitStart,
		WaitLayer,
		ReleaseFirstCartboard,
		PositioningLayer,
		LayerOnPallet,
		GoBack,
		MoveCraneForCartboard,
		LoadCartboard,
		ReleaseSecondCartboard,
		WaitingPositioning,
		StopCrane
		);
	CraneStruct : 	STRUCT 
		State : CraneStateType;
		Start : BOOL;
		Vacuum : GenericDevice;
		Vacuum_enable_request : BOOL;
		Vacuum_disable_request : BOOL;
		VacuumEnableTime : INT := 80;
		VacuumDisableTime : INT := 80;
		Cartboard : GenericDevice;
		Cartboard_enable_request : BOOL;
		Cartboard_disable_request : BOOL;
		CartboardEnableTime : INT := 60;
		CartboardDisableTime : INT := 60;
		SlideRail : GenericDevice;
		SlideRail_enable_request : BOOL;
		SlideRail_disable_request : BOOL;
		SlideRailEnableTime : INT := 60;
		SlideRailDisableTime : INT := 60;
		PusherZ : GenericDevice;
		PusherZ_enable_request : BOOL;
		PusherZ_disable_request : BOOL;
		PusherZEnableTime : INT := 60;
		PusherZDisableTime : INT := 60;
		PusherX : GenericDevice;
		PusherX_enable_request : BOOL;
		PusherX_disable_request : BOOL;
		PusherXEnableTime : INT := 60;
		PusherXDisableTime : INT := 60;
		GantryCrane : GenericAxis;
		GantryCranePositionReached : BOOL;
		BoxCrane : GenericAxis;
		BoxCranePositionReached : BOOL;
	END_STRUCT;
END_TYPE
