if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_ASSpecOp";
_tskDesc = "STR_TSK_TD_DESC_ASSpecOp";

_markerX = _this select 0;
_source = _this select 1;

if (_source == "mil") then {
	_val = server getVariable "milActive";
	server setVariable ["milActive", _val + 1, true];
};

_positionX = getMarkerPos _markerX;

_timeLimit = 120;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_nameDest = [_markerX] call AS_fnc_localizar;

_tsk = ["AS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"CREATED",5,true,true,"Kill"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";

_mrkFinal = createMarkerLocal [format ["specops%1", random 100],_positionX];
_mrkFinal setMarkerShapeLocal "RECTANGLE";
_mrkFinal setMarkerSizeLocal [500,500];
_mrkFinal setMarkerTypeLocal "hd_warning";
_mrkFinal setMarkerColorLocal "ColorRed";
_mrkFinal setMarkerBrushLocal "DiagGrid";
if (!debug) then {_mrkFinal setMarkerAlphaLocal 0};

_typeGroup = [opGroup_SpecOps, side_red] call AS_fnc_pickGroup;
_groupX = [_positionX, side_red, _typeGroup] call BIS_Fnc_spawnGroup;
sleep 1;
_uav = createVehicle [opUAVsmall, _positionX, [], 0, "FLY"];
createVehicleCrew _uav;
[_groupX, _mrkFinal, "RANDOM", "SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";
{[_x] spawn CSATinit; _x allowFleeing 0} forEach units _groupX;

_groupUAV = group (crew _uav select 1);
[_groupUAV, _mrkFinal, "SAFE", "SPAWNED","NOVEH", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";

waitUntil  {sleep 5; (dateToNumber date > _dateLimitNum) or ({alive _x} count units _groupX == 0)};

if (dateToNumber date > _dateLimitNum) then
	{
	_tsk = ["AS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"FAILED",5,true,true,"Kill"] call BIS_fnc_setTask;
	[5,0,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	[-600] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	}
else
	{
	_tsk = ["AS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"SUCCEEDED",5,true,true,"Kill"] call BIS_fnc_setTask;
	[0,200] remoteExec ["resourcesFIA",2];
	[0,5,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	[600] remoteExec ["AS_fnc_increaseAttackTimer",2];
	{if (isPlayer _x) then {[10,_x] call playerScoreAdd}} forEach ([500,0,_positionX,"BLUFORSpawn"] call distanceUnits);
	[10,Slowhand] call playerScoreAdd;
	[0,0] remoteExec ["prestige",2];
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
	};

[1200,_tsk] spawn deleteTaskX;

if (_source == "mil") then {
	_val = server getVariable "milActive";
	server setVariable ["milActive", _val - 1, true];
};

{
waitUntil {sleep 1; !([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)};
deleteVehicle _x
} forEach units _groupX;
deleteGroup _groupX;
waitUntil {sleep 1; !([distanceSPWN,1,_uav,"BLUFORSpawn"] call distanceUnits)};
{deleteVehicle _x} forEach units _groupUAV;
deleteVehicle _uav;
deleteGroup _groupUAV;
