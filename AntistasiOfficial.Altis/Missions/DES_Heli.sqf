if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_DesHeli";
_tskDesc = "STR_TSK_TD_DESC_DesHeli";

private ["_poscrash","_markerX","_positionX","_mrkFinal","_typeVehX","_effect","_heli","_vehiclesX","_soldiers","_groups","_unit","_roads","_road","_vehicle","_veh","_typeGroup","_tsk","_smokeX","_emitterArray"];

_markerX = _this select 0;
_source = _this select 1;

if (_source == "mil") then {
	_val = server getVariable "milActive";
	server setVariable ["milActive", _val + 1, true];
};

_positionX = getMarkerPos _markerX;

_posHQ = getMarkerPos guer_respawn;

_timeLimit = 120;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

while {true} do
	{
	sleep 0.1;
	_poscrash = [_positionX,5000,random 360] call BIS_fnc_relPos;
	if ((!surfaceIsWater _poscrash) and (_poscrash distance _posHQ < 4000)) exitWith {};
	};

_typeVehX = indAirForce call BIS_fnc_selectRandom;

_posCrashMrk = [_poscrash,random 500,random 360] call BIS_fnc_relPos;
_posCrash = _posCrash findEmptyPosition [0,100,_typeVehX];
_mrkFinal = createMarker [format ["DES%1", random 100], _posCrashMrk];
_mrkFinal setMarkerShape "ICON";

_nameXbase = [_markerX] call AS_fnc_localizar;

_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameXbase],_tskTitle,_mrkFinal],_posCrashMrk,"CREATED",5,true,true,"Destroy"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
_vehiclesX = [];
_soldiers = [];
_groups = [];

_effect = createVehicle ["CraterLong", _poscrash, [], 0, "CAN_COLLIDE"];
_heli = createVehicle [_typeVehX, _poscrash, [], 0, "CAN_COLLIDE"];
_heli attachTo [_effect,[0,0,1.5]];
_smokeX = "test_EmptyObjectForSmoke" createVehicle _poscrash; _smokeX attachTo[_heli,[0,1.5,-1]];
_heli setDamage 0.9;
_heli lock 2;
_vehiclesX = _vehiclesX + [_heli,_effect];

_grpcrash = createGroup side_green;
_groups = _groups + [_grpcrash];

_unit = ([_poscrash, 0, infPilot, _grpcrash] call bis_fnc_spawnvehicle) select 0;
_unit setDamage 1;
_unit moveInDriver _heli;
_soldiers = _soldiers + [_unit];

_radiusX = 100;

while {true} do
	{
	_roads = _positionX nearRoads _radiusX;
	if (count _roads > 0) exitWith {};
	_radiusX = _radiusX + 50;
	};

_road = _roads select 0;

_vehicle=[position _road, 0,selectRandom standardMRAP, side_green] call bis_fnc_spawnvehicle;
_veh = _vehicle select 0;
[_veh] spawn genVEHinit;
[_veh,"AAF Escort"] spawn inmuneConvoy;
_vehCrew = _vehicle select 1;
{[_x] spawn genInit} forEach _vehCrew;
_groupVeh = _vehicle select 2;
_soldiers = _soldiers + _vehCrew;
_groups = _groups + [_groupVeh];
_vehiclesX = _vehiclesX + [_veh];

sleep 1;

_typeGroup = [infPatrol, side_green] call AS_fnc_pickGroup;
_groupX = [_positionX, side_green, _typeGroup] call BIS_Fnc_spawnGroup;

{_x assignAsCargo _veh; _x moveInCargo _veh; _soldiers = _soldiers + [_x]; [_x] join _groupVeh; [_x] spawn genInit} forEach units _groupX;
deleteGroup _groupX;
//[_veh] spawn smokeCover;

_Vwp0 = _groupVeh addWaypoint [_poscrash, 0];
_Vwp0 setWaypointType "TR UNLOAD";
_Vwp0 setWaypointBehaviour "SAFE";
_Gwp0 = _groupX addWaypoint [_poscrash, 0];
_Gwp0 setWaypointType "GETOUT";
_Vwp0 synchronizeWaypoint [_Gwp0];

sleep 15;

_vehicleT=[position _road, 0, selectRandom vehTruckBox, side_green] call bis_fnc_spawnvehicle;
_vehT = _vehicleT select 0;
[_vehT] spawn genVEHinit;
[_vehT,"AAF Recover Truck"] spawn inmuneConvoy;
_vehCrewT = _vehicle select 1;
{[_x] spawn genInit} forEach _vehCrewT;
_groupVehT = _vehicleT select 2;
_soldiers = _soldiers + _vehCrewT;
_groups = _groups + [_groupVehT];
_vehiclesX = _vehiclesX + [_vehT];

_Vwp0 = _groupVehT addWaypoint [_poscrash, 0];
_Vwp0 setWaypointType "MOVE";
_Vwp0 setWaypointBehaviour "SAFE";
waitUntil {sleep 1; (not alive _heli) or (_vehT distance _heli < 50) or (dateToNumber date > _dateLimitNum)};

if (_vehT distance _heli < 50) then
	{
	_vehT doMove position _heli;
	sleep 60;
	if (alive _heli) then
		{
		_heli attachTo [_vehT,[0,-3,2]];
		_emitterArray = _smokeX getVariable "effects";
		{deleteVehicle _x} forEach _emitterArray;
		deleteVehicle _smokeX;
		};

	_Vwp0 = _groupVehT addWaypoint [_positionX, 1];
	_Vwp0 setWaypointType "MOVE";
	_Vwp0 setWaypointBehaviour "SAFE";

	_Vwp0 = _groupVeh addWaypoint [_poscrash, 0];
	_Vwp0 setWaypointType "LOAD";
	_Vwp0 setWaypointBehaviour "SAFE";
	_Gwp0 = _groupX addWaypoint [_poscrash, 0];
	_Gwp0 setWaypointType "GETIN";
	_Vwp0 synchronizeWaypoint [_Gwp0];

	_Vwp0 = _groupVeh addWaypoint [_positionX, 2];
	_Vwp0 setWaypointType "MOVE";
	_Vwp0 setWaypointBehaviour "SAFE";

	};

waitUntil {sleep 1; (not alive _heli) or (_vehT distance _positionX < 100) or (dateToNumber date > _dateLimitNum)};

if (not alive _heli) then
	{
	_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameXbase],_tskTitle,_mrkFinal],_posCrashMrk,"SUCCEEDED",5,true,true,"Destroy"] call BIS_fnc_setTask;
	[0,300] remoteExec ["resourcesFIA",2];
	[0,0] remoteExec ["prestige",2];
	//[-3,3,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	[1200] remoteExec ["AS_fnc_increaseAttackTimer",2];
	{if (_x distance _heli < 500) then {[10,_x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
	[5,Slowhand] call playerScoreAdd;
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
	};

if ((dateToNumber date > _dateLimitNum) or (_vehT distance _positionX < 100)) then
	{
	_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameXbase],_tskTitle,_mrkFinal],_posCrashMrk,"FAILED",5,true,true,"Destroy"] call BIS_fnc_setTask;
	//[3,0,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	[-600] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	};

if (!isNull _smokeX) then
	{
	_emitterArray = _smokeX getVariable "effects";
	{deleteVehicle _x} forEach _emitterArray;
	deleteVehicle _smokeX;
	};

if (_source == "mil") then {
	_val = server getVariable "milActive";
	server setVariable ["milActive", _val - 1, true];
};

[1200,_tsk] spawn deleteTaskX;
deleteMarker _mrkFinal;
{
waitUntil {sleep 1;(!([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits))};
deleteVehicle _x} forEach _vehiclesX;
{deleteVehicle _x} forEach _soldiers;
{deleteGroup _x} forEach _groups;

//sleep (600 + random 1200);

//[_tsk,true] call BIS_fnc_deleteTask;
