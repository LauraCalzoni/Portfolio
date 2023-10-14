
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	// Falling edge in the coining boxes sensor 
	F_TRIG_0( CLK:=LASER_SENSOR_2_IR );
	LaserSensor2 := F_TRIG_0.Q;
	
	Feeder.Start := START_FEEDER;
	
	
	CASE (Feeder.State) OF

		
		WaitStart:
			
			IF ImmediateStop THEN
				
				PrevState := WaitStart;
				Feeder.State := StopFeederImmediate;
				
			ELSIF Feeder.Start THEN 
				
				Feeder.Conveyor_if_enable_request := TRUE;
				Feeder.Conveyor_turn1_enable_request := TRUE;
				Feeder.Conveyor_end_enable_request := TRUE;
				
				Feeder.State := WaitConv;
			
			END_IF
		
		WaitConv:
			
			IF ImmediateStop THEN
				
				Feeder.Conveyor_if_disable_request := TRUE;
				Feeder.Conveyor_end_disable_request := TRUE;
				Feeder.Conveyor_turn1_disable_request := TRUE;
				
				PrevState := WaitConv;
				Feeder.State := StopFeederImmediate;
				
			ELSIF NOT Feeder.Conveyor_if_enable_request AND NOT Feeder.Conveyor_turn1_enable_request AND NOT Feeder.Conveyor_end_enable_request THEN
					
				Feeder.State := PusherBox;
				
			END_IF
			
			
					
		PusherBox:
			
			IF ImmediateStop THEN
				
				Feeder.Conveyor_if_disable_request := TRUE;
				Feeder.Conveyor_end_disable_request := TRUE;
				Feeder.Conveyor_turn1_disable_request := TRUE;
				
				PrevState := PusherBox;
				Feeder.State := StopFeederImmediate;
				
			// Behaviour with an OnPhase stop signal	
			ELSIF LastLayer AND OnPhaseStop THEN
				
				Feeder.Conveyor_if_disable_request := TRUE;
				Feeder.Conveyor_end_disable_request := TRUE;
				Feeder.State := StopFeederOnPhase;
			
			// Nominal behaviour
			ELSIF NOT Feeder.Turnpusher_enable_request AND NOT Feeder.Turnpusher_disable_request AND Feeder.CarriagePositionReached THEN
				
				IF LASER_SENSOR_IR AND NOT Feeder.Pusher_disable_request THEN 
					ExpectedBox := Box + 1;
					Feeder.Pusher_enable_request := TRUE;
					LastLayer := FALSE;
					Feeder.State := BoxCounting;
				END_IF
				
				IF Box <> ExpectedBox THEN
					Feeder.Pusher_enable_request := TRUE;
					LastLayer := FALSE;
					Feeder.State := BoxCounting;
				END_IF
				
				
			END_IF
			
					
		BoxCounting:
			
			IF ImmediateStop THEN
				
				Feeder.Conveyor_if_disable_request := TRUE;
				Feeder.Conveyor_end_disable_request := TRUE;
				Feeder.Conveyor_turn1_disable_request := TRUE;
				PrevState := BoxCounting;
				Feeder.State := StopFeederImmediate;
			
			// Nominal	
			ELSIF NOT Feeder.Pusher_enable_request THEN 
				
				Feeder.Pusher_disable_request := TRUE;
				LayerPositioned := FALSE;
				LayerOn := FALSE;
				
				IF LaserSensor2 THEN 
					Box := Box+1;
					
					// Type of boxes in the pallet (first horizzontals)
					IF Format = 1 AND Line = 1 AND Box = 8 THEN
						Feeder.Turnpusher_enable_request := TRUE;
						Line := 2;
						Box := 0;
						ExpectedBox := 0;
						Feeder.Carriage.NewSetPoint	:= 0.44;  
						Feeder.Carriage.Command := CHANGE_POSITION;
						Feeder.State := BackwardCarriage;
					END_IF
					
					IF Format = 1 AND Line = 2 AND Box = 3 THEN
						Line := 3;
						Feeder.Carriage.NewSetPoint	:= 0.44;  
						Feeder.Carriage.Command := CHANGE_POSITION;
						Feeder.State := BackwardCarriage;
					END_IF
					
					IF Format = 1 AND Line = 3 AND Box = 6 THEN 
						Line := 1;
						Format := 2;
						Box := 0;
						ExpectedBox := 0;
						Feeder.State := WaitSyncCrane;
					END_IF
					
					IF Format = 2 AND Line = 1 AND Box = 3 THEN
						Line := 2;
						Feeder.Carriage.NewSetPoint	:= 0.44;
						Feeder.Carriage.Command := CHANGE_POSITION;
						Feeder.State := BackwardCarriage;
					END_IF
					
					IF Format = 2 AND Line = 2 AND Box = 6 THEN
						Feeder.Turnpusher_disable_request := TRUE;
						Line := 3;
						Box := 0;
						ExpectedBox := 0;
						Feeder.Carriage.NewSetPoint := 0.44;  
						Feeder.Carriage.Command := CHANGE_POSITION;
						Feeder.State := BackwardCarriage;
					END_IF
					
					IF Format = 2 AND Line = 3 AND Box = 8 THEN
						LastLayer := TRUE; 
						Line := 1;
						Format := 1;
						Box := 0;
						ExpectedBox := 0;
						Feeder.State := WaitSyncCrane;
					END_IF
					
					IF (Feeder.State <> BackwardCarriage) AND (Feeder.State <> WaitSyncCrane) THEN
						Feeder.State := PusherBox;
					END_IF
				END_IF
					
				
			END_IF
		
			
		BackwardCarriage:
			
			IF ImmediateStop THEN
				
				Feeder.Conveyor_if_disable_request := TRUE;
				Feeder.Conveyor_end_disable_request := TRUE;
				Feeder.Conveyor_turn1_disable_request := TRUE;
				
				PrevState := BackwardCarriage;
				Feeder.State := StopFeederImmediate;
				
			ELSIF Feeder.CarriagePositionReached THEN
				
				Feeder.Carriage.NewSetPoint := 0.0;
				Feeder.Carriage.Command := CHANGE_POSITION;
				Feeder.State := WaitingBack;
				
			END_IF
			
			
		WaitingBack:
			
			IF ImmediateStop THEN
				
				Feeder.Conveyor_if_disable_request := TRUE;
				Feeder.Conveyor_end_disable_request := TRUE;
				Feeder.Conveyor_turn1_disable_request := TRUE;
				
				PrevState := WaitingBack;
				Feeder.State := StopFeederImmediate;
			
			ELSIF LayerOn AND Feeder.CarriagePositionReached THEN
				LayerPositioned := TRUE;
				Feeder.State := PusherBox;
				
			ELSIF NOT LayerOn AND Feeder.CarriagePositionReached THEN
				Feeder.State := PusherBox;
			END_IF
			
			
		WaitSyncCrane:
			
			
			IF ImmediateStop THEN
				
				Feeder.Conveyor_if_disable_request := TRUE;
				Feeder.Conveyor_end_disable_request := TRUE;
				Feeder.Conveyor_turn1_disable_request := TRUE;

				
				PrevState := WaitSyncCrane;
				Feeder.State := StopFeederImmediate;
			
			ELSIF PushLayer THEN
				Feeder.Carriage.NewSetPoint	:= 1.1;  
				Feeder.Carriage.Command := CHANGE_POSITION;
				LayerOn := TRUE;
				PushLayer := FALSE;
				Feeder.State := BackwardCarriage;
			END_IF
		
			
		StopFeederImmediate:
			
			IF LaserSensor2 THEN 
				Box := Box+1;
			END_IF
			
			IF  NOT Feeder.Conveyor_if_disable_request AND NOT Feeder.Conveyor_end_disable_request AND NOT Feeder.Conveyor_turn1_disable_request 
				AND NOT ImmediateStop THEN
				
				Feeder.Conveyor_if_enable_request := TRUE;
				Feeder.Conveyor_end_enable_request := TRUE;
				Feeder.Conveyor_turn1_enable_request := TRUE;
				Feeder.State := WaitingForReactivation;
				
			END_IF
			
			
		StopFeederOnPhase:			
				
			IF NOT Feeder.Conveyor_if_disable_request AND NOT Feeder.Conveyor_end_disable_request AND NOT OnPhaseStop AND NOT ImmediateStop THEN
				
				Feeder.State := WaitStart;
				
			END_IF
			
		
		WaitingForReactivation: 
			
			IF LaserSensor2 THEN 
				Box := Box+1;
			END_IF
			
			
			IF NOT Feeder.Conveyor_if_enable_request AND NOT Feeder.Conveyor_end_enable_request AND NOT Feeder.Conveyor_turn1_enable_request THEN
				
				IF Box <> ExpectedBox THEN
					Feeder.State := BoxCounting;
				END_IF
				
				IF Box = ExpectedBox THEN
					Feeder.Pusher_disable_request := TRUE;
					Feeder.State := PusherBox;
				END_IF
				
			END_IF
		
			
	END_CASE
		
	
	

	
	
	
	
	Feeder.Conveyor_if.DeviceOperation := OperationType;
	Feeder.Conveyor_if.DeviceClock := TRUE;
	Feeder.Conveyor_if.DeviceDiagnosticsEnabled := TRUE;
	Feeder.Conveyor_if.DeviceEnablePreset := FALSE;
	Feeder.Conveyor_if.DeviceEnableTime := Feeder.Conveyor_if_EnableTime;
	Feeder.Conveyor_if.DeviceDisableTime := Feeder.Conveyor_if_DisableTime;
	Feeder.Conveyor_if.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Feeder.Conveyor_if(DeviceEnableRequest := Feeder.Conveyor_if_enable_request, DeviceDisableRequest := Feeder.Conveyor_if_disable_request);
	CONVEYOR_IF_FWD := Feeder.Conveyor_if.EnableDevice;
	ConveyorIfFault	:= Feeder.Conveyor_if.DeviceFault;

	Feeder.Conveyor_turn1.DeviceOperation := OperationType;
	Feeder.Conveyor_turn1.DeviceClock := TRUE;
	Feeder.Conveyor_turn1.DeviceDiagnosticsEnabled := TRUE;
	Feeder.Conveyor_turn1.DeviceEnablePreset := FALSE;
	Feeder.Conveyor_turn1.DeviceEnableTime := Feeder.Conveyor_turn1_EnableTime;
	Feeder.Conveyor_turn1.DeviceDisableTime := Feeder.Conveyor_turn1_DisableTime;
	Feeder.Conveyor_turn1.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Feeder.Conveyor_turn1(DeviceEnableRequest := Feeder.Conveyor_turn1_enable_request, DeviceDisableRequest := Feeder.Conveyor_turn1_disable_request);
	CONVEYOR_TURN_1_FWD := Feeder.Conveyor_turn1.EnableDevice;
	ConveyorTurnFault := Feeder.Conveyor_turn1.DeviceFault;

	Feeder.Pusher.DeviceOperation := OperationType;
	Feeder.Pusher.DeviceClock := TRUE;
	Feeder.Pusher.DeviceDiagnosticsEnabled := TRUE;
	Feeder.Pusher.DeviceEnablePreset := FALSE;
	Feeder.Pusher.DeviceEnabledSensor := PUSHER_LFR;
	Feeder.Pusher.DeviceDisabledSensor := PUSHER_LBK;
	Feeder.Pusher.DeviceEnableTime := Feeder.PusherEnableTime;
	Feeder.Pusher.DeviceDisableTime := Feeder.PusherDisableTime;
	Feeder.Pusher.DeviceType := DEVICE_WITH_DOUBLE_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Feeder.Pusher(DeviceEnableRequest := Feeder.Pusher_enable_request, DeviceDisableRequest := Feeder.Pusher_disable_request);
	PUSHER_FW := Feeder.Pusher.EnableDevice;
	PusherFault := Feeder.Pusher.DeviceActuatorFault;

	Feeder.Conveyor_end.DeviceOperation := OperationType;
	Feeder.Conveyor_end.DeviceClock := TRUE;
	Feeder.Conveyor_end.DeviceDiagnosticsEnabled := TRUE;
	Feeder.Conveyor_end.DeviceEnablePreset := FALSE;
	Feeder.Conveyor_end.DeviceEnableTime := Feeder.Conveyor_end_EnableTime;
	Feeder.Conveyor_end.DeviceDisableTime := Feeder.Conveyor_end_DisableTime;
	Feeder.Conveyor_end.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Feeder.Conveyor_end(DeviceEnableRequest := Feeder.Conveyor_end_enable_request, DeviceDisableRequest := Feeder.Conveyor_end_disable_request);
	CONVEYOR_END_FWD := Feeder.Conveyor_end.EnableDevice;
	ConveyorEndFault:= Feeder.Conveyor_end.DeviceFault;
	
	Feeder.Turnpusher.DeviceOperation := OperationType;
	Feeder.Turnpusher.DeviceClock := TRUE;
	Feeder.Turnpusher.DeviceDiagnosticsEnabled := TRUE;
	Feeder.Turnpusher.DeviceEnablePreset := FALSE;
	Feeder.Turnpusher.DeviceEnabledSensor := TURNPUSHER_LBK;
	Feeder.Turnpusher.DeviceDisabledSensor := TURNPUSHER_LFR;
	Feeder.Turnpusher.DeviceEnableTime := Feeder.TurnpusherEnableTime;
	Feeder.Turnpusher.DeviceDisableTime := Feeder.TurnpusherDisableTime;
	Feeder.Turnpusher.DeviceType := DEVICE_WITH_DOUBLE_FEEDBACK OR DEVICE_WITH_DOUBLE_ACTUATION;
	Feeder.Turnpusher(DeviceEnableRequest := Feeder.Turnpusher_enable_request, DeviceDisableRequest := Feeder.Turnpusher_disable_request);
	TURNPUSHER_BWD := Feeder.Turnpusher.EnableDevice;
	TURNPUSHER_FWD := Feeder.Turnpusher.DisableDevice;
	TurnPusherFault := Feeder.Turnpusher.DeviceActuatorFault;

	
	Feeder.Carriage.ActualPosition	:= CARRIAGE_2_AXIS;
	CARRIAGE_2_TGT_POS	:= Feeder.Carriage.TargetPosition;
	Feeder.Carriage.TGT_SENSOR	:= CARRIAGE_2_RCHD;
	Feeder.Carriage.DeviceTimer := 400;
	CarriageFault := Feeder.Carriage.DeviceFault;
	Feeder.Carriage();	
	Feeder.CarriagePositionReached	:= Feeder.Carriage.InPosition;

	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

