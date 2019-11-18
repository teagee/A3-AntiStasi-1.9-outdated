if (!isServer) exitWith{};

private ["_markerX","_pos","_equis","_countX","_y"];

_markerX = _this select 0;
_pos = getMarkerPos _markerX;
_equis = _pos select 0;
_y = _pos select 1;
_countX = 0;

while {(!([300,1,_pos,"OPFORSpawn"] call distanceUnits)) and (_countX < 50)} do
	{
	_countX = _countX + 1;
	_rndmslp = 5 + (random 5);
	sleep _rndmslp;
	_shell1 = "Sh_82mm_AMOS" createVehicle [_equis + (150 - (random 300)),_y + (150 - (random 300)),200];
	_shell1 setVelocity [0,0,-50];
	};

