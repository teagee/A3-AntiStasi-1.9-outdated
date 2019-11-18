if (!isServer and hasInterface) exitWith {};
private ["_posOrigin","_typeGroup","_nameOrigin","_markTsk","_wp1","_soldiers","_landpos","_pad","_vehiclesX","_wp0","_wp3","_wp4","_wp2","_groupX","_groups","_typeVehX","_vehicle","_heli","_heliCrew","_groupHeli","_pilots","_rnd","_resourcesAAF","_nVeh","_radiusX","_roads","_Vwp1","_tanksX","_road","_veh","_vehCrew","_groupVeh","_Vwp0","_size","_Hwp0","_groupX1","_uav","_groupUAV","_uwp0","_tsk","_vehiculo","_soldierX","_pilot","_mrkDestination","_posDestination","_prestigeCSAT","_base","_airportX","_nameDest","_timeX","_solMax","_pos","_timeOut"];
_mrkDestination = _this select 0;

forcedSpawn = forcedSpawn + [_mrkDestination]; publicVariable "forcedSpawn";

_posDestination = getMarkerPos _mrkDestination;

_groups = [];
_soldiers = [];
_pilots = [];
_vehiclesX = [];
_civiles = [];

_nameDest = [_mrkDestination] call AS_fnc_localizar;
_tsk = ["AttackAAF",[side_blue,civilian],[["CSAT is making a punishment expedition to %1. They will kill everybody there. Defend the city at all costs",_nameDest],"CSAT Punishment",_mrkDestination],getMarkerPos _mrkDestination,"CREATED",10,true,true,"Defend"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
//Ataque de artillería
[_mrkDestination] spawn artilleryX;

_timeX = time + 3600;

_posOrigin = getMarkerPos "spawnCSAT";

for "_i" from 1 to 3 do {
	_typeVehX = opAir call BIS_fnc_selectRandom;
	if(_i == 1) then {_typeVehX = opAir select 0};
	if(_i == 3) then {_typeVehX = opAir select 1};
	_timeOut = 0;
	_pos = _posOrigin findEmptyPosition [0,100,_typeVehX];
	while {_timeOut < 60} do {
		if (count _pos > 0) exitWith {};
		_timeOut = _timeOut + 1;
		_pos = _posOrigin findEmptyPosition [0,100,_typeVehX];
		sleep 1;
	};
	if (count _pos == 0) then {_pos = _posOrigin};
	_vehicle=[_pos, 0, _typeVehX, side_red] call bis_fnc_spawnvehicle;
	_heli = _vehicle select 0;
	_heli setVariable ["OPFORSpawn",true];
	_heliCrew = _vehicle select 1;
	_groupHeli = _vehicle select 2;
	_pilots = _pilots + _heliCrew;
	_groups = _groups + [_groupHeli];
	_vehiclesX = _vehiclesX + [_heli];
	//_heli lock 3;
	if (_typeVehX != opHeliFR) then
		{
		{[_x] spawn CSATinit} forEach _heliCrew;
		_wp1 = _groupHeli addWaypoint [_posDestination, 0];
		_wp1 setWaypointType "SAD";
		_wp101 = _groupHeli addWaypoint [_posDestination, 50];
		_wp101 setWaypointType "LOITER";
		_wp101 setWaypointLoiterType "CIRCLE";
		_wp101 setWaypointLoiterRadius 200;
		_wp101 setWaypointSpeed "LIMITED";
		[_heli,"CSAT Air Attack"] spawn inmuneConvoy;
	} else {
		{_x setBehaviour "CARELESS";} forEach units _groupHeli;
		_typeGroup = [opGroup_Squad, side_red] call AS_fnc_pickGroup;
		_groupX = [_posOrigin, side_red, _typeGroup] call BIS_Fnc_spawnGroup;
		{_x assignAsCargo _heli; _x moveInCargo _heli; _soldiers = _soldiers + [_x]; [_x] spawn CSATinit} forEach units _groupX;
		_groups = _groups + [_groupX];
		[_heli,"CSAT Air Transport"] spawn inmuneConvoy;

		if (random 100 < 50) then
			{
			{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _groupHeli;
			_landpos = [];
			_landpos = [_posDestination, 300, 500, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
			_landPos set [2, 0];
			_pad = createVehicle ["Land_HelipadEmpty_F", _landpos, [], 0, "NONE"];
			_vehiclesX = _vehiclesX + [_pad];
			_wp0 = _groupHeli addWaypoint [_landpos, 0];
			_wp0 setWaypointType "TR UNLOAD";
			_wp0 setWaypointStatements ["true", "(vehicle this) land 'GET OUT'"];
			[_groupHeli,0] setWaypointBehaviour "CARELESS";
			_wp3 = _groupX addWaypoint [_landpos, 0];
			_wp3 setWaypointType "GETOUT";
			_wp0 synchronizeWaypoint [_wp3];
			_wp4 = _groupX addWaypoint [_posDestination, 1];
			_wp4 setwaypointtype "SAD";
			private _i = 1;
   			 while {_i < 10} do
		    {
		        private _wp = _x addWaypoint [_posDestination, 50, _i, "MOVE wp"];
		        _wp setWaypointCompletionRadius 0.2*50;
		        _wp setWaypointType "SAD";
		        _i = _i + 1;
		    };
			[_groupX,0] setWaypointBehaviour "COMBAT";
			_wp2 = _groupHeli addWaypoint [_posOrigin, 1];
			_wp2 setWaypointType "MOVE";
			_wp2 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew this; deleteVehicle this"];
			[_groupHeli,1] setWaypointBehaviour "AWARE";
		} else {
		[_heli,_groupX,_posDestination,_posOrigin,_groupHeli] spawn fastropeCSAT;};
	};
	sleep 3;
};

_dataX = server getVariable _mrkDestination;
_numCiv = _dataX select 0;
_numCiv = 16; //making the number standard for now

_size = [_mrkDestination] call sizeMarker;
_groupCivil1 = createGroup side_blue;
_groups pushBack _groupCivil1;

for "_i" from 0 to _numCiv do {
	while {true} do {
		_pos = _posDestination getPos [random _size,random 360];
		if (!surfaceIsWater _pos) exitWith {};
	};
	_civ = _groupCivil1 createUnit [CIV_units call BIS_fnc_selectRandom,_pos, [],20,"NONE"];
	_rnd = random 100;
	if (_rnd < 90) then {
		if (_rnd < 25) then {[_civ, "hgun_PDW2000_F", 5, 0] call BIS_fnc_addWeapon;} else {[_civ, "hgun_Pistol_heavy_02_F", 5, 0] call BIS_fnc_addWeapon;};
	};
	_civiles pushBack _civ;
	[_civ] call civInit;
	sleep 0.5;
};
_groupCivil = createGroup side_blue;
{[_x] join _groupCivil} foreach (units _groupCivil1);
_groups pushBack _groupCivil;

[_groupCivil, _mrkDestination, "AWARE","SPAWNED","NOVEH2"] execVM "scripts\UPSMON.sqf";

_civilMax = {alive _x} count _civiles;
_solMax = count _soldiers;

//Loop to make civis get killed at some point, could be done better by beeing sure CSAF find where they hide
	[_groupCivil,_soldiers,_posDestination]  spawn {sleep 900; //15 min, can be tweaked on need
		diag_log format ["CSAT: civilians: %1 enemies: %2",_this select 0,_this select 1];
		{(_this select 0) reveal [_x,4]} foreach (_this select 1);
		_wp7 = (_this select 0) addWaypoint [_this select 2, 1];
		_wp7 setWaypointType "SAD";
		[(_this select 0),1] setWaypointBehaviour "CARELESS";
		_pos = position (leader (_this select 0));
		diag_log format ["CSAT: pos: %1",_pos];
		_smokeX = "SmokeShellYellow" createVehicle _pos;
		sleep 30;
		_pos = position (leader (_this select 0));
		_smokeX = "SmokeShellYellow" createVehicle _pos;
		sleep 60;
		_pos = position (leader (_this select 0));
		_smokeX = "SmokeShellYellow" createVehicle _pos;
	};

for "_i" from 0 to round random 2 do {
	[_mrkDestination, selectRandom opCASFW] spawn airstrike;
	sleep 30;
};

{if ((surfaceIsWater position _x) and (vehicle _x == _x)) then {_x setDamage 1}} forEach _soldiers;

waitUntil {sleep 5;
	(({not (captive _x)} count _soldiers) < ({captive _x} count _soldiers)) or
	({alive _x} count _soldiers < round (_solMax / 3)) or
	(
	 	({(_x distance _posDestination < _size*2) and (not(vehicle _x isKindOf "Air")) and (alive _x) and (!captive _x)} count _soldiers)
	 	> 4*
	 	({(alive _x) and (_x distance _posDestination < _size*2)} count _civiles)
	) or
	(time > _timeX)};

		if ((({!(captive _x)} count _soldiers) < ({captive _x} count _soldiers)) or ({alive _x} count _soldiers < round (_solMax / 3)) or (time > _timeX)) then {
			{_x doMove [0,0,0]} forEach _soldiers;
			_tsk = ["AttackAAF",[side_blue,civilian],[["CSAT is making a punishment expedition to %1. They will kill everybody there. Defend the city at all costs",_nameDest],"CSAT Punishment",_mrkDestination],getMarkerPos _mrkDestination,"SUCCEEDED",10,true,true,"Defend"] call BIS_fnc_setTask;
			[-5,20,_posDestination] remoteExec ["AS_fnc_changeCitySupport",2];
			[10,0] remoteExec ["prestige",2];
			{[-5,0,_x] remoteExec ["AS_fnc_changeCitySupport",2]} forEach citiesX;
			{if (isPlayer _x) then {[10,_x] call playerScoreAdd}} forEach ([500,0,_posDestination,"BLUFORSpawn"] call distanceUnits);
			[10,Slowhand] call playerScoreAdd;
		} else {
			_tsk = ["AttackAAF",[side_blue,civilian],[["CSAT is making a punishment expedition to %1. They will kill everybody there. Defend the city at all costs",_nameDest],"CSAT Punishment",_mrkDestination],getMarkerPos _mrkDestination,"FAILED",10,true,true,"Defend"] call BIS_fnc_setTask;
			[-5,-20,_posDestination] remoteExec ["AS_fnc_changeCitySupport",2];
			{[0,-5,_x] remoteExec ["AS_fnc_changeCitySupport",2]} forEach citiesX;
			destroyedCities = destroyedCities + [_mrkDestination];
			if (count destroyedCities > 7) then
				{
				 ["destroyedCities",false,true] remoteExec ["BIS_fnc_endMission",0];
				};
			publicVariable "destroyedCities";
			for "_i" from 1 to 60 do
				{
				_mineX = createMine ["APERSMine",_posDestination,[],_size];
				};
			};

	forcedSpawn = forcedSpawn - [_mrkDestination]; publicVariable "forcedSpawn";
	sleep 15;

	[0,_tsk] spawn deleteTaskX;
	[2400] remoteExec ["AS_fnc_increaseAttackTimer",2];
	{
	waitUntil {sleep 1; !([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)};
	deleteVehicle _x;
	} forEach _soldiers;
	{
	waitUntil {sleep 1; !([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)};
	deleteVehicle _x;
	} forEach _pilots;
	{
	if (!([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)) then {deleteVehicle _x};
	} forEach _vehiclesX;
	{deleteGroup _x} forEach _groups;

	waitUntil {sleep 1; not (spawner getVariable _mrkDestination)};

	{deleteVehicle _x} forEach _civiles;
	deleteGroup _groupCivil;
