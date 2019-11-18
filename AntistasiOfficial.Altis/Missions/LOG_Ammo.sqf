if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_logAmmo";
_tskDesc = "STR_TSK_TD_DESC_logAmmo";

private ["_pos","_truckX","_truckCreated","_groupX","_groupX1","_mrk"];

_markerX = _this select 0;
_positionX = getMarkerPos _markerX;

_timeLimit = 60;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_nameDest = [_markerX] call AS_fnc_localizar;

_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"CREATED",5,true,true,"rearm"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
_truckCreated = false;

waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (spawner getVariable _markerX)};

if (spawner getVariable _markerX) then
	{
	sleep 10;
	_size = [_markerX] call sizeMarker;
	while {true} do
		{
		_pos = _positionX findEmptyPosition [10,_size, vehAmmo];
		if (count _pos > 0) exitWith {};
		_size = _size + 20
		};
	_truckX = vehAmmo createVehicle _pos;
	_truckCreated = true;
	[_truckX] call boxAAF;

	_mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], _pos];
	_mrk setMarkerShapeLocal "RECTANGLE";
	_mrk setMarkerSizeLocal [20,20];
	_mrk setMarkerTypeLocal "hd_warning";
	_mrk setMarkerColorLocal "ColorRed";
	_mrk setMarkerBrushLocal "DiagGrid";
	if (!debug) then {_mrk setMarkerAlphaLocal 0};

	_typeGroup = [infGarrisonSmall, side_green] call AS_fnc_pickGroup;
	_groupX = [_pos, side_green, _typeGroup] call BIS_Fnc_spawnGroup;
	sleep 1;
	if (random 10 < 33) then
		{
		_dog = _groupX createUnit ["Fin_random_F",_positionX,[],0,"FORM"];
		[_dog] spawn guardDog;
		};

	[_groupX, _mrk, "SAFE","SPAWNED", "NOVEH2"] execVM "scripts\UPSMON.sqf";

	_groupX1 = [_pos, side_green, _typeGroup] call BIS_Fnc_spawnGroup;
	sleep 1;
	[_groupX1, _mrk, "SAFE","SPAWNED", "NOVEH2"] execVM "scripts\UPSMON.sqf";

	{[_x] spawn genInitBASES} forEach units _groupX;
	{[_x] spawn genInitBASES} forEach units _groupX1;

	waitUntil {sleep 1; (not alive _truckX) or (dateToNumber date > _dateLimitNum) or ({_x getVariable ["BLUFORSpawn",false]} count crew _truckX > 0)};

	if (dateToNumber date > _dateLimitNum) then
		{
		_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"FAILED",5,true,true,"rearm"] call BIS_fnc_setTask;
		[-1200] remoteExec ["AS_fnc_increaseAttackTimer",2];
		[-10,Slowhand] call playerScoreAdd;
		};
	if ((not alive _truckX) or ({_x getVariable ["BLUFORSpawn",false]} count crew _truckX > 0)) then
		{
		[position _truckX] spawn patrolCA;
		_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"SUCCEEDED",5,true,true,"rearm"] call BIS_fnc_setTask;
		[0,300] remoteExec ["resourcesFIA",2];
		[1200] remoteExec ["AS_fnc_increaseAttackTimer",2];
		{if (_x distance _truckX < 500) then {[10,_x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
		[5,Slowhand] call playerScoreAdd;
		// BE module
		if (activeBE) then {
			["mis"] remoteExec ["fnc_BE_XP", 2];
		};
		// BE module
		};
	}
else
	{
	_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"FAILED",5,true,true,"rearm"] call BIS_fnc_setTask;
	[-1200] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	};

[1200,_tsk] spawn deleteTaskX;
if (_truckCreated) then
	{
	{deleteVehicle _x} forEach units _groupX;
	deleteGroup _groupX;
	{deleteVehicle _x} forEach units _groupX1;
	deleteGroup _groupX1;
	deleteMarker _mrk;
	waitUntil {sleep 1; not ([300,1,_truckX,"BLUFORSpawn"] call distanceUnits)};
	deleteVehicle _truckX;
	};