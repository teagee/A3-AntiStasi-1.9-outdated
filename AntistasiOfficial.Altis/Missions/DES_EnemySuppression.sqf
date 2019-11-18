if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_DESSuppression";
_tskDesc  = "STR_TSK_TD_DESC_DESSuppression";

private ["_poscrash", "_posbase", "_mrkFinal", "_mrkTarget", "_typeVehX", "_churches", "_vehiclesX", "_soldiers", "_groups", "_unit", "_roads", "_road", "_vehicle", "_veh", "_typeGroup", "_tsk", "_smokeX", "_emitterArray", "_poschurch", "_groupX", "_missionchurch", "_posmissionchurch", "_group1", "_MRAP"];


_markerX   = _this select 0;
_positionX   = getMarkerPos _markerX;
_nameDest = [_markerX] call AS_fnc_localizar;

_posHQ = getMarkerPos guer_respawn;

_timeLimit   = 60;
_dateLimit    = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_fMarkers = mrkFIA + campsFIA;
_hMarkers = bases + airportsX + outposts - mrkFIA;

_basesAAF = bases - mrkFIA;
_bases	  = [];
_base	  = "";
{
	_base	 = _x;
	_posbase = getMarkerPos _base;
	if ((_positionX distance _posbase < 7500)and (_positionX distance _posbase > 1500) and (not (spawner getVariable _base))) then {_bases = _bases + [_base]}
		} forEach _basesAAF;
	if (count _bases > 0) then {_base = [_bases, _positionX] call BIS_fnc_nearestPosition;
		} else                                                                               {_base = ""};

	_posbase = getMarkerPos _base;

	_nameOrigin = [_base] call AS_fnc_localizar;

	// finding church and making markers
_range = 1000;
while {true} do {
	sleep 0.1;
	_range = _range + 500;
	_churches = nearestTerrainObjects [_positionX, ["CHURCH", "CHAPEL"], _range];
	if (count _churches > 0) exitwith {};
};

	while {true} do {
		sleep 0.1;
		_missionchurch	  = selectRandom _churches;
		_posmissionchurch = getPos _missionchurch;
		_nfMarker	  = [_fMarkers, _posmissionchurch] call BIS_fnc_nearestPosition;
		_nhMarker	  = [_hMarkers, _posmissionchurch] call BIS_fnc_nearestPosition;
		if ((_posmissionchurch distance _posHQ > 750) && (getMarkerPos _nfMarker distance _posmissionchurch > 350) && ((player distance _posmissionchurch) > 350)) exitWith {};
	};

	_clearspot = _posmissionchurch findEmptyPosition [10, 100, "I_Truck_02_covered_F"];
	_mrkchurch = createMarker [format ["Church%1", random 100], _posmissionchurch];
	_mrkchurch setMarkerSize [100, 100];

	_mrkFinal = createMarker [format ["DES%1", random 100], _missionchurch];
	_mrkFinal setMarkerShape "ICON";

	// setting the mission

	_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nameDest, numberToDate [2035, _dateLimitNum] select 3, numberToDate [2035, _dateLimitNum] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _missionchurch, "CREATED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
	missionsX pushBack _tsk;
	publicVariable "missionsX";

	// adding groups and vehicle

	_vehiclesX = [];
	_soldiers  = [];
	_groups	   = [];

	if ((server getVariable "prestigeCSAT") < 70) then
		{
			_typeGroup = [infSquad, side_green] call AS_fnc_pickGroup;
			_group1	   = [_posmissionchurch, side_green, _typeGroup] call BIS_Fnc_spawnGroup;
			[_group1, _mrkchurch, "SAFE", "SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";

			{ [_x] spawn genInit;
			  _soldiers = _soldiers + [_x]} forEach units _group1;

			_groups = _groups + [_group1];


			private _groupX = createGroup side_green;

			_MRAP = "";
			{if (_x in standardMRAP) exitWith {_MRAP = _x};
			} forEach enemyMotorpool;
			if (_MRAP != "") then {_typeVehX = selectRandom standardMRAP;
				} else                                                        {_typeVehX = selectRandom vehTrucks;
				};

			_veh = _typeVehX createVehicle _clearspot;
			_veh setDir random 360;
			[_veh] spawn genVEHinit;

			_unit = ( [_posmissionchurch, 0, sol_RFL, _groupX] call bis_fnc_spawnvehicle)select 0;
			_unit moveInGunner _veh;
			_unit = ( [_posmissionchurch, 0, sol_RFL, _groupX] call bis_fnc_spawnvehicle)select 0;
			_unit moveInCommander _veh;
			_unit = ( [_posmissionchurch, 0, sol_RFL, _groupX] call bis_fnc_spawnvehicle)select 0;
			_unit moveInDriver _veh;
			_groups = _groups + [_groupX];

			{ [_x] spawn genInit;
			  _soldiers = _soldiers + [_x]} forEach units _groupX;
		} else {
			_typeGroup = [opGroup_Squad, side_red] call AS_fnc_pickGroup;
			_group1	   = [_posmissionchurch, side_red, _typeGroup] call BIS_Fnc_spawnGroup;
			[_group1, _mrkchurch, "SAFE", "SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";


			{ [_x] spawn CSATinit;
			  _x allowFleeing 0} forEach units _group1;

			_groups = _groups + [_group1];


			private _groupX = createGroup side_red;


			_veh = createVehicle [selectRandom opIFV, _clearspot, [], 0, "NONE"];
			_veh lock 2;
			_veh setDir random 360;


			_unit = ( [_posmissionchurch, 0, opI_CREW, _groupX] call bis_fnc_spawnvehicle)select 0;
			_unit moveInGunner _veh;
			_unit = ( [_posmissionchurch, 0, opI_CREW, _groupX] call bis_fnc_spawnvehicle)select 0;
			_unit moveInCommander _veh;
			_unit = ( [_posmissionchurch, 0, opI_CREW, _groupX] call bis_fnc_spawnvehicle)select 0;
			_unit moveInDriver _veh;
				_wp0 = _groupX addWaypoint [_clearspot, 50];
				_wp0 setWaypointType "HOLD";
			_groups = _groups + [_groupX];

			{ [_x] spawn CSATinit;
			  _soldiers = _soldiers + [_x]} forEach units _groupX;
		};


	// mission win/fail and closing mission; calls QRF

	waitUntil  {sleep 5;
		    (dateToNumber date > _dateLimitNum)or ({alive _x} count units _group1 < 4)};

	if (dateToNumber date > _dateLimitNum) then
		{
			_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nameDest, numberToDate [2035, _dateLimitNum] select 3, numberToDate [2035, _dateLimitNum] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _missionchurch, "FAILED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
			[5, 0, _positionX] remoteExec ["AS_fnc_changeCitySupport", 2];
			[-50] remoteExec ["AS_fnc_increaseAttackTimer", 2];
			[-20, Slowhand] call playerScoreAdd;
		} else {
			_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nameDest, numberToDate [2035, _dateLimitNum] select 3, numberToDate [2035, _dateLimitNum] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _missionchurch, "SUCCEEDED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
			[3, 200] remoteExec ["resourcesFIA", 2];
			[0, 5, _positionX] remoteExec ["AS_fnc_changeCitySupport", 2];
			[_mrkchurch] remoteExec ["patrolCA",  call AS_fnc_getNextWorker];

			{if (isPlayer _x) then { [10, _x] call playerScoreAdd}} forEach ( [500, 0, _positionX, "BLUFORSpawn"] call distanceUnits);
			 [10, Slowhand] call playerScoreAdd;
			 [2, 0] remoteExec ["prestige", 2];
				// BE module
			 if (activeBE) then {
					 ["mis"] remoteExec ["fnc_BE_XP", 2];
				 };
			// BE module
			};


			[1200, _tsk] spawn deleteTaskX;
			deleteMarker _mrkFinal;
			[_groups, _soldiers, _vehiclesX] spawn AS_fnc_despawnUnits;