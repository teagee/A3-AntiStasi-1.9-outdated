if (!isServer and hasInterface) exitWith {};

_prestigio = server getVariable "prestigeNATO";
_airportsX = airportsX - mrkAAF + ["spawnNATO"];

_originX = [_airportsX,Slowhand] call BIS_fnc_nearestPosition;
_orig = getMarkerPos _originX;

[-10,0] remoteExec ["prestige",2];

_timeLimit = _prestigio;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_nameOrigin = format ["the %1 Carrier", A3_Str_BLUE];
if (_originX!= "spawnNATO") then {_nameOrigin = [_originX] call AS_fnc_localizar};

_tsk = ["NATOCAS",[side_blue,civilian],[["%4 is providing Air support from %1. They will be under our command until %2:%3.",_nameOrigin,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_BLUE],["%1 CAS", A3_Str_BLUE],_originX],_orig,"CREATED",5,true,true,"Attack"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";

_typeVehX = bluHeliArmed;

if (_prestigio > 70) then{
	_typeVehX = bluHeliGunship; //17/10 Stef - Removed fixed wings, too difficult to assing where to fly.
}else{
	if (_prestigio > 30) then{
		_typeVehX = bluHeliGunship;
	};
};

_soldiers = [];
_vehiclesX = [];

_groupHeli = createGroup side_blue;
_groupHeli setVariable ["esNATO",true,true];
_groupHeli setGroupId ["CAS"];
hint format ["%1 CAS will be available on HC module in 35 seconds.", A3_Str_BLUE];

for "_i" from 1 to 3 do{
	_helifn = [_orig, 0, selectRandom _typeVehX, side_blue] call bis_fnc_spawnvehicle;
	_heli = _helifn select 0;
	_heli setVariable ["BLUFORSpawn",false];
	_vehiclesX pushBack _heli;
	_heliCrew = _helifn select 1;
	_groupHeliTmp = _helifn select 2;
	{[_x] spawn NATOinitCA; _soldiers pushBack _x; [_x] join _groupHeli} forEach _heliCrew;
	deleteGroup _groupHeliTmp;
	//[_heli] spawn NATOVEHinit; //This despawns the CAS vehicles as soon as they appear so i removed this. Sparker.
	_heli setPosATL [getPosATL _heli select 0, getPosATL _heli select 1, 1000];
	_heli flyInHeight 300;
	//[_heli] spawn unlimitedAmmo;
	//[_heli,"NATO CAS"] spawn inmuneConvoy;
	sleep 10;
};

Slowhand hcSetGroup [_groupHeli];
_groupHeli setVariable ["isHCgroup", true, true];

waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or ({alive _x} count _vehiclesX == 0) or ({canMove _x} count _vehiclesX == 0)};

if (dateToNumber date > _dateLimitNum) then
	{
	{["TaskSucceeded", ["", format ["%1 CAS finished", A3_Str_BLUE]]] call BIS_fnc_showNotification} remoteExec ["call", 0];
	}
else
	{
	_tsk = ["NATOCAS",[side_blue,civilian],[["%4 is providing Air support from %1. They will be under our command until %2:%3.",_nameOrigin,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_BLUE],["%1 CAS", A3_Str_BLUE],_originX],_orig,"FAILED",5,true,true,"Attack"] call BIS_fnc_setTask;
	[-5,0] remoteExec ["prestige",2];
	};

[0,_tsk] spawn deleteTaskX;

{deleteVehicle _x} forEach _soldiers;
{deleteVehicle _x} forEach _vehiclesX;
deleteGroup _groupHeli;