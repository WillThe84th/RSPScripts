//A dynamic launching script for RSS. (I wouldn't use if I were you)
DECLARE PARAMETER orbAlt.
CLEARSCREEN.

SET statu TO "10...".
LOCK twr TO (SHIP:AVAILABLETHRUSTAT(SHIP:Q)*0.100361135657)/SHIP:MASS.

DECLARE FUNCTION tryToStage {
	LIST ENGINES IN engineList.
	SET deadEngines TO 0.
	SET totalEngines TO 0.
	SET standByEngines TO 0.
	
	FOR eng IN engineList {
		IF eng:TAG = "ignore" {
			SET deadEngines TO deadEngines.
		} ELSE IF eng:FLAMEOUT {
			SET deadEngines TO deadEngines+1.
		}.
		IF NOT eng:IGNITION {
			SET standByEngines TO standByEngines+1.
		}.
		SET totalEngines to totalEngines+1.
	}.
	
	IF standByEngines = totalEngines AND SHIP:AVAILABLETHRUST = 0 {
		SET deadEngines TO deadEngines+1.
	}.
	
	IF deadEngines > 0 AND STAGE:READY {
		STAGE.
		SET statu TO "Staging".
		update().
		WAIT 2.5.
	}.
}.

IF orbAlt > 300000 {
	SET o TO orbAlt.
} ELSE {
	SET o TO 300000.
}.

DECLARE FUNCTION update {
	CLEARSCREEN.
	PRINT "Dynamic Launch System (" + o+ " m)" AT(0,0).
	
	PRINT "Status: " + statu AT (0,2).
	PRINT "TWR: " + ROUND(twr,3) AT(0,3).
	PRINT "Surface Velocity: " + ROUND(SHIP:VELOCITY:SURFACE:MAG,1) + " m/s" AT(0,4).
	
	PRINT "Apogee: " + ROUND(ALT:APOAPSIS,1) + " m" AT(0,6).
	PRINT "Perigee: " + ROUND(ALT:PERIAPSIS,1) + " m" AT(0,7).
	PRINT "SMA: " + ROUND(SHIP:ORBIT:SEMIMAJORAXIS,1) + " m" AT(0,8).
	PRINT "Orbital Velocity: " + ROUND(SHIP:VELOCITY:ORBIT:MAG,1) + " m/s" AT(0,9).
}.

update().
LOCK THROTTLE TO 1.
WAIT 1.
SET statu TO "9...".
update().
WAIT 1.
SET statu TO "8...".
update().
WAIT 1.
SET statu TO "7...".
update().
WAIT 1.
SET statu TO "6...".
STAGE.
update().
WAIT 1.
SET statu TO "5...".
update().
WAIT 1.
SET statu TO "4...".
update().
WAIT 1.
SET statu TO "5...".
update().
WAIT 1.
SET statu TO "4...".
update().
WAIT 1.
SET statu TO "3...".
update().
WAIT 1.
SET statu TO "2...".
update().
WAIT 1.
SET statu TO "1...".
update().
WAIT 1.
SET statu TO "Liftoff!".
update().
STAGE.

SAS ON.
WAIT 2.
SAS OFF.
SET pitchAngle TO 90.
LOCK STEERING TO HEADING(90,pitchAngle).

IF twr > 1.45 {
	WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG > 50.
	SAS ON.
	UNTIL SHIP:VELOCITY:SURFACE:MAG > 1000 {
		SET pitchAngle TO SHIP:VELOCITY:SURFACE:MAG.
		SET pitchAngle to pitchAngle * (-9/190).
		SET pitchAngle to pitchAngle + (1755/19).
		LOCK STEERING TO HEADING(90,pitchAngle).
		SET statu TO "Gravity turn (shallower)".
		tryToStage().
		update().
	}.
} ELSE {
	WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG > 150.
	SAS ON.
	UNTIL SHIP:VELOCITY:SURFACE:MAG > 1000 {
		SET pitchAngle TO SHIP:VELOCITY:SURFACE:MAG.
		SET pitchAngle to pitchAngle * (-9/170).
		SET pitchAngle to pitchAngle + (1665/17).
		LOCK STEERING TO HEADING(90,pitchAngle).
		SET statu TO "Gravity turn (steeper)".
		tryToStage().
		update().
	}.
}.

UNTIL SHIP:VELOCITY:SURFACE:MAG > 4250 {
	SET pitchAngle TO SHIP:VELOCITY:SURFACE:MAG.
	SET pitchAngle to pitchAngle * (-43/3250).
	SET pitchAngle to pitchAngle + (757/13).
	LOCK STEERING TO HEADING(90,pitchAngle).
	SET statu TO "Gravity turn".
	tryToStage().
	update().
}.

SAS OFF.

UNTIL ALT:APOAPSIS > o { 
	IF ETA:APOAPSIS < 120 OR ETA:APOAPSIS > ETA:PERIAPSIS {
		LOCK STEERING TO HEADING(90,30).
	} ELSE {
		LOCK STEERING TO HEADING(90,0).
	}.
	SET statu TO "Raising Apogee".
	tryToStage().
	update().
}.

LOCK THROTTLE TO 0.
SET statu TO "Coasting to apogee".
update().
WAIT 2.

SET velAtApo TO SQRT(EARTH:MU*((2/(EARTH:RADIUS+ALT:APOAPSIS))-(1/SHIP:ORBIT:SEMIMAJORAXIS))).
SET desVelAtApo TO SQRT(EARTH:MU/(EARTH:RADIUS+ALT:APOAPSIS)).
SET dVCirc TO desVelAtApo- velAtApo. 
SET burnTime TO dVCirc/(twr*9.80665).

PRINT "Velocity at apoapsis is " + velAtApo + " m/s.".
PRINT "Desired velocity at apoapsis is " + desVelAtApo + " m/s.".
PRINT "Delta V to circularize is " + dVCirc + " m/s.".
PRINT "Burn will take " + burnTime + " seconds.".
RCS ON.
LOCK STEERING TO PROGRADE.

WAIT UNTIL ETA:APOAPSIS < (burnTime/2).
UNTIL SHIP:ORBIT:SEMIMAJORAXIS > (EARTH:RADIUS+o) {
	LOCK THROTTLE TO 1.
	SET statu TO "Cicularizing".
	tryToStage().
	update().
}
LOCK THROTTLE TO 0.
SET statu TO "In orbit".
update().
