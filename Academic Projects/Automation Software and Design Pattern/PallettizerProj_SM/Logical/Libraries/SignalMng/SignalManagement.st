
(* TODO: Add your comment here *)
FUNCTION_BLOCK SignalManagement
	
	CASE SignalOperation OF
		
		START_CONFIGURATION: (* reset signal count*)
			
			NumberOfAlarms := 0; 
			NumberOfAnomalies := 0;
			NumberOfInformation := 0;
			NumberOfWarnings := 0;
			
		CONFIGURATION:

			CASE (SignalType AND SIGNAL_TYPE_MASK) OF
				ALARM:
					NumberOfAlarms := NumberOfAlarms + 1;
				ANOMALY:
					NumberOfAnomalies := NumberOfAnomalies + 1;
				WARNING:
					NumberOfWarnings := NumberOfWarnings + 1;
				INFORMATION:
					NumberOfInformation := NumberOfInformation + 1;
			END_CASE
			
		START_GENERATION:
			
			ResetEnable := FALSE;
			SignalOutputs := NONE;
			ResetActivation := Reset AND NOT ResetOld;
			ResetOld := Reset;
			AuxResetEnable	:= FALSE;
			AuxResetActivation := KeyReset AND NOT KeyResetOld;
			KeyResetOld:= KeyReset;

		GENERATION:
			CASE (SignalType AND SIGNAL_TYPE_MASK) OF
				ALARM:
					Index := NumberOfActiveAlarms;
					BaseIndex := 0;
					Condition := TRUE;
				ANOMALY:
					Index := NumberOfActiveAnomalies;
					BaseIndex := NumberOfAlarms;
					Condition := TRUE;
				WARNING:
					Index := NumberOfActiveWarning;
					BaseIndex := NumberOfAlarms + NumberOfAnomalies;
					Condition := TRUE;
				INFORMATION:
					Index := NumberOfActiveInformation;
					BaseIndex := NumberOfAlarms + NumberOfAnomalies + NumberOfWarnings;
					Condition := TRUE;
			END_CASE
			
			IF ActivationSignal AND NOT Signals[SignalCode] THEN
				Signals[SignalCode] := TRUE;
				Index := Index + 1;
				ActiveSignalCodes[BaseIndex + Index] := SignalCode;
			END_IF
			
			AuxResetRequired := ((SignalType AND AUX_RESET) = AUX_RESET);
			
			IF (Condition AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode) AND AuxResetRequired) THEN
				AuxResetEnable := TRUE; // LED AUX RECOVERY GREEN
			END_IF
			
			IF (Condition AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode)) THEN
				ResetEnable := TRUE; // LED RECOVERY GREEN
			END_IF
			
			IF ((ResetActivation OR NOT Condition) AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode)) THEN
				Signals[SignalCode] := FALSE;
				
				FOR i := 2 TO Index DO
					ActiveSignalCodes[BaseIndex + i-1] := ActiveSignalCodes[BaseIndex + i];
				END_FOR;
				
				ActiveSignalCodes[BaseIndex + Index] := 0;
				Index := Index - 1;
				ResetActivation := FALSE; 
			END_IF

			IF ((AuxResetActivation OR NOT Condition) AND Signals[SignalCode] AND NOT ActivationSignal AND (ActiveSignalCodes[BaseIndex + 1] = SignalCode) AND AuxResetRequired) THEN
				Signals[SignalCode] := FALSE;
				
				FOR i := 2 TO Index DO
					ActiveSignalCodes[BaseIndex + i-1] := ActiveSignalCodes[BaseIndex + i];
				END_FOR;
				
				ActiveSignalCodes[BaseIndex + Index] := 0;
				Index := Index - 1;
				AuxResetActivation := FALSE; 
			END_IF
			
			CASE (SignalType AND SIGNAL_TYPE_MASK) OF
				ALARM:
					NumberOfActiveAlarms := Index;
				ANOMALY:
					NumberOfActiveAnomalies := Index;
				WARNING:
					NumberOfActiveWarning := Index;
				INFORMATION:
					NumberOfActiveInformation := Index;
			END_CASE
			
			IF Signals[SignalCode] THEN
				SignalOutputs := SignalOutputs OR SignalOutput;
			END_IF
			
		RUN_SM:
			CurrentAlarm := NumberOfActiveAlarms; 
			CurrentAnomaly := NumberOfActiveAnomalies;
			CurrentWarning := NumberOfActiveWarning;
			CurrentInformation := NumberOfActiveInformation;
		
			IF NumberOfActiveAlarms > 0 THEN
				ActiveAlarmCode := ActiveSignalCodes[CurrentAlarm];			
			ELSE
				ActiveAlarmCode := SignalCodeDefault;
			END_IF
			
			IF NumberOfActiveAnomalies > 0 THEN
				ActiveAnomalyCode := ActiveSignalCodes[NumberOfAlarms + CurrentAnomaly];
			ELSE
				ActiveAnomalyCode := SignalCodeDefault;
			END_IF
			
			IF NumberOfActiveWarning > 0 THEN
				ActiveWarningCode := ActiveSignalCodes[NumberOfAlarms + NumberOfAnomalies + CurrentWarning];
			ELSE
				ActiveWarningCode := SignalCodeDefault;
			END_IF
			
			IF NumberOfActiveInformation > 0 THEN
				ActiveInformationCode := ActiveSignalCodes[NumberOfAlarms + NumberOfAnomalies + NumberOfWarnings + CurrentInformation];
			ELSE
				ActiveInformationCode := SignalCodeDefault;
			END_IF;
		
	END_CASE
	
			
			
		
	
END_FUNCTION_BLOCK
