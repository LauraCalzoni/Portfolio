
TYPE
	PalletStruct : 	STRUCT 
		Start : BOOL;
		State : PalletStateType;
		PalletFork : GenericDevice;
		PalletFork_enable_request : BOOL;
		PalletFork_disable_request : BOOL;
		PalletForkEnableTime : INT := 20;
		PalletForkDisableTime : INT := 20;
		PalletLifter : GenericAxis;
		PalletLifterPositionReached : BOOL;
		PalletConveyor1 : GenericDevice;
		PalletConveyor1EnableTime : INT := 20;
		PalletConveyor1DisableTime : INT := 20;
		PalletConveyor2 : GenericAxis;
		PalletConveyor1_disable_request : BOOL;
		PalletConveyor1_enable_request : BOOL;
		PalletConveyor2VelocityReached : BOOL;
	END_STRUCT;
	PalletStateType : 
		(
		WaitStart,
		ReleasePallet,
		NextPallet,
		LifterHoming,
		MovingPallet,
		PositioningPallet,
		PalletApproaching,
		PalletInPosition,
		WaitingPositioning,
		StopPalletOnPhase,
		StopPalletImmediate
		);
END_TYPE
