
(* TODO: Add your comment here *)
FUNCTION_BLOCK MyFilterFB
	IF (OperationType = 0) THEN 
		Delay := 0;
	END_IF;
	IF (Clock AND (Delay > 0)) THEN 
		Delay := Delay - 1; 
	END_IF;
	IF (Delay = 0) THEN 
		DelayedSignal := Signal; 
	END_IF;
	IF (Signal = DelayedSignal)	THEN
		IF (Signal) THEN 
			Delay := DeactivationDelay;
		ELSE 
			Delay := ActivationDelay;
			
		END_IF;
	END_IF;
END_FUNCTION_BLOCK
