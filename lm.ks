//Compilation of both lm scripts.
clearscreen.
set itwr TO (SHIP:AVAILABLETHRUST*0.100361135657)/SHIP:MASS.
lock twr TO (SHIP:AVAILABLETHRUST*0.100361135657)/SHIP:MASS.
lock srfVel to VELOCITY:SURFACE:MAG.
lock horVel to groundspeed.
lock vertVel to verticalspeed.
lock currentG to (SHIP:ORBIT:BODY:MU/((SHIP:ORBIT:BODY:RADIUS+SHIP:ALTITUDE)^2))/9.807.

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
	Print "Crew are safe in orbit!".
}.

declare function descend {
	until abort {
		SAS off.
		lock steering to srfretrograde.
		wait 5.
		until alt:radar < 50 {
			lock throttle to ((srfVel/alt:radar)*(horVel/400)*(40000/alt:radar))/(itwr/0.9).
			if abort {
				Print "Aborting descent!".
				launch().
			}.
		}.
		SAS off.
		lock steering to srfretrograde.
		toggle gear.
		until srfVel < 2 {
			lock throttle to (currentG*2)/twr.
			if abort {
				Print "Aborting descent!".
				launch().
			}.
		}
		until alt:radar < 4 {
			lock throttle to currentG/twr.
			if abort {
				Print "Aborting descent!".
				launch().
			}.
		}.
		lock throttle to 0.
		unlock steering.
		Print "Touchdown!".
		Print "Waiting for liftoff...".
		wait 1.
		return.
	}.
	Print "Aborting descent!"
	launch().
}.

when twr = 0 AND alt:radar > 5 AND throttle > 0 then {
	set abort to true.
}

descend().
wait until abort.
Print "Liftoff!".
launch().