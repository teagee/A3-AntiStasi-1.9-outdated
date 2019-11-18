if (!isServer and hasInterface) exitWith{};

_tskTitle = "STR_TSK_TD_DesAntenna";
_tskDesc = "STR_TSK_TD_DESC_DesAntenna";

private ["_antenna","_positionX","_timeLimit","_markerX","_nameDest","_mrkFinal","_tsk"];

_antenna = _this select 0;
_positionX = getPos _antenna;

_timeLimit = 120;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_markerX = [markers,_positionX] call BIS_fnc_nearestPosition;
_nameDest = [_markerX] call AS_fnc_localizar;

_mrkFinal = createMarker [format ["DES%1", random 100], _positionX];
_mrkFinal setMarkerShape "ICON";

_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkFinal],_positionX,"CREATED",5,true,true,"Destroy"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";

waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (not alive _antenna) or (not(_markerX in mrkAAF))};

if (dateToNumber date > _dateLimitNum) then
	{
	_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkFinal],_positionX,"FAILED",5,true,true,"Destroy"] call BIS_fnc_setTask;
	[-10,Slowhand] call playerScoreAdd;
	};
if ((not alive _antenna) or (not(_markerX in mrkAAF))) then
	{
	sleep 15;
	_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkFinal],_positionX,"SUCCEEDED",5,true,true,"Destroy"] call BIS_fnc_setTask;
	[0,0] remoteExec ["prestige",2];
	[600] remoteExec ["AS_fnc_increaseAttackTimer",2];
	{if (_x distance _positionX < 500) then {[10,_x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
	[5,Slowhand] call playerScoreAdd;
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
	};

deleteMarker _mrkFinal;

[1200,_tsk] spawn deleteTaskX;