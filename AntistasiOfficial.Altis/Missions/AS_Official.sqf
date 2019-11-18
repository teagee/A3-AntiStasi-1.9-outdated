if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_ASOfficer";
_tskDesc = "STR_TSK_TD_DESC_ASOfficer";

_markerX = _this select 0;
_source = _this select 1;

if (_source == "mil") then {
	_val = server getVariable "milActive";
	server setVariable ["milActive", _val + 1, true];
};

_positionX = getMarkerPos _markerX;

_timeLimit = 30;//120
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_nameDest = [_markerX] call AS_fnc_localizar;
_tsk = ["AS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"CREATED",5,true,true,"Kill"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
_grp = createGroup side_red;

_official = ([_positionX, 0, opI_OFF, _grp] call bis_fnc_spawnvehicle) select 0;
_pilot = ([_positionX, 0, opI_PIL, _grp] call bis_fnc_spawnvehicle) select 0;

_grp selectLeader _official;
sleep 1;
[_grp, _markerX, "SAFE", "SPAWNED", "NOVEH", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";

{[_x] spawn CSATinit; _x allowFleeing 0} forEach units _grp;

waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or (not alive _official)};

if (not alive _official) then {
	_tsk = ["AS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"SUCCEEDED",5,true,true,"Kill"] call BIS_fnc_setTask;
	[0,300] remoteExec ["resourcesFIA",2];
	[1800] remoteExec ["AS_fnc_increaseAttackTimer",2];
	{if (isPlayer _x) then {[10,_x] call playerScoreAdd}} forEach ([500,0,_positionX,"BLUFORSpawn"] call distanceUnits);
	[5,Slowhand] call playerScoreAdd;
	[_markerX,30] spawn AS_fnc_addTimeForIdle;
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
} else {
	_tsk = ["AS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"FAILED",5,true,true,"Kill"] call BIS_fnc_setTask;
	[-600] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	[_markerX,-30] spawn AS_fnc_addTimeForIdle;
};

if (_source == "mil") then {
	_val = server getVariable "milActive";
	server setVariable ["milActive", _val - 1, true];
};

{deleteVehicle _x} forEach units _grp;
deleteGroup _grp;

[1200,_tsk] spawn deleteTaskX;