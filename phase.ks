//Script for caluculating phase angles and transfering/rendezvousing with the target.
LOCK shipAngle TO SHIP:ORBIT:LAN+SHIP:ORBIT:ARGUMENTOFPERIAPSIS+SHIP:ORBIT:TRUEANOMALY.
LOCK targetAngle TO TARGET:ORBIT:LAN+TARGET:ORBIT:ARGUMENTOFPERIAPSIS+TARGET:ORBIT:TRUEANOMALY.
LOCK currentPhaseAngle TO (targetAngle-shipAngle)-360*floor((targetAngle-shipAngle)/360).
LOCK twr TO (SHIP:AVAILABLETHRUST*0.100361135657)/SHIP:MASS.

set transferSMA to (SHIP:ORBIT:SEMIMAJORAXIS+TARGET:ORBIT:SEMIMAJORAXIS)/2.
set transferTime to CONSTANT:PI*SQRT((transferSMA^3)/SHIP:ORBIT:BODY:MU).
set transferVel to SQRT(SHIP:ORBIT:BODY:MU*((2/SHIP:ORBIT:SEMIMAJORAXIS)-(1/transferSMA))).
set velAtTransfer to SQRT(SHIP:ORBIT:BODY:MU/(SHIP:ORBIT:SEMIMAJORAXIS)).

set transferDeltaV to transferVel-velAtTransfer.
set burnTime TO transferDeltaV/(twr*9.80665).

set targetAngVel to (TARGET:VELOCITY:ORBIT:MAG/TARGET:ORBIT:SEMIMAJORAXIS)*CONSTANT:RadToDeg.
set shipAngVel to (SHIP:VELOCITY:ORBIT:MAG/SHIP:ORBIT:SEMIMAJORAXIS)*CONSTANT:RadToDeg.
set relAngVel to targetAngVel-shipAngVel.

set desPhaseAngle to 180-(targetAngVel*transferTime).

SAS OFF.
set timeToBurn to 1000000000000000.
LOCK STEERING TO PROGRADE.
until timeToBurn < 0.5*burnTime {
	clearscreen.
	if relAngVel < 0 {
		if currentPhaseAngle > desPhaseAngle {
			set timeToBurn to (currentPhaseAngle-desPhaseAngle)*(1/ABS(relAngVel)).
		} else {
			set timeToBurn to (currentPhaseAngle+(360-desPhaseAngle))*(1/ABS(relAngVel)).
		}.
	} else if relAngVel > 0 {
		if desPhaseAngle > currentPhaseAngle {
			set timeToBurn to (desPhaseAngle-currentPhaseAngle)*(1/ABS(relAngVel)).
		} else {
			set timeToBurn to ((360-currentPhaseAngle)+desPhaseAngle)*(1/ABS(relAngVel)).
		}
	}.
	
	print "Current phase angle: " + currentPhaseAngle.
	print "Desired phase angle: " + desPhaseAngle.
	print "Time to burn: " + timeToBurn.
	print "Burn time: " + burnTime.
	wait 0.1.
}.
SAS ON.
LOCK THROTTLE TO 1.
wait until SHIP:ORBIT:SEMIMAJORAXIS > transferSMA.
LOCK THROTTLE TO 1.