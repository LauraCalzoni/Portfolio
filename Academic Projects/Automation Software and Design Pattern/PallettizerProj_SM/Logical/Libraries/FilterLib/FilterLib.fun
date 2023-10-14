(**)

{REDUND_ERROR} FUNCTION_BLOCK MyFilterFB (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		OperationType : INT;
		Clock : BOOL;
		Signal : BOOL;
		ActivationDelay : UDINT;
		DeactivationDelay : UDINT;
	END_VAR
	VAR_OUTPUT
		DelayedSignal : BOOL;
	END_VAR
	VAR
		Delay : UDINT;
	END_VAR
END_FUNCTION_BLOCK
