if (!isServer and hasInterface) exitWith{};

/*
parameters
0: base/airport/carrier to start from
1: target location

If origin is an airport/carrier, the QRF will consist of air cavalry. Otherwise it'll be ground forces in MRAPs.
*/

_orig = _this select 0;
_dest = _this select 1;

// names of locations for the task description
_origName = format ["the %1 carrier", A3_Str_BLUE];
_destName = [([citiesX, _dest] call BIS_fnc_nearestPosition)] call AS_fnc_localizar;

// kind of QRF: air/land
_type = "air";

// FIA bases
_bases = bases arrayIntersect mrkFIA;

// define type of QRF by type of origin
if (_orig != "spawnNATO") then {
	_origName = [_orig] call AS_fnc_localizar;
	if (_orig in _bases) then {
		_type = "land";
	};
};

_posOrig = getMarkerPos _orig;

// marker on the map, required for the UPS script
_mrk = createMarker ["NATOQRF", _dest];
_mrk setMarkerShape "ICON";
_mrk setMarkerType "b_support";
_mrk setMarkerText (format ["%1 QRF", A3_Str_BLUE]);

// mission time restricted to 30 minutes
_timeLimit = 30;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_tsk = ["NATOQRF",[side_blue,civilian],[["Our Commander asked %3 for reinforcements near %1. Their troops will depart from %2.",_destName,_origName, A3_Str_BLUE],["%1 QRF", A3_Str_BLUE],_mrk],_dest,"CREATED",5,true,true,"Move"] call BIS_fnc_setTask;
missionsX pushBackUnique _tsk; publicVariable "missionsX";

// cost: 10 NATO
[-10,0] remoteExec ["prestige",2];


// arrays of all spawned units/groups
_groups = [];
_soldiers = [];
_vehiclesX = [];

// initialise groups, two for vehicles, two for dismounts
_grpVeh1 = createGroup side_blue;
_groups pushBack _grpVeh1;

_grpVeh2 = createGroup side_blue;
_groups pushBack _grpVeh2;

_grpDis1 = createGroup side_blue;
_groups pushBack _grpDis1;

_grpDis2 = createGroup side_blue;
_groups pushBack _grpDis2;

// air cav
if (_type == "air") then {

	// landing pad, to allow for dismounts
	_landpos1 = [];
	_landpos1 = [_dest, 0, 150, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
	_landpos1 set [2, 0];
	_pad1 = createVehicle ["Land_HelipadEmpty_F", _landpos1, [], 0, "NONE"];
	_vehiclesX = _vehiclesX + [_pad1];

	// first chopper
	_vehicle = [_posOrig, 0, selectRandom bluHeliArmed, side_blue] call bis_fnc_spawnvehicle;
	_heli1 = _vehicle select 0;
	_heli1 setVariable ["BLUFORSpawn",false];
	_heliCrew = _vehicle select 1;
	_grpVeh1 = _vehicle select 2;
	{[_x] spawn NATOinitCA} forEach _heliCrew;
	[_heli1] spawn NATOVEHinit;
	_soldiers = _soldiers + _heliCrew;
	_groups = _groups + [_grpVeh1];
	_vehiclesX = _vehiclesX + [_heli1];
	_heli1 lock 3;

	// spawn loiter script for armed escort
	[_grpVeh1, _posOrig, _dest, 15*60] spawn AS_fnc_QRF_gunship;

	sleep 5;

	// shift the spawn position of second chopper to avoid crash
	_pos2 = _posOrig;
	_xshift2 = (_posOrig select 0) + 30;
	_zshift2 = (_posOrig select 2) + 50;
	_pos2 set [0, _xshift2];
	_pos2 set [2, _zshift2];
	_vehicle2 = [_pos2, 0, selectRandom bluHeliTS, side_blue] call bis_fnc_spawnvehicle;
	_heli2 = _vehicle2 select 0;
	_heli2 setVariable ["BLUFORSpawn",false];
	_heliCrew2 = _vehicle2 select 1;
	_grpVeh2 = _vehicle2 select 2;
	{[_x] spawn NATOinitCA} forEach _heliCrew2;
	[_heli2] spawn NATOVEHinit;
	_soldiers = _soldiers + _heliCrew2;
	_groups = _groups + [_grpVeh2];
	_vehiclesX = _vehiclesX + [_heli2];
	_heli2 lock 3;

	// add dismounts
	{
		_soldier = ([_posOrig, 0, _x, _grpDis2] call bis_fnc_spawnvehicle) select 0;
		[_soldier] spawn NATOinitCA;
		_soldiers pushBack _soldier;
		_soldier assignAsCargo _heli2;
		_soldier moveInCargo _heli2;
	} forEach bluAirCav;
	_grpDis2 selectLeader (units _grpDis2 select 0);

	// spawn dismount script
	[_grpVeh2, _posOrig, _landpos1, _mrk, _grpDis2, 25*60, "land"] spawn AS_fnc_QRF_airCavalry;
}

// ground convoy
else {
	_radiusX = 10;
	_roads = [];

	while {true} do {
	_roads = _posOrig nearRoads _radiusX;
	if (count _roads > 2) exitWith {};
	_radiusX = _radiusX + 10;
	};

	// first MRAP, escort
	_vehicle1 = [position (_roads select 0), 0, bluMRAPHMG select 0, side_blue] call bis_fnc_spawnvehicle;
	_veh1 = _vehicle1 select 0;
	[_veh1] spawn NATOVEHinit;
	[_veh1,"NATO Armor"] spawn inmuneConvoy;
	_vehCrew1 = _vehicle1 select 1;
	_grpVeh1 = _vehicle1 select 2;
	{[_x] spawn NATOinitCA} forEach _vehCrew1;
	_soldiers = _soldiers + _vehCrew1;
	_vehiclesX = _vehiclesX + [_veh1];

	// add dismounts
	{
		_soldier = ([_posOrig, 0, _x, _grpDis1] call bis_fnc_spawnvehicle) select 0;
		[_soldier] spawn NATOinitCA;
		_soldier assignAsCargo _veh1;
		_soldier moveInCargo _veh1;
		_soldiers pushBack _soldier;
	} forEach bluMRAPHMGgroup;
	_grpDis1 selectLeader (units _grpDis1 select 0);

	// spawn dismount script
	[_grpVeh1, _posOrig, _dest, _mrk, _grpDis1, 25*60] spawn AS_fnc_QRF_leadVehicle;

	sleep 15;

	// second MRAP
	_vehicle2 = [position (_roads select 1), 0, selectRandom bluMRAP, side_blue] call bis_fnc_spawnvehicle;
	_veh2 = _vehicle2 select 0;
	[_veh2] spawn NATOVEHinit;
	[_veh2,"NATO Armor"] spawn inmuneConvoy;
	_vehCrew2 = _vehicle2 select 1;
	_grpVeh2 = _vehicle2 select 2;
	{[_x] spawn NATOinitCA} forEach _vehCrew2;
	_soldiers = _soldiers + _vehCrew2;
	_vehiclesX = _vehiclesX + [_veh2];

	// add dismounts
	{
		_soldier = ([_posOrig, 0, _x, _grpDis2] call bis_fnc_spawnvehicle) select 0;
		[_soldier] spawn NATOinitCA;
		_soldier assignAsCargo _veh2;
		_soldier moveInCargo _veh2;
		_soldiers pushBack _soldier;
	} forEach bluMRAPgroup;
	_grpDis2 selectLeader (units _grpDis2 select 0);


	// spawn dismount script
	_pos3 =+ _dest;
	_xshift3 = (_dest select 0) + 30;
	_pos3 set [0, _xshift3];
	[_grpVeh2, _posOrig, _pos3, _mrk, _grpDis2, 25, "assault"] spawn AS_fnc_QRF_dismountTroops;
};

{
	_x setVariable ["esNATO",true,true];
} foreach _groups;


// you lose if all soldiers die before the timer runs out
waitUntil {sleep 10; (dateToNumber date > _dateLimitNum) or ({alive _x} count _soldiers == 0)};

if (dateToNumber date > _dateLimitNum) then {
	_tsk = ["NATOQRF",[side_blue,civilian],[["Our Commander asked %3 for reinforcements near %1. Their troops will depart from %2",_destName,_origName, A3_Str_BLUE],["%1 QRF", A3_Str_BLUE],_mrk],_dest,"SUCCEEDED",5,true,true,"Move"] call BIS_fnc_setTask;
}
else {
	_tsk = ["NATOQRF",[side_blue,civilian],[["Our Commander asked %3 for reinforcements near %1. Their troops will depart from %2",_destName,_origName, A3_Str_BLUE],["%1 QRF", A3_Str_BLUE],_mrk],_dest,"FAILED",5,true,true,"Move"] call BIS_fnc_setTask;
	[-5,0] remoteExec ["prestige",2];
};

sleep 15;
deleteMarker "NATOQRF";
[0,_tsk] spawn deleteTaskX;

// despawn everything
{
	_soldierX = _x;
	waitUntil {sleep 1; {_x distance _soldierX < distanceSPWN} count (allPlayers - (entities "HeadlessClient_F")) == 0};
	deleteVehicle _soldierX;
} forEach _soldiers;

{deleteGroup _x} forEach _groups;

{
	_vehiculo = _x;
	waitUntil {sleep 1; {_x distance _vehiculo < distanceSPWN/2} count (allPlayers - (entities "HeadlessClient_F")) == 0};
	deleteVehicle _x
} forEach _vehiclesX;
