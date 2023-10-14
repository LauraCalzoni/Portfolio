
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	Crane.Start := START_CRANE;
	
	CASE (Crane.State) OF
		
		WaitStart:
			IF Crane.Start THEN
				Crane.State := MoveCraneForCartboard;
			END_IF
			
		
		WaitLayer:
			IF Crane.BoxCranePositionReached THEN
				CraneHomed := TRUE;
			
				IF MoveCrane THEN 
					MoveCrane := FALSE;
					Crane.PusherZ_enable_request := TRUE;
					Crane.SlideRail_enable_request := TRUE;
					CraneHomed := FALSE;
					IF (NextLayer = 1) THEN 
						Crane.State := ReleaseFirstCartboard;
					END_IF
					
					IF (NextLayer = 2) THEN	
						Crane.State := ReleaseSecondCartboard;		
					END_IF	
				END_IF
			END_IF
		
		ReleaseFirstCartboard:
			
			IF (NOT Crane.PusherZ_enable_request AND NOT Crane.SlideRail_enable_request) AND CraneEnabled THEN
				
				NextLayer := 2;
				PrevState := ReleaseFirstCartboard;
				Crane.GantryCrane.NewSetPoint := -1.11;
				Crane.GantryCrane.Command := CHANGE_POSITION;
				Crane.BoxCrane.NewSetPoint := -0.2;
				Crane.BoxCrane.Command := CHANGE_POSITION;
				Crane.State := WaitingPositioning;
				
			END_IF
		
		PositioningLayer:
			
			IF NOT Crane.Vacuum_disable_request AND NOT VACUUM_BOX_CRANE THEN
				
				PrevState := PositioningLayer;
				Crane.GantryCrane.NewSetPoint := -1.3;
				Crane.GantryCrane.Command := CHANGE_POSITION;
				Crane.State := WaitingPositioning;
			
			END_IF
		
		LayerOnPallet:
		
			IF NOT Crane.SlideRail_disable_request THEN 
		
				Crane.PusherX_enable_request := TRUE ;
				Crane.GantryCrane.NewSetPoint := 0.0;
				Crane.GantryCrane.Command := CHANGE_POSITION;
				PrevState := LayerOnPallet;
				Crane.State := WaitingPositioning;
				
			END_IF
		
		GoBack:
			
			IF FullPalletReady AND OnPhaseStop THEN
			
				Crane.PusherZ_disable_request := TRUE;
				Crane.PusherX_disable_request := TRUE;
				Crane.BoxCrane.NewSetPoint := 0.0;
				NextState := StopCrane;
				PrevState := GoBack;
				Crane.State := WaitingPositioning;
			
			END_IF
			
						
			CraneEnabled := FALSE;
			FullPalletReady := FALSE;
			
			IF PrevState = LayerOnPallet AND NOT Crane.PusherX_enable_request THEN
				
				Crane.PusherZ_disable_request := TRUE;
				Crane.PusherX_disable_request := TRUE;
				Crane.BoxCrane.NewSetPoint := 0.0;
				Crane.BoxCrane.Command := CHANGE_POSITION;
				NextState := MoveCraneForCartboard;
				PrevState := GoBack;
				Crane.State := WaitingPositioning;
					
			END_IF
				
			IF (PrevState = LoadCartboard AND NOT Crane.Vacuum_enable_request) THEN

				Crane.BoxCrane.NewSetPoint := 0.0;
				Crane.BoxCrane.Command := CHANGE_POSITION;
				NextState := WaitLayer;
				PrevState := GoBack;
				Crane.State := WaitingPositioning;
			
			END_IF
			
			
			
		MoveCraneForCartboard:
			
			IF Crane.BoxCranePositionReached THEN
				
				Crane.BoxCrane.NewSetPoint := -0.195;
				Crane.BoxCrane.Command := CHANGE_POSITION;
				Crane.State := LoadCartboard;
				
			END_IF
			
			
		LoadCartboard:
			
			IF Crane.BoxCranePositionReached THEN
				
				Crane.Vacuum_enable_request	:= TRUE;
				Crane.Cartboard_enable_request := TRUE;
				PrevState := LoadCartboard;
				Crane.State := GoBack;
				
			END_IF
		
		ReleaseSecondCartboard:
			
			
			IF (NOT Crane.PusherZ_enable_request AND NOT Crane.SlideRail_enable_request) THEN
				
				NextLayer := 1;
				Crane.GantryCrane.NewSetPoint := -1.11;
				Crane.GantryCrane.Command := CHANGE_POSITION;
				Crane.BoxCrane.NewSetPoint := 0.01;
				Crane.BoxCrane.Command := CHANGE_POSITION;
				CompleatingPallet := TRUE;
				PrevState := ReleaseSecondCartboard;
				Crane.State := WaitingPositioning;
				

			END_IF
		
		
		WaitingPositioning:
			
			IF Crane.GantryCranePositionReached AND Crane.BoxCranePositionReached    (*GANTRY_CRANE_AXIS = -1.11 AND BOX_CRANE_AXIS = 0.01*) THEN
				
				IF PrevState = ReleaseFirstCartboard OR PrevState = ReleaseSecondCartboard THEN
					
					Crane.Vacuum_disable_request := TRUE;
					Crane.Cartboard_disable_request := TRUE;
					Crane.State := PositioningLayer;
					
				END_IF
				
				IF PrevState = PositioningLayer THEN
								
					Crane.SlideRail_disable_request := TRUE;
					Crane.State := LayerOnPallet;
					
				END_IF
				
				IF PrevState = LayerOnPallet THEN
					
					IF CompleatingPallet THEN 
						CompleatingPallet:=FALSE;
						FullPalletReady := TRUE;
					END_IF
					
					Crane.State := GoBack;
					
				END_IF
				
				IF PrevState = GoBack THEN
					
					Crane.State := NextState;
					
				END_IF
				
			END_IF
		
		StopCrane:
		
			IF Reset THEN 
				
				Crane.State := WaitStart;
		
			END_IF
		
			
			
		
				
	END_CASE
				
				
	Crane.Vacuum.DeviceOperation := OperationType;
	Crane.Vacuum.DeviceClock := TRUE;
	Crane.Vacuum.DeviceDiagnosticsEnabled := TRUE;
	Crane.Vacuum.DeviceEnablePreset := FALSE;
	Crane.Vacuum.DeviceEnabledSensor := VACUUM_BOX_CRANE;
	Crane.Vacuum.DeviceEnableTime := 500;//VacuumEnableTime;
	Crane.Vacuum.DeviceDisableTime := Crane.VacuumDisableTime;
	Crane.Vacuum.DeviceType := DEVICE_WITH_SINGLE_ACTUATION OR DEVICE_WITH_ENABLE_FEEDBACK;
	Crane.Vacuum(DeviceEnableRequest := Crane.Vacuum_enable_request, DeviceDisableRequest := Crane.Vacuum_disable_request );
	VACUUM_BOX_CRANE_GRIP := Crane.Vacuum.EnableDevice;
	//eVacuumFault := (*Vacuum.DeviceEnabledSensorFault OR Vacuum.DeviceActuatorFault*) SIMVacuumFault;
	
	Crane.Cartboard.DeviceOperation := OperationType;
	Crane.Cartboard.DeviceClock := TRUE;
	Crane.Cartboard.DeviceDiagnosticsEnabled := TRUE;
	Crane.Cartboard.DeviceEnablePreset := FALSE;
	Crane.Cartboard.DeviceEnableTime := Crane.CartboardEnableTime;
	Crane.Cartboard.DeviceDisableTime := Crane.CartboardDisableTime;
	Crane.Cartboard.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Crane.Cartboard(DeviceEnableRequest := Crane.Cartboard_enable_request, DeviceDisableRequest := Crane.Cartboard_disable_request);
	CARTBOARD_TRIG := Crane.Cartboard.EnableDevice;
//	eCartboardFault	:= (*Cartboard.DeviceActuatorFault*) SIMCartboardFault;

	Crane.SlideRail.DeviceOperation := OperationType;
	Crane.SlideRail.DeviceClock := TRUE;
	Crane.SlideRail.DeviceDiagnosticsEnabled := TRUE;
	Crane.SlideRail.DeviceEnablePreset := FALSE;
	Crane.SlideRail.DeviceEnableTime := Crane.SlideRailEnableTime;
	Crane.SlideRail.DeviceDisableTime := Crane.SlideRailDisableTime;
	Crane.SlideRail.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Crane.SlideRail(DeviceEnableRequest := Crane.SlideRail_enable_request, DeviceDisableRequest := Crane.SlideRail_disable_request);
	SLIDE_RAIL_RIGHT_EN := Crane.SlideRail.EnableDevice;
	//eSlideRailFault	:= (*SlideRail.DeviceActuatorFault*) SIMSlideRailFault;

	Crane.PusherZ.DeviceOperation := OperationType;
	Crane.PusherZ.DeviceClock := TRUE;
	Crane.PusherZ.DeviceDiagnosticsEnabled := TRUE;
	Crane.PusherZ.DeviceEnablePreset := FALSE;
	Crane.PusherZ.DeviceEnableTime := Crane.PusherZEnableTime;
	Crane.PusherZ.DeviceDisableTime := Crane.PusherZDisableTime;
	Crane.PusherZ.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Crane.PusherZ(DeviceEnableRequest := Crane.PusherZ_enable_request, DeviceDisableRequest := Crane.PusherZ_disable_request);
	PUSHER_Z_EN := Crane.PusherZ.EnableDevice;
	//ePusherzFault	:= (*PusherZ.DeviceActuatorFault*) SIMPusherzFault;


	Crane.PusherX.DeviceOperation := OperationType;
	Crane.PusherX.DeviceClock := TRUE;
	Crane.PusherX.DeviceDiagnosticsEnabled := TRUE;
	Crane.PusherX.DeviceEnablePreset := FALSE;
	Crane.PusherX.DeviceEnableTime := Crane.PusherXEnableTime;
	Crane.PusherX.DeviceDisableTime := Crane.PusherXDisableTime;
	Crane.PusherX.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Crane.PusherX(DeviceEnableRequest := Crane.PusherX_enable_request, DeviceDisableRequest := Crane.PusherX_disable_request );
	PUSHER_X_EN := Crane.PusherX.EnableDevice;
	//ePusherxFault	:= (*PusherX.DeviceActuatorFault*) SIMPusherxFault;

	Crane.GantryCrane.ActualPosition	:= GANTRY_CRANE_AXIS;
	Crane.GantryCrane.TGT_SENSOR	:= TRUE;
	GANTRY_CRANE_TGT_POS	:= Crane.GantryCrane.TargetPosition;
	Crane.GantryCrane.DeviceTimer	:= 400;
	//eGantryCraneFault	:= (*GantryCrane.DeviceFault*) SIMGantryCraneFault;
	Crane.GantryCrane();
	Crane.GantryCranePositionReached	:= Crane.GantryCrane.InPosition;

	//BoxCrane.NewSetPoint	:= BoxCraneSetPoint;
	Crane.BoxCrane.ActualPosition	:= BOX_CRANE_AXIS;
	Crane.BoxCrane.TGT_SENSOR	:= TRUE;
	BOX_CRANE_TGT_POS	:=	Crane.BoxCrane.TargetPosition;
	Crane.BoxCrane.DeviceTimer	:= 400;
	//eBoxCraneFault	:= (*BoxCrane.DeviceFault*) SIMBoxCraneFault;
	Crane.BoxCrane();
	Crane.BoxCranePositionReached	:= Crane.BoxCrane.InPosition;
 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

