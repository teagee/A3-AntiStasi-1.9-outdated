if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_DESfuel";
_tskDesc  = "STR_TSK_TD_DESC_DESfuel";

private ["_posbase", "_mrkFinal", "_mrkTarget", "_typeVehX", "_range", "_vehiclesX", "_soldiers", "_groups", "_returntime", "_roads", "_road", "_vehicle", "_veh", "_TypeOfGroup", "_tsk", "_smokeX", "_emitterArray", "_poschurch", "_groupX", "_fuelstop", "_posfuelstop", "_fuelstops"];


_InitialMarker = _this select 0;
_InitialPos    = getMarkerPos _InitialMarker;

_posHQ = getMarkerPos guer_respawn;

_MissionDuration = 60;
_MissionEndTime	 = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _MissionDuration];
_TimeLeft	 = dateToNumber _MissionEndTime;

_fMarkers = mrkFIA + campsFIA;
_hMarkers = bases + airportsX + outposts - mrkFIA;

_basesAAF = bases - mrkFIA;
_bases	  = [];
_base	  = "";
{
	_base	 = _x;
	_posbase = getMarkerPos _base;
	if ((_InitialPos distance _posbase < 7500)and (_InitialPos distance _posbase > 1500) and (not (spawner getVariable _base))) then {_bases = _bases + [_base]}
		} forEach _basesAAF;
	if (count _bases > 0) then {_base = [_bases, _InitialPos] call BIS_fnc_nearestPosition;
		} else                                                                                 {_base = ""};

	_posbase = getMarkerPos _base;

	_nameOrigin = [_base] call AS_fnc_localizar;

	// finding location and making markers

	_range = 2000;
	while {true} do {
		sleep 0.1;
		while {true} do {
			sleep 0.1;
			_range	   = _range + 500;
			_fuelstops = nearestTerrainObjects [_InitialPos, ["FUELSTATION"], _range];
			if (count _fuelstops > 0) exitwith {};
		};
		_fuelstop    = selectRandom _fuelstops;
		_posfuelstop = getPos _fuelstop;
		_nfMarker    = [_fMarkers, _posfuelstop] call BIS_fnc_nearestPosition;
		_nhMarker    = [_hMarkers, _posfuelstop] call BIS_fnc_nearestPosition;
		if ((_posfuelstop distance _posHQ > 400) && (getMarkerPos _nfMarker distance _posfuelstop > 200)) exitWith {};
	};

	_spawnpositionData = [_posbase, _posfuelstop] call AS_fnc_findSpawnSpots;
	_spawnPosition = _spawnpositionData select 0;
	_direction = _spawnpositionData select 1;

	_mrkfuelstop  = createMarker [format ["Fuel%1", random 100], _posfuelstop];
	_mrkfuelstop setMarkerSize [150, 150];

	_mrkFinal = createMarker [format ["DES%1", random 100], _posfuelstop];

	_mrkFinal setMarkerShape "ICON";

	// setting the mission

	_nearestbase = [_base] call AS_fnc_localizar;
	_tsk	     = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "CREATED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
	missionsX pushBack _tsk;
	publicVariable "missionsX";

	// adding groups and vehicle

	_vehiclesX = [];
	_soldiers  = [];
	_groups	   = [];


	[_mrkfuelstop] remoteExec ["patrolCA",  call AS_fnc_getNextWorker];
	sleep 10;


	private _groupX = createGroup side_green;

	_fueltruck = selectRandom vehFuel;
	_veh	   = _fueltruck createVehicle _spawnPosition;
	sleep 1;
	if (not alive _veh) then {_veh = "I_Truck_02_fuel_F" createVehicle _spawnPosition}; // Fallback default fuel truck in case it's not in a template.
	_veh setDir _direction;
	// _vehiclesX = _vehiclesX + [_veh];
	[_veh] spawn genVEHinit;

	_unit = ( [_posbase, 0, sol_RFL, _groupX] call bis_fnc_spawnvehicle)select 0;
	_unit moveInDriver _veh;
	_unit disableAI "AUTOTARGET";
	_unit disableAI "TARGET";
	_unit disableAI "AUTOCOMBAT";
	_unit setBehaviour "CARELESS";
	_unit allowFleeing 0;
	_groups = _groups + [_groupX];

	{ [_x] spawn genInit;
	  _soldiers = _soldiers + [_x]} forEach units _groupX;


	_wp0 = _groupX addWaypoint [_posfuelstop, 0];
	_wp0 setWaypointType "MOVE";
	_wp0 setWaypointBehaviour "SAFE";
	_wp0 setWaypointSpeed "NORMAL";
	_wp0 setWaypointFormation "COLUMN";


	waitUntil {sleep 3;
		(not alive _veh) or ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0) or (dateToNumber date > _TimeLeft) or (_veh distance _posfuelstop < 40)
	};

		if (dateToNumber date > _TimeLeft) then {
			_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "FAILED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
		};

		if ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0) then {
			_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "FAILED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
			[-5, 5, _InitialMarker] remoteExec ["AS_fnc_changeCitySupport", 2];
		};

		if (not alive _veh) then {
			_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "SUCCEEDED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
		};

		if (_veh distance _posfuelstop < 40) then {
			_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _veh, "CREATED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
			hint "The fuel truck has arrived at the station.";
			_returntime = (time + (1800 + (random 600)));
			waitUntil {sleep 5;
				(not alive _veh) or ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0) or (dateToNumber date > _TimeLeft) or (time > _returntime)
			};
				if (not alive _veh) then {
					_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "SUCCEEDED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
					[-10, 10, _InitialMarker] remoteExec ["AS_fnc_changeCitySupport", 2];
					[5, 0] remoteExec ["prestige", 2];
					{if (_x distance _veh < 1500) then { [10, _x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
					[5, Slowhand] call playerScoreAdd;
					// BE module
					if (activeBE) then { ["mis"] remoteExec ["fnc_BE_XP", 2]};
				};

				if ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0) then {
					_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "SUCCEEDED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
					[-5, 5, _InitialMarker] remoteExec ["AS_fnc_changeCitySupport", 2];
				};

				if (dateToNumber date > _TimeLeft) exitWith {_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "FAILED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
				};

				if (time >= _returntime) then {
					_wp1 = _groupX addWaypoint [_posbase, 0];
					_wp1 setWaypointType "MOVE";
					_wp1 setWaypointBehaviour "SAFE";
					_wp1 setWaypointSpeed "NORMAL";
					_wp1 setWaypointFormation "COLUMN";
					hint "The fuel truck is RTB";
				};

				waitUntil {sleep 5;
					((_veh distance _posbase) < 75) or (not alive _veh) or ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0) or (dateToNumber date > _TimeLeft)
				};
					if (dateToNumber date > _TimeLeft) then {_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "FAILED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
					};

					if (not alive _veh) then {
						_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "SUCCEEDED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
						[-10, 10, _InitialMarker] remoteExec ["AS_fnc_changeCitySupport", 2];
						{if (_x distance _veh < 1500) then { [10, _x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
						[5, Slowhand] call playerScoreAdd;
						// BE module
						 if (activeBE) then { ["mis"] remoteExec ["fnc_BE_XP", 2]};
					};

					if ({_x getVariable ["BLUFORSpawn",false]} count crew _veh > 0) then {
						_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "SUCCEEDED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
						[-5, 5, _InitialMarker] remoteExec ["AS_fnc_changeCitySupport", 2];
					};

					if (_veh distance _posbase < 75) then{
						_tsk = ["DES", [side_blue, civilian], [[_tskDesc, _nearestbase, numberToDate [2035, _TimeLeft] select 3, numberToDate [2035, _TimeLeft] select 4, A3_Str_INDEP], _tskTitle, _mrkFinal], _fuelstop, "FAILED", 5, true, true, "Destroy"] call BIS_fnc_setTask;
						deleteVehicle _veh;
						deleteGroup _groupX;
					};
		};

					[800, _tsk] spawn deleteTaskX;
					deleteMarker _mrkFinal;
					deleteMarker _mrkfuelstop;
