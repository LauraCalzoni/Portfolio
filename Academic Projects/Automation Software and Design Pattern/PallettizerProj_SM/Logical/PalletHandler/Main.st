
PROGRAM _INIT
	
	NumberPallet := 5;
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	Pallet.Start := START_PALLET_HANDLER;
	
	CASE (Pallet.State) OF 
			
		WaitStart:
			
			IF ImmediateStop THEN
				
				PrevState := WaitStart;
				Pallet.State := StopPalletImmediate;
		
			ELSIF Pallet.Start THEN 
				Pallet.State := ReleasePallet;
			END_IF
		
		ReleasePallet:
						
			PalletExpultion := FALSE;
			PalletPositioned := FALSE;
			
			
			IF ImmediateStop THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.0;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
				
				PrevState := ReleasePallet;
				Pallet.State :=StopPalletImmediate;
			
			ELSIF Pallet.PalletLifterPositionReached AND NOT OnPhaseStop THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.5;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;		
				Pallet.PalletLifter.NewSetPoint := -0.258;
				Pallet.PalletLifter.Command := CHANGE_POSITION;

				PrevState := ReleasePallet;
				Pallet.State := WaitingPositioning;
		
			END_IF
			
			
		NextPallet:
			
			IF ImmediateStop THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.0;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
				
				PrevState := NextPallet;
				Pallet.State :=StopPalletImmediate;
				
		
			ELSIF NOT Pallet.PalletFork_enable_request THEN
				
				Pallet.PalletLifter.NewSetPoint := -0.12;
				Pallet.PalletLifter.Command := CHANGE_POSITION;

				PrevState := NextPallet;
				Pallet.State := WaitingPositioning;	
				
			END_IF
			
		
		LifterHoming:
			
			IF ImmediateStop THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.0;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
				
				PrevState := LifterHoming;
				Pallet.State :=StopPalletImmediate;
				
			
			ELSIF NOT Pallet.PalletFork_disable_request THEN
				Pallet.PalletLifter.NewSetPoint := 0.0;
				Pallet.PalletLifter.Command := CHANGE_POSITION;

				Pallet.State := MovingPallet;
			END_IF
			
			
			
		MovingPallet:
			
			IF ImmediateStop THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.0;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
				
				PrevState := MovingPallet;
				Pallet.State :=StopPalletImmediate;
			
			ELSIF Pallet.PalletLifterPositionReached THEN
				
				Pallet.PalletConveyor1_enable_request := TRUE;
				Pallet.PalletLifter.NewSetPoint := 0.0;
				Pallet.PalletLifter.Command := CHANGE_POSITION;
				Pallet.State := PositioningPallet;
					
			END_IF
					
		
		PositioningPallet:
			
			IF ImmediateStop THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.0;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
				Pallet.PalletConveyor1_disable_request := TRUE;

				PrevState := PositioningPallet;
				Pallet.State :=StopPalletImmediate;
			
			ELSIF Pallet.PalletConveyor2VelocityReached AND NOT Pallet.PalletConveyor1_enable_request AND PALLET_LIGHT_BARRIER_2_IR THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.1;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
				Pallet.State := PalletApproaching;
				
			END_IF
			
			
		PalletApproaching:
			
			IF ImmediateStop THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.0;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
				Pallet.PalletConveyor1_disable_request := TRUE;

				PrevState := PalletApproaching;
				Pallet.State :=StopPalletImmediate;
			
			ELSIF Pallet.PalletConveyor2VelocityReached AND PALLET_LIGHT_BARRIER_1_IR THEN
			
				Pallet.PalletConveyor2.NewSetPoint := 0.0;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
				Pallet.PalletConveyor1_disable_request := TRUE;
				Pallet.State := PalletInPosition;
				
			END_IF
			
			
		PalletInPosition:
			
			IF ImmediateStop THEN

				PrevState := PalletApproaching;
				Pallet.State :=StopPalletImmediate;
			
			ELSIF Pallet.PalletConveyor2VelocityReached AND NOT Pallet.PalletConveyor1_disable_request THEN
				
				PalletPositioned := TRUE;
				
				IF PalletExpultion THEN
					
					IF OnPhaseStop THEN
						
						Pallet.PalletConveyor1_disable_request := TRUE;
						Pallet.PalletConveyor2.NewSetPoint := 0.0;
						Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
						Pallet.State := StopPalletOnPhase;
						
					END_IF
					
					IF NOT OnPhaseStop THEN
						
						Pallet.PalletConveyor2.NewSetPoint := 0.5;
						Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;	
						Pallet.State := ReleasePallet;
						
					END_IF
					
				END_IF
				
				
			
			END_IF
			
						
		WaitingPositioning:
			
			IF ImmediateStop THEN
				
				Pallet.PalletConveyor2.NewSetPoint := 0.0;
				Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;
				Pallet.State := StopPalletImmediate;
		
			ELSIF Pallet.PalletLifterPositionReached THEN
				
				IF PrevState = ReleasePallet THEN
					NumberPallet := NumberPallet-1;
					
					IF NumberPallet = 0 THEN
						NoMorePallet := TRUE;
					END_IF
					
					Pallet.PalletFork_enable_request := TRUE;
					Pallet.State := NextPallet;
							
				END_IF
				
				IF PrevState = NextPallet THEN 
					
					Pallet.PalletFork_disable_request := TRUE;
					Pallet.State := LifterHoming;

							
				END_IF
										
			END_IF
		
		StopPalletOnPhase:
		
			IF NOT Pallet.PalletConveyor1_disable_request AND Pallet.PalletConveyor2VelocityReached  AND NOT OnPhaseStop THEN
				
				IF NumberPallet = 0 THEN	
					NoMorePallet := FALSE;
					NumberPallet := 5;
				END_IF
				
				Pallet.State := WaitStart;
				
			END_IF
		
		StopPalletImmediate:
		
			IF Pallet.PalletConveyor2VelocityReached AND NOT ImmediateStop THEN
				
				IF (PrevState = PositioningPallet ) AND NOT Pallet.PalletConveyor1_disable_request THEN
					
					Pallet.PalletConveyor1_enable_request := TRUE;
					Pallet.PalletConveyor2.NewSetPoint := 0.5;
					Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;
					
				END_IF
				
				IF PrevState = PalletApproaching AND NOT Pallet.PalletConveyor1_disable_request THEN
					
					Pallet.PalletConveyor1_enable_request := TRUE;
					Pallet.PalletConveyor2.NewSetPoint := 0.1;
					Pallet.PalletConveyor2.Command := CHANGE_VELOCITY;
					
				END_IF
				
					
					
				Pallet.State := PrevState;
		
			END_IF
		
			
		
		
				
	END_CASE
	
	
	
	Pallet.PalletFork.DeviceOperation := OperationType;
	Pallet.PalletFork.DeviceClock := TRUE;
	Pallet.PalletFork.DeviceDiagnosticsEnabled := TRUE;
	Pallet.PalletFork.DeviceEnablePreset := FALSE;
	Pallet.PalletFork.DeviceEnabledSensor := PALLET_FORK_LEFT_FB;
	Pallet.PalletFork.DeviceEnableTime := Pallet.PalletForkEnableTime;
	Pallet.PalletFork.DeviceDisableTime := Pallet.PalletForkDisableTime;
	PALLET_FORK_LEFT_EN := Pallet.PalletFork.EnableDevice;
	Pallet.PalletFork.DeviceType := DEVICE_WITH_ENABLE_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	Pallet.PalletFork(DeviceEnableRequest := Pallet.PalletFork_enable_request, DeviceDisableRequest := Pallet.PalletFork_disable_request);
	PalletforkFault := Pallet.PalletFork.DeviceFault;
	
	Pallet.PalletConveyor1.DeviceOperation := OperationType;
	Pallet.PalletConveyor1.DeviceClock := TRUE;
	Pallet.PalletConveyor1.DeviceDiagnosticsEnabled := TRUE;
	Pallet.PalletConveyor1.DeviceEnablePreset := FALSE;
	Pallet.PalletConveyor1.DeviceEnableTime := Pallet.PalletConveyor1EnableTime;
	Pallet.PalletConveyor1.DeviceDisableTime := Pallet.PalletConveyor1DisableTime;
	Pallet.PalletConveyor1.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	PALLET_CONVEYOR_1_FWD := Pallet.PalletConveyor1.EnableDevice;
	Pallet.PalletConveyor1(DeviceEnableRequest := Pallet.PalletConveyor1_enable_request, DeviceDisableRequest := Pallet.PalletConveyor1_disable_request);
	PalletConveyor1Fault := Pallet.PalletConveyor1.DeviceFault;
	

	Pallet.PalletLifter.ActualPosition	:= PALLET_LIFTER_AXIS;
	Pallet.PalletLifter.TGT_SENSOR	:= TRUE;
	PALLET_LIFTER_TGT_POS 	:= Pallet.PalletLifter.TargetPosition;
	Pallet.PalletLifter.DeviceTimer	:= 400;
	PalletLifterFault	:= Pallet.PalletLifter.DeviceFault;
	Pallet.PalletLifter();
	Pallet.PalletLifterPositionReached	:= Pallet.PalletLifter.InPosition;

	Pallet.PalletConveyor2.ActualVelocity	:= PALLET_CONVEYOR_2_ACT_VEL;
	PALLET_CONVEYOR_2_ACT_VEL	:= Pallet.PalletConveyor2.TargetVelocity;			
	Pallet.PalletConveyor2.DeviceTimer	:= 400;
	PalletConveyor2Fault:= Pallet.PalletConveyor2.DeviceFault;
	Pallet.PalletConveyor2();
	Pallet.PalletConveyor2VelocityReached	:= Pallet.PalletConveyor2.InVelocity;
 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

