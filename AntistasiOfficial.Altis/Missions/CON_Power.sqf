if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_CONPower";
_tskDesc = "STR_TSK_TD_DESC_CONPower";

private ["_markerX"];

_markerX = _this select 0;
_source = _this select 1;

if (_source == "civ") then {
	_val = server getVariable "civActive";
	server setVariable ["civActive", _val + 1, true];
};

_positionX = getMarkerPos _markerX;
_timeLimit = 90;//120
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_nameDest = [_markerX] call AS_fnc_localizar;

_tsk = ["CON",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"CREATED",5,true,true,"Target"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";

waitUntil {sleep 1; ((dateToNumber date > _dateLimitNum) or (not(_markerX in mrkAAF)))};

if (dateToNumber date > _dateLimitNum) then {
	_tsk = ["CON",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"FAILED",5,true,true,"Target"] call BIS_fnc_setTask;
	[5,0,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	[-600] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
};

if (not(_markerX in mrkAAF)) then {
	sleep 10;
	_tsk = ["CON",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"SUCCEEDED",5,true,true,"Target"] call BIS_fnc_setTask;
	[0,200] remoteExec ["resourcesFIA",2];
	[-5,0,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	[600] remoteExec ["AS_fnc_increaseAttackTimer",2];
	{if (isPlayer _x) then {[10,_x] call playerScoreAdd}} forEach ([500,0,_positionX,"BLUFORSpawn"] call distanceUnits);
	[10,Slowhand] call playerScoreAdd;
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
};

if (_source == "civ") then {
	_val = server getVariable "civActive";
	server setVariable ["civActive", _val - 1, true];
};

[1200,_tsk] spawn deleteTaskX;