
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	// Recognize input

	
	IF (OperationType = INIT) THEN 
		SignalManager(SignalOperation := START_CONFIGURATION);
		SignalManager.SignalOperation  := CONFIGURATION;
	ELSE
		SignalManager(SignalOperation 	:= START_GENERATION); 
		SignalManager.SignalOperation 	:= GENERATION; 
	END_IF;
	
	SignalManager.ActivationSignal := OnPhaseStopHMI;
	SignalManager.SignalCode := 1;
	SignalManager.SignalType := ANOMALY;
	SignalManager.SignalOutput := ON_PHASE_STOP;
	SignalManager.Reset := Reset;
	SignalManager();
	
	SignalManager.ActivationSignal := NoMorePallet;
	SignalManager.SignalCode := 2;
	SignalManager.SignalType := ANOMALY;
	SignalManager.SignalOutput := ON_PHASE_STOP;
	SignalManager.Reset := Reset;
	SignalManager();
	
	SignalManager.ActivationSignal := ImmediateStopHMI;
	SignalManager.SignalCode := 3;
	SignalManager.SignalType := ALARM OR AUX_RESET;
	SignalManager.SignalOutput := IMMEDIATE_STOP;
	SignalManager.KeyReset := AuxReset;
	SignalManager();
	
	//Feeder
	SignalManager.ActivationSignal :=  ConveyorIfFaultHMI;
	SignalManager.SignalCode := 4;
	SignalManager.SignalType := ALARM OR AUX_RESET;
	SignalManager.SignalOutput := IMMEDIATE_STOP;
	SignalManager.KeyReset := AuxReset;
	SignalManager();
	
	SignalManager.ActivationSignal := ConveyorEndFaultHMI;
	SignalManager.SignalCode := 5;
	SignalManager.SignalType := ALARM OR AUX_RESET;
	SignalManager.SignalOutput := IMMEDIATE_STOP;
	SignalManager.KeyReset := AuxReset;
	SignalManager();
	
	SignalManager.ActivationSignal := ConveyorTurnFaultHMI;
	SignalManager.SignalCode := 6;
	SignalManager.SignalType := ALARM OR AUX_RESET;
	SignalManager.SignalOutput := IMMEDIATE_STOP;
	SignalManager.KeyReset := AuxReset;
	SignalManager();
	
	SignalManager.ActivationSignal := PusherFaultHMI;
	SignalManager.SignalCode := 7;
	SignalManager.SignalType := ALARM OR AUX_RESET;
	SignalManager.SignalOutput := IMMEDIATE_STOP;
	SignalManager.KeyReset := AuxReset;
	SignalManager();
	
	SignalManager.ActivationSignal := TurnPusherFaultHMI;
	SignalManager.SignalCode := 8;
	SignalManager.SignalType := ALARM OR AUX_RESET;
	SignalManager.SignalOutput := IMMEDIATE_STOP;
	SignalManager.KeyReset := AuxReset;
	SignalManager();
	
	SignalManager.ActivationSignal := CarriageFaultHMI;
	SignalManager.SignalCode := 9;
	SignalManager.SignalType := ALARM OR AUX_RESET;
	SignalManager.SignalOutput := IMMEDIATE_STOP;
	SignalManager.KeyReset := AuxReset;
	SignalManager();
	
	
	
	EmergencyStop	:= ((SignalManager.SignalOutputs AND EMERGENCY_STOP) = EMERGENCY_STOP);
	ImmediateStop	:= ((SignalManager.SignalOutputs AND IMMEDIATE_STOP) = IMMEDIATE_STOP);
	OnPhaseStop		:= ((SignalManager.SignalOutputs AND ON_PHASE_STOP)  = ON_PHASE_STOP);
	
	
	
	
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

