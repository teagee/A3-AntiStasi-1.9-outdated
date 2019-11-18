if !(isServer) exitWith {};

debugperf = false;

private _currentTime = time;
private _hills = colinas - colinasAA;

while {true} do {
	sleep 1;
	if (debugperf) then {hint format ["Total Time : %1 for %2 markers", time - _currentTime, count markers]};
	_currentTime = time;

	waitUntil {!isNil "Slowhand"};

	//Ally that can spawn in enemy
	private _allyUnits = [];

	//Enemy that can spawn in friendly
	private _enemyUnits = [];

	//loop all units
	{
		_unit = _x;
		_veh = vehicle _unit;

		//check if vehicle can spawn in units
		_sideAlly = _veh getVariable "BLUFORSpawn";
		_sideEnemy = _veh getVariable "OPFORSpawn";

		//check unit if vehicle doesnt have variable
		if(isNil "_sideAlly")then{_sideAlly = _x getVariable ["BLUFORSpawn",false]};
		if(isNil "_sideEnemy")then{_sideEnemy = _x getVariable ["OPFORSpawn",false]};

		//pushback units in list
		if (_sideAlly) then {_allyUnits pushBack _x;};
		if (_sideEnemy) then {_enemyUnits pushBack _x;};

	} forEach allUnits;

	{
		private _marker = _x;
		private _markerPos = getMarkerPos _marker;


		if (_marker in mrkAAF) then {
			if !(spawner getVariable _marker) then {
				//check if a units is near the location or place needs to be forced to spawned in
				if (({_x distance _markerPos < distanceSPWN} count _allyUnits > 0) OR (_marker in forcedSpawn)) then {
					spawner setVariable [_marker, true, true]; //Spawn the place
					call {
						if (_marker in _hills) exitWith {[_marker] remoteExec ["createWatchpost", call AS_fnc_getNextWorker]};
						if (_marker in colinasAA) exitWith {[_marker] remoteExec ["createAAsite", call AS_fnc_getNextWorker]};
						if (_marker in citiesX) exitWith {[_marker] remoteExec ["createCIV", call AS_fnc_getNextWorker]; [_marker] remoteExec ["createCity", call AS_fnc_getNextWorker]};
						if (_marker in power) exitWith {[_marker] remoteExec ["createPower", call AS_fnc_getNextWorker]};
						if (_marker in bases) exitWith {[_marker] remoteExec ["createBase", call AS_fnc_getNextWorker]};
						if (_marker in controlsX) exitWith {[_marker, roadblocksEnemy getVariable [_marker, nil]] remoteExec ["createRoadblock2", call AS_fnc_getNextWorker]}; // Server must take the composition of the roadblock from its roadblockEnemy logic object and sends it to the worker
						if (_marker in airportsX) exitWith {[_marker] remoteExec ["createAirbase", call AS_fnc_getNextWorker]};
						if ((_marker in resourcesX) OR (_marker in factories)) exitWith {[_marker] remoteExec ["createResources", call AS_fnc_getNextWorker]};
						if ((_marker in outposts) OR (_marker in seaports)) exitWith {[_marker] remoteExec ["createOutpost", call AS_fnc_getNextWorker]};
						//if ((_marker in artyEmplacements) AND (_marker in forcedSpawn)) exitWith {[_marker] remoteExec ["createArtillery", call AS_fnc_getNextWorker]};
                        if (_marker in markerSupplyCrates) exitWith {[_marker] remoteExec ["createSupplyGroup", call AS_fnc_getNextWorker]};
					};
				};

			} else { //If place was spawned in already
				//units only despawn when you get back 50 meters from the point they spawned in.
				if (({_x distance _markerPos < (distanceSPWN+50)} count _allyUnits == 0) AND !(_marker in forcedSpawn)) then {
					spawner setVariable [_marker, false, true];
				};
			};
		}else{
			if !(spawner getVariable _marker) then {
				if (({_x distance _markerPos < distanceSPWN} count _enemyUnits > 0) OR ({((_x getVariable ["owner",objNull]) == _x) AND (_x distance _markerPos < distanceSPWN)} count _allyUnits > 0) OR (_marker in forcedSpawn)) then {
					spawner setVariable [_marker,true,true];
					if (_marker in citiesX) then {
						if (({((_x getVariable ["owner",objNull]) == _x) AND (_x distance _markerPos < distanceSPWN)} count _allyUnits > 0) OR (_marker in forcedSpawn)) then {[_marker] remoteExec ["createCIV",call AS_fnc_getNextWorker]};
						[_marker] remoteExec ["createCity", call AS_fnc_getNextWorker]
					} else {
						call {
							if ((_marker in resourcesX) OR (_marker in factories)) exitWith {[_marker] remoteExec ["createFIAresources", call AS_fnc_getNextWorker]};
							if ((_marker in power) OR (_marker == "FIA_HQ")) exitWith {[_marker] remoteExec ["createFIApower", call AS_fnc_getNextWorker]};
							if (_marker in airportsX) exitWith {[_marker] remoteExec ["createNATOairplane", call AS_fnc_getNextWorker]};
							if (_marker in bases) exitWith {[_marker] remoteExec ["createNATObases", call AS_fnc_getNextWorker]};
							if (_marker in outpostsFIA) exitWith {[_marker] remoteExec ["createFIAEmplacement", call AS_fnc_getNextWorker]};
							if ((_marker in outposts) OR (_marker in seaports)) exitWith {[_marker] remoteExec ["createFIAOutpost", call AS_fnc_getNextWorker]};
							if (_marker in campsFIA) exitWith {[_marker] remoteExec ["createCampFIA", call AS_fnc_getNextWorker]};
							if (_marker in outpostsNATO) exitWith {[_marker] remoteExec ["createNATOOutpost", call AS_fnc_getNextWorker]};
                            if (_marker in markerSupplyCrates) exitWith {[_marker] remoteExec ["createSupplyGroup", call AS_fnc_getNextWorker]};
						};
					};
				};
			} else {
				if ((({_x distance _markerPos < (distanceSPWN+50)} count _enemyUnits == 0) AND ({((_x getVariable ["owner",objNull]) == _x) AND (_x distance _markerPos < distanceSPWN)} count _allyUnits == 0)) AND !(_marker in forcedSpawn)) then {
					spawner setVariable [_marker, false, true];
				};
			};
		};

	} forEach (markers + markerSupplyCrates);

};
