if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_DesVehicle";
_tskDesc = "STR_TSK_TD_DESC_DesVehicle";

private ["_markerX","_positionX","_dateLimit","_dateLimitNum","_nameDest","_typeVehX","_textX","_truckCreated","_size","_pos","_veh","_groupX","_unit"];

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

_typeVehX = "";
_textX = "";

//experimental
if (count (enemyMotorpool - vehTank) < count enemyMotorpool) then {_typeVehX = selectRandom vehTank; _textX = "Enemy Tank"} else {_typeVehX = selectRandom vehIFV; _textX = "Enemy IFV"};

// if ("I_MBT_03_cannon_F" in enemyMotorpool) then {_typeVehX = "I_MBT_03_cannon_F"; _textX = "AAF Tank"} else {_typeVehX = opSPAA; _textX = "CSAT Artillery"};

_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4,_textX],_tskTitle,_markerX],_positionX,"CREATED",5,true,true,"Destroy"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
_truckCreated = false;

waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (spawner getVariable _markerX)};

if (spawner getVariable _markerX) then
	{
	_truckCreated = true;
	_size = [_markerX] call sizeMarker;
	_pos = [];
	if (_size > 40) then {_pos = [_positionX, 10, _size, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos} else {_pos = _positionX findEmptyPosition [10,60,_typeVehX]};
	_veh = createVehicle [_typeVehX, _pos, [], 0, "NONE"];
	_veh allowdamage false;
	_veh setDir random 360;
	//if (_typeVehX == "I_MBT_03_cannon_F") then {[_veh] spawn genVEHinit} else {[_veh] spawn CSATVEHinit};
	[_veh] spawn genVEHinit;

	_groupX = createGroup side_green;

	sleep 5;
	_veh allowDamage true;

	for "_i" from 1 to 3 do
		{
		_unit = ([_pos, 0, sol_CREW, _groupX] call bis_fnc_spawnvehicle) select 0;
		[_unit] spawn genInit;
		sleep 2;
		};
	waitUntil {sleep 1;({leader _groupX knowsAbout _x > 1.4} count ([distanceSPWN,0,leader _groupX,"BLUFORSpawn"] call distanceUnits) > 0) or (dateToNumber date > _dateLimitNum) or (not alive _veh) or ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0)};

	if ({leader _groupX knowsAbout _x > 1.4} count ([distanceSPWN,0,leader _groupX,"BLUFORSpawn"] call distanceUnits) > 0) then {_groupX addVehicle _veh;};

	waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (not alive _veh) or ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0)};

	if ((not alive _veh) or ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0)) then
		{
		_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4,_textX],_tskTitle,_markerX],_positionX,"SUCCEEDED",5,true,true,"Destroy"] call BIS_fnc_setTask;
		[0,300] remoteExec ["resourcesFIA",2];
		[2,0] remoteExec ["prestige",2];
		if (_typeVehX == opSPAA) then {[0,0] remoteExec ["prestige",2]; [0,10,_positionX] remoteExec ["AS_fnc_changeCitySupport",2]} else {[0,5,_positionX] remoteExec ["AS_fnc_changeCitySupport",2]};
		[1200] remoteExec ["AS_fnc_increaseAttackTimer",2];
		{if (_x distance _veh < 500) then {[10,_x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
		[5,Slowhand] call playerScoreAdd;
		// BE module
		if (activeBE) then {
			["mis"] remoteExec ["fnc_BE_XP", 2];
		};
		// BE module
		};
	};
if (dateToNumber date > _dateLimitNum) then
	{
	_tsk = ["DES",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4,_textX],_tskTitle,_markerX],_positionX,"FAILED",5,true,true,"Destroy"] call BIS_fnc_setTask;
	[-5,-100] remoteExec ["resourcesFIA",2];
	[5,0,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	if (_typeVehX == opSPAA) then {[0,0] remoteExec ["prestige",2]};
	[-600] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	};

[1200,_tsk] spawn deleteTaskX;

if (_source == "mil") then {
	_val = server getVariable "milActive";
	server setVariable ["milActive", _val - 1, true];
};

waitUntil {sleep 1; not (spawner getVariable _markerX)};

if (_truckCreated) then
	{
	{deleteVehicle _x} forEach units _groupX;
	deleteGroup _groupX;
	if (!([distanceSPWN,1,_veh,"BLUFORSpawn"] call distanceUnits)) then {deleteVehicle _veh};
	};
