
{REDUND_ERROR} FUNCTION_BLOCK SignalManagement (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		SignalType : DINT;
		KeyReset : BOOL;
		ActivationSignal : BOOL;
		SignalOutput : DWORD;
		SignalCode : INT;
		Reset : BOOL;
	END_VAR
	VAR_OUTPUT
		SignalOutputs : DWORD;
		ResetEnable : BOOL;
		NumberOfActiveAlarms : INT;
		NumberOfActiveWarning : INT;
		NumberOfActiveAnomalies : INT;
		NumberOfActiveInformation : INT;
		ActiveSignalCodes : ARRAY[1..20] OF INT;
		AuxResetEnable : BOOL;
		ActiveAlarmCode : INT;
		ActiveSignalCode : INT;
		ActiveAnomalyCode : INT;
		ActiveWarningCode : INT;
		ActiveInformationCode : INT;
	END_VAR
	VAR_INPUT
		SignalOperation : SMOperationType;
	END_VAR
	VAR
		NumberOfAlarms : INT;
		NumberOfAnomalies : INT;
		NumberOfInformation : INT;
		NumberOfWarnings : INT;
		ResetActivation : BOOL;
		ResetOld : BOOL;
		AuxResetActivation : BOOL;
		KeyResetOld : BOOL;
		Index : INT;
		BaseIndex : INT;
		Condition : BOOL;
		Signals : ARRAY[1..23] OF BOOL;
		AuxResetRequired : BOOL;
		i : INT;
		CurrentAlarm : INT;
		CurrentAnomaly : INT;
		CurrentWarning : INT;
		CurrentInformation : INT;
		SignalCodeDefault : INT := 0;
	END_VAR
END_FUNCTION_BLOCK
