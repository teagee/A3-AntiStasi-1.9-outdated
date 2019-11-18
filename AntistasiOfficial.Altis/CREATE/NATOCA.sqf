if (!isServer and hasInterface) exitWith{};

private ["_originX"];

_markerX = _this select 0;

_positionX = getMarkerPos (_markerX);

_airportsX = airportsX - mrkAAF + ["spawnNATO"];

_threatEval = 7; //Stef i forced it to 7 untill i manage to check if vehDef and static guns are operative or not.

_originX = [_airportsX,_positionX] call BIS_fnc_nearestPosition;
_orig = getMarkerPos _originX;

_nameDest = [_markerX] call AS_fnc_localizar;
_nameOrigin = "the NATO Carrier";
if (_originX!= "spawnNATO") then {_nameOrigin = [_originX] call AS_fnc_localizar};
_tsk = ["NATOCA",[side_blue,civilian],[["STR_TSK_DESC_ATTACK",_nameDest,_nameOrigin, A3_Str_BLUE],["STR_TSK_ATTACK", A3_Str_BLUE],_markerX],_positionX,"CREATED",5,true,true,"Attack"] call BIS_fnc_setTask;
missionsX pushBackUnique _tsk; publicVariable "missionsX";
_soldiers = [];
_vehiclesX = [];
_groups = [];
_typeVehX = "";
_countX = 3;

[-20,0] remoteExec ["prestige",2];

_spawnergroup = createGroup east;
_spawner = _spawnergroup createUnit [selectrandom CIV_journalists, getmarkerpos _markerX, [], 15,"None"];
_spawner setVariable ["BLUFORSpawn",true,true];
_spawner disableAI "ALL";
_spawner allowdamage false;
_spawner setcaptive true;
_spawner enableSimulation false;
hideObjectGlobal _spawner;

sleep 15;

for "_i" from 1 to _countX do {
	//Create and initialise aircraft
		_typeVehX = planesNATOTrans call BIS_fnc_selectRandom;
		_vehicle=[_orig, 0, _typeVehX, side_blue] call bis_fnc_spawnvehicle;
		_heli = _vehicle select 0;
		_heliCrew = _vehicle select 1;
		_groupHeli = _vehicle select 2;
		_gunners = _heliCrew - [driver _heli];
		_gunnersgroup = createGroup west;
		_gunners join _gunnersgroup;
		_gunnersgroup setbehaviour "COMBAT";
		{_x setskill 1} foreach units _gunnersgroup;
		{[_x] call NATOinitCA} forEach _heliCrew;
		[_heli] call NATOVEHinit;
		_soldiers = _soldiers + _heliCrew;
		_groups = _groups + [_groupHeli];
		_vehiclesX = _vehiclesX + [_heli];
		_heli lock 3;
		{_x setBehaviour "CARELESS";} forEach units _groupHeli;
		[_heli,"NATO Air Transport"] call inmuneConvoy;
	//Depending on kind of heli
		if (_typeVehX in bluHeliDis) then {		//Apache transport, can land, fastrope or paradrop
			//Add troops and init them
			_typeGroup = [bluSquadWeapons, side_blue] call AS_fnc_pickGroup;
			_groupX = [_orig, side_blue, _typeGroup] call BIS_Fnc_spawnGroup;
			{_x assignAsCargo _heli; _x moveInCargo _heli; _soldiers = _soldiers + [_x]; [_x] spawn NATOinitCA} forEach units _groupX;
			_groups = _groups + [_groupX];
			//Decide for aidrop or fastrope/land
			if ((_markerX in outposts) or (random 10 < _threatEval)) then {
				{removebackpack _x; _x addBackpack "B_Parachute"} forEach units _groupX;
				[_heli,_groupX,_markerX,_threatEval] spawn airdrop;
				diag_log format ["NATOCA HeliDIS airdropping: %1, %2, %3 ",_heli,_groupX,_markerX];
			} else {
				if ((_markerX in bases) or (_markerX in outposts)) then {
					[_heli,_groupX,_positionX,_orig,_groupHeli] spawn fastropeNATO;
				};
				if ((_markerX in resourcesX) or (_markerX in power) or (_markerX in factories)) then {
					{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _groupHeli;
					_landpos = [];
					_landpos = [_positionX, 0, 500, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
					_landPos set [2, 0];
					_pad = createVehicle ["Land_HelipadEmpty_F", _landpos, [], 0, "NONE"];
					_vehiclesX = _vehiclesX + [_pad];
					_wp0 = _groupHeli addWaypoint [_landpos, 0];
					_wp0 setWaypointType "TR UNLOAD";
					_wp0 setWaypointSpeed "FULL";
					_wp0 setWaypointStatements ["true", "(vehicle this) land 'GET OUT';"];
					[_groupHeli,0] setWaypointBehaviour "CARELESS";
					_wp3 = _groupX addWaypoint [_landpos, 0];
					_wp3 setWaypointType "GETOUT";
					_wp0 synchronizeWaypoint [_wp3];
					_wp4 = _groupX addWaypoint [_positionX, 1];
					_wp4 setWaypointType "SAD";
					_wp2 = _groupHeli addWaypoint [_orig, 1];
					_wp2 setWaypointType "MOVE";
					_wp2 setWaypointSpeed "FULL";
					_wp2 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew this; deleteVehicle this"];
					[_groupHeli,1] setWaypointBehaviour "AWARE";
					[_heli,true] spawn entriesLand;
				};
			};
		};
		if (_typeVehX in bluHeliTS) then {  		//Littlebird will land only
			{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _groupHeli;
			//Add troops and init them
			_typeGroup = [bluTeam, side_blue] call AS_fnc_pickGroup;
			_groupX = [_orig, side_blue, _typeGroup] call BIS_Fnc_spawnGroup;
			{_x assignAsCargo _heli; _x moveInCargo _heli; _soldiers = _soldiers + [_x]; [_x] call NATOinitCA} forEach units _groupX;
			_groups = _groups + [_groupX];
			_landpos = [];
			_landpos = [_positionX, 0, 500, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
			_landPos set [2, 0];
			_pad = createVehicle ["Land_HelipadEmpty_F", _landpos, [], 0, "NONE"];
			_vehiclesX = _vehiclesX + [_pad];
			//WP assignement
			_wp0 = _groupHeli addWaypoint [_landpos, 0];
			_wp0 setWaypointType "TR UNLOAD";
			_wp0 setWaypointSpeed "FULL";
			_wp0 setWaypointStatements ["true", "(vehicle this) land 'GET OUT';"];
			[_groupHeli,0] setWaypointBehaviour "CARELESS";
			_wp3 = _groupX addWaypoint [_landpos, 0];
			_wp3 setWaypointType "GETOUT";
			_wp0 synchronizeWaypoint [_wp3];
			_wp4 = _groupX addWaypoint [_positionX, 1];
			_wp4 setWaypointType "SAD";
			_wp2 = _groupHeli addWaypoint [_orig, 1];
			_wp2 setWaypointSpeed "FULL";
			_wp2 setWaypointType "MOVE";
			_wp2 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew this; deleteVehicle this"];
			[_groupHeli,1] setWaypointBehaviour "AWARE";
			[_heli,true] spawn entriesLand;
			diag_log format ["NATOCA HeliTS airdropping: %1, %2, %3 ",_heli,_groupX,_markerX];
		};
		if (_typeVehX in bluHeliRope) then {			//Chinhook	can aidrop or land
			{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _groupHeli;
			//Add troops and init them
			_typeGroup = [bluSquad, side_blue] call AS_fnc_pickGroup;
			_groupX = [_orig, side_blue, _typeGroup] call BIS_Fnc_spawnGroup;
			{_x assignAsCargo _heli; _x moveInCargo _heli; _soldiers = _soldiers + [_x]; [_x] call NATOinitCA} forEach units _groupX;
			_groups = _groups + [_groupX];

			//Decide airdrop or land
			if (!(_markerX in outposts) or (_markerX in bases) or (random 10 < _threatEval)) then {
				{removebackpack _x; _x addBackpack "B_Parachute"} forEach units _groupX;
				[_heli,_groupX,_markerX,_threatEval] spawn airdrop;
				diag_log format ["NATOCA HeliRope: %1, %2, %3,",_heli,_groupX,_markerX];
			} else {
				_landpos = [];
				_landpos = [_positionX, 0, 300, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
				_landPos set [2, 0];
				_pad = createVehicle ["Land_HelipadEmpty_F", _landpos, [], 0, "NONE"];
				_vehiclesX = _vehiclesX + [_pad];
				_wp0 = _groupHeli addWaypoint [_landpos, 0];
				_wp0 setWaypointType "TR UNLOAD";
				_wp0 setWaypointSpeed "FULL";
				_wp0 setWaypointStatements ["true", "(vehicle this) land 'GET OUT';"];
				[_groupHeli,0] setWaypointBehaviour "CARELESS";
				_wp3 = _groupX addWaypoint [_landpos, 0];
				_wp3 setWaypointType "GETOUT";
				_wp0 synchronizeWaypoint [_wp3];
				_wp4 = _groupX addWaypoint [_positionX, 1];
				_wp4 setWaypointType "SAD";
				_wp2 = _groupHeli addWaypoint [_orig, 1];
				_wp2 setWaypointType "MOVE";
				_wp2 setWaypointSpeed "FULL";
				_wp2 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew this; deleteVehicle this"];
				[_groupHeli,1] setWaypointBehaviour "AWARE";
				[_heli,true] spawn entriesLand;
				};
		};
		sleep 25;
	};


_solMax = count _soldiers;
_solMax = round (_solMax / 4);

sleep 20;
//Taking out enemy mortar to balance the fight
	if ((_markerX in bases) and ((player distance _positionX)>300)) then {
		[_markerX] spawn artilleryNATO;
	};
	if ((_markerX in airportsX) and ((player distance _positionX)>300)) then {
		[_markerX] spawn artilleryNATO;
	};

waitUntil {sleep 1; (_markerX in mrkFIA) or ({alive _x} count _soldiers < _solMax)};

if ({alive _x} count _soldiers < _solMax) then {
	_tsk = ["NATOCA",[side_blue,civilian],[["STR_TSK_DESC_ATTACK",_nameDest,_nameOrigin, A3_Str_BLUE],["STR_TSK_ATTACK", A3_Str_BLUE],_markerX],_positionX,"FAILED",5,true,true,"Attack"] call BIS_fnc_setTask;
	[-10,0] remoteExec ["prestige",2];
};


//[_tsk,true] call BIS_fnc_deleteTask;
[0,_tsk] spawn deleteTaskX;

{
	_soldierX = _x;
	waitUntil {sleep 1; {_x distance _soldierX < distanceSPWN} count (allPlayers - (entities "HeadlessClient_F")) == 0};
	deleteVehicle _soldierX;
} forEach _soldiers;

{deleteGroup _x} forEach _groups;

{
	_vehiculo = _x;
	waitUntil {sleep 1; {_x distance _vehiculo < distanceSPWN/2} count (allPlayers - (entities "HeadlessClient_F")) == 0};
	deleteVehicle _x
} forEach _vehiclesX;

deletevehicle _spawner;
deleteGroup _spawnergroup;