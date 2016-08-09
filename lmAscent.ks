//Lunar module ascent script.
clearscreen.
stage.
lock throttle to 1.
lock twr TO (SHIP:AVAILABLETHRUST*0.100361135657)/SHIP:MASS.
SAS off.
lock steering to heading(90,90).
print "Ascent started.".
wait 1.

declare function turn {
	until eta:apoapsis > 120 {
		set pitchAngle to eta:apoapsis.
		set pitchAngle to pitchAngle*(-3/5).
		set pitchAngle to pitchAngle+90.
		lock steering to heading(90,pitchAngle).
	}.
}.

if eta:apoapsis < eta:periapsis {
	turn().
} else {
	lock steering to heading(90,90).
	wait until eta:apoapsis < eta:periapsis.
	turn().
}.

lock steering to heading(90,5).
wait until alt:apoapsis > 40000.
lock throttle to 0.

lock steering to heading(90,0).
SET velAtApo TO SQRT(SHIP:ORBIT:BODY:MU*((2/(SHIP:ORBIT:BODY:RADIUS+ALT:APOAPSIS))-(1/SHIP:ORBIT:SEMIMAJORAXIS))).
SET desVelAtApo TO SQRT(SHIP:ORBIT:BODY:MU/(SHIP:ORBIT:BODY:RADIUS+ALT:APOAPSIS)).
SET dVCirc TO desVelAtApo- velAtApo.
SET burnTime TO dVCirc/(twr*9.80665).
WAIT UNTIL ETA:APOAPSIS < (burnTime/2).

lock throttle to 1.
wait UNTIL SHIP:ORBIT:SEMIMAJORAXIS > (SHIP:ORBIT:BODY:RADIUS+40000).
lock throttle to 0.