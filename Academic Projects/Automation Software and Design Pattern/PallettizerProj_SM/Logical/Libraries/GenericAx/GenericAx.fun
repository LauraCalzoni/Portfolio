
FUNCTION_BLOCK GenericAxis
	VAR_INPUT
		Command : WORD := 0;
		ActualPosition : REAL;
		ActualVelocity : REAL;
		NewSetPoint : REAL;
		DeviceTimer : INT;
		TGT_SENSOR : BOOL;
		Reset : BOOL;
	END_VAR
	VAR_OUTPUT
		TargetVelocity : REAL;
		TargetPosition : REAL;
		InPosition : BOOL := 1;
		InVelocity : BOOL := 1;
		DeviceFault : BOOL;
		AxisBusy : BOOL;
	END_VAR
	VAR
		AxisState : GA_State := CheckCommand;
		Timer : INT;
	END_VAR
END_FUNCTION_BLOCK
