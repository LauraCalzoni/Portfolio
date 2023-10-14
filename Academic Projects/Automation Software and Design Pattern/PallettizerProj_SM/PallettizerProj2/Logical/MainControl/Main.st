
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	CASE MainState OF 
		
		
		Initialization:
			
			IF (OperationType = INIT) THEN
				
				OperationType := RUN;
				MainState := WaitStart;
				
			END_IF 
		
			
		WaitStart:
			
			IF(START_MACHINE) THEN
				
				START_FEEDER := TRUE;
				START_CRANE := TRUE;
				START_PALLET_HANDLER := TRUE;
				MainState := WaitCrane;
			END_IF
		
			
		WaitCrane:
		
			IF CraneHomed THEN 
							
				PushLayer := TRUE;
				MainState := WaitFeeder;
				
			END_IF
		
			IF FullPalletReady THEN 
				
				PalletExpultion := TRUE;
				MainState := WaitPalletHandler;
				
			END_IF
		
			
		WaitFeeder:
						
			IF LayerPositioned THEN
							
				MoveCrane := TRUE;
				MainState := WaitPalletHandler;
				
			END_IF
		
			
		WaitPalletHandler:
			
			IF OnPhaseStopHMI AND PalletExpultion THEN	
				MainState := StopMachine;	
			END_IF
			
				
			
			IF PalletPositioned AND NOT (OnPhaseStopHMI AND PalletExpultion) THEN
				
				CraneEnabled := TRUE;
				MainState := WaitCrane;
				
			END_IF
				
		
		
		StopMachine:
			
			START_MACHINE := FALSE;
			START_FEEDER := FALSE;
			START_CRANE := FALSE;
			START_PALLET_HANDLER := FALSE;
		
			IF Reset THEN
				
				OnPhaseStopHMI := FALSE;
				MainState := WaitStart;
				
			END_IF
		
				
				
				

	END_CASE
	
	
	
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

