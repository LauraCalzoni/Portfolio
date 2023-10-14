
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	// Recognize input
	
	IF OnPhaseStopHMI_input THEN
		OnPhaseStopHMI :=TRUE;
	END_IF
	
	IF (OperationType = INIT) THEN 
		SignalManager(SignalOperation := START_CONFIGURATION);
		SignalManager(SignalOperation  := CONFIGURATION);
	ELSIF NOT (OperationType = INIT) THEN
		SignalManager(SignalOperation 	:= START_GENERATION); 
		SignalManager(SignalOperation 	:= GENERATION); 
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
	
	
	
	EmergencyStop	:= ((SignalManager.SignalOutputs AND EMERGENCY_STOP) = EMERGENCY_STOP);
	ImmediateStop	:= ((SignalManager.SignalOutputs AND IMMEDIATE_STOP) = IMMEDIATE_STOP);
	OnPhaseStop		:= ((SignalManager.SignalOutputs AND ON_PHASE_STOP)  = ON_PHASE_STOP);
	
	
	
	
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

