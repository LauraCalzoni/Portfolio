
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	//Pallet_light_barrier1 filtering
	PalletLightBarrierSensor1.OperationType := OperationType;
	PalletLightBarrierSensor1.Clock := TRUE;
	PalletLightBarrierSensor1.Signal  := PALLET_LIGHT_BARRIER_1_IR;
	PalletLightBarrierSensor1.ActivationDelay := 2;
	PalletLightBarrierSensor1.DeactivationDelay  := 0;
	PalletLightBarrierSensor1();
	
	pallet_light_barrier_1 := PalletLightBarrierSensor1.DelayedSignal;
	
	//Pallet_light_barrier2 filtering
	PalletLightBarrierSensor2.OperationType := OperationType;
	PalletLightBarrierSensor2.Clock := TRUE;
	PalletLightBarrierSensor2.Signal  := PALLET_LIGHT_BARRIER_2_IR;
	PalletLightBarrierSensor2.ActivationDelay := 2;
	PalletLightBarrierSensor2.DeactivationDelay  := 0;
	PalletLightBarrierSensor2();
	
	pallet_light_barrier_2 := PalletLightBarrierSensor2.DelayedSignal;

	//Sensor1 filtering
	LaserSensor.OperationType := OperationType;
	LaserSensor.Clock := TRUE;
	LaserSensor.Signal  := LASER_SENSOR_IR;
	LaserSensor.ActivationDelay := 2;
	LaserSensor.DeactivationDelay  := 0;
	LaserSensor();

	laser_sensor := LaserSensor.DelayedSignal;
	
	//Sensor2 filtering
	LaserSensor2.OperationType := OperationType;
	LaserSensor2.Clock := TRUE;
	LaserSensor2.Signal  := LASER_SENSOR_2_IR;
	LaserSensor2.ActivationDelay := 2;
	LaserSensor2.DeactivationDelay  := 0;
	LaserSensor2();
	
	laser_sensor2 := LaserSensor2.DelayedSignal;
	
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

