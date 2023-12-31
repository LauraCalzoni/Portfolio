
(* TODO: Add your comment here *)
FUNCTION_BLOCK GenericAxis
	
	CASE (AxisState) OF
		
		
		CheckCommand:
			
			
			//			IF Command = IDLE THEN
			//				Timer	:= DeviceTimer;
			//				DeviceFault	:= FALSE;
			//			END_IF;
			
			IF Command = CHANGE_POSITION THEN
				
				IF (ActualPosition <> NewSetPoint) THEN
					Timer	:= DeviceTimer;
					InPosition	:= FALSE;
					TargetPosition := NewSetPoint;
					AxisState := WaitTargetPosition;
				END_IF

			END_IF;
			
			IF Command = CHANGE_VELOCITY THEN
				
				IF (ActualVelocity <> NewSetPoint) THEN
					Timer	:= DeviceTimer;
					TargetVelocity := NewSetPoint;
					InVelocity	:= FALSE;
					AxisState	:= WaitTargetVelocity;
				END_IF
				
			END_IF;
			
			
//			IF Command = IMMEDIATE_STOP_REQUEST THEN
//				
//				TargetPosition	:= ActualPosition;
//				TargetVelocity	:= 0;
//				IF (ActualPosition = TargetPosition AND ActualVelocity = TargetVelocity) THEN
//					InPosition	:= TRUE;
//					InVelocity	:= TRUE;
//					AxisState	:= CheckCommand;
//				END_IF;
//				
//			END_IF;
			
			IF Command = EMERGENCY_STOP_REQUEST THEN
				TargetPosition	:= ActualPosition;
				TargetVelocity	:= 0;
				IF (ActualPosition = TargetPosition AND ActualVelocity = TargetVelocity) THEN
					InPosition	:= TRUE;
					InVelocity	:= TRUE;
					AxisState	:= CheckCommand;
				END_IF;
			END_IF;
			
		WaitTargetPosition:
			IF (ActualPosition = TargetPosition AND TGT_SENSOR) THEN
				InPosition	:= TRUE;
				AxisState	:= CheckCommand;
			END_IF;
			Timer	:= Timer	- 1;
			IF Timer = 0 THEN
				DeviceFault	:= TRUE;
				AxisState	:= FaultState;
			END_IF;

		WaitTargetVelocity:
			IF ActualVelocity = TargetVelocity THEN
				InVelocity	:= TRUE;
				AxisState	:= CheckCommand;
			END_IF;
			Timer	:= Timer	- 1;
			IF Timer = 0 THEN
				DeviceFault	:= TRUE;
				AxisState	:= FaultState;
			END_IF;
		
		FaultState:
			IF Reset THEN
				DeviceFault	:= FALSE;
				AxisState	:= CheckCommand;
			END_IF;



		
	END_CASE;
	
END_FUNCTION_BLOCK
