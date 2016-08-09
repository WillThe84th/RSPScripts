//Lunar module descent script.
clearscreen.
set itwr TO (SHIP:AVAILABLETHRUST*0.100361135657)/SHIP:MASS.
lock twr TO (SHIP:AVAILABLETHRUST*0.100361135657)/SHIP:MASS.
lock srfVel to VELOCITY:SURFACE:MAG.
lock horVel to groundspeed.
lock currentG to (SHIP:ORBIT:BODY:MU/((SHIP:ORBIT:BODY:RADIUS+SHIP:ALTITUDE)^2))/9.807.

SAS off.
lock steering to srfretrograde.
wait 5.
until alt:radar < 50 {
	lock throttle to ((srfVel/alt:radar)*(horVel/400)*(40000/alt:radar))/(itwr/0.9).
}.
SAS off.
lock steering to srfretrograde.
until srfVel < 2 {
	lock throttle to (currentG*2)/twr.
}
until alt:radar < 4 {
	lock throttle to currentG/twr.
}.
lock steering to up.
lock throttle to 0.
wait 1.