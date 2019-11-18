if (!isServer and hasInterface) exitWith {};

private ["_prestigio","_markerX","_positionX","_timeLimit","_dateLimit","_dateLimitNum","_nameDest","_tsk","_soldiers","_vehiclesX","_groupX","_typeVehX","_countX","_size"];

_prestigio = server getVariable "prestigeNATO";

_markerX = _this select 0;
_positionX = getMarkerPos _markerX;

[-10,0] remoteExec ["prestige",2];

_timeLimit = _prestigio;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_nameDest = [_markerX] call AS_fnc_localizar;

_tsk = ["NATOArty",[west,civilian],[["STR_TSK_ARTY_DESC",_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_BLUE],["STR_TSK_ARTY_TITLE", A3_Str_BLUE],_markerX],_positionX,"CREATED",5,true,true,"target"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";

_size = [_markerX] call sizeMarker;
_soldiers = [];
_vehiclesX = [];
_groupX = createGroup side_blue;
_typeVehX = selectRandom bluStatMortar;
_groupX setVariable ["esNATO",true,true];
_countX = 1;
_spread = 0;
if (_prestigio < 33) then
	{
	_countX = 4;
	_spread = 15;
	}
else
	{
	if (_prestigio < 66) then {_typeVehX = selectRandom bluArty} else {_countX = 2; _spread = 20; _typeVehX = selectRandom bluMLRS};
	};
for "_i" from 1 to _countX do
	{
	_unit = ([_positionX, 0, bluGunner, _groupX] call bis_fnc_spawnvehicle) select 0;
	[_unit] spawn NATOinitCA;
	sleep 1;
	_pos = [_markerX, "base_4", true] call AS_fnc_findSpawnSpots;
	_veh = createVehicle [_typeVehX, _pos, [], _spread, "NONE"];
	[_veh] spawn NATOvehInit;
	sleep 1;
	_unit moveInGunner _veh;
	_soldiers pushBack _unit;
	_vehiclesX pushBack _veh;
	sleep 2;
	};
_groupX setGroupOwner (owner Slowhand);
_groupX setGroupId ["N.Arty"];
Slowhand hcSetGroup [_groupX];
_groupX setVariable ["isHCgroup", true, true];
//{[_x] spawn unlimitedAmmo} forEach _vehiclesX;

waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or ({alive _x} count _vehiclesX == 0)};

if ({alive _x} count _vehiclesX == 0) then
	{
	[-5,0] remoteExec ["prestige",2];

	_tsk = ["NATOArty",[west,civilian],[["STR_TSK_ARTY_DESC",_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_BLUE],["STR_TSK_ARTY_TITLE", A3_Str_BLUE],_markerX],_positionX,"FAILED",5,true,true,"target"] call BIS_fnc_setTask;
	};

//[_tsk,true] call BIS_fnc_deleteTask;
[0,_tsk] spawn deleteTaskX;

{deleteVehicle _x} forEach _soldiers;
{deleteVehicle _x} forEach _vehiclesX;
deleteGroup _groupX;