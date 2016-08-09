//Compilation of both lm scripts.
clearscreen.
set itwr TO (SHIP:AVAILABLETHRUST*0.100361135657)/SHIP:MASS.
lock twr TO (SHIP:AVAILABLETHRUST*0.100361135657)/SHIP:MASS.
lock srfVel to VELOCITY:SURFACE:MAG.
lock horVel to groundspeed.
lock vertVel to verticalspeed.
lock currentG to (SHIP:ORBIT:BODY:MU/((SHIP:ORBIT:BODY:RADIUS+SHIP:ALTITUDE)^2))/9.807.

declare function descend {
	SAS off.
	lock steering to srfretrograde.
	wait 5.
	until alt:radar < 50 {
		lock throttle to ((srfVel/alt:radar)*(horVel/400)*(40000/alt:radar))/(itwr/0.9).
	}.
	SAS off.
	lock steering to srfretrograde.
	set legs to true.
	until srfVel < 2 {
		lock throttle to (currentG*2)/twr.
	}
	until alt:radar < 4 {
		lock throttle to currentG/twr.
	}.
	lock steering to up.
	lock throttle to 0.
	wait 1.
}.

declare function launch {
	lock throttle to 0.
	stage.
	lock throttle to 1.
	lock steering to heading(90,90).
	wait until eta:apoapsis > 30 AND vertVel > 0.
	until alt:apoapsis > 40000 {
		if eta:apoapsis > 120 {
			lock steering to heading(90,5).
		} else {
			lock steering to heading(90,45).
		}.
	}.
}.

descend().
when abort then {
	launch().
}