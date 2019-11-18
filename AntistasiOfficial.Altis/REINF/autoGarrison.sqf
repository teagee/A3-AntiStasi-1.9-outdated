if (!isServer and hasInterface) exitWith {};

if(true)exitWith{};//disabled because its to slow

private ["_markerX","_destinationX","_originX","_groups","_soldiers","_vehiclesX","_size","_groupX","_truckX","_radiusX","_roads","_road","_pos"];

_markerX = _this select 0;
if (not(_markerX in smallCAmrk)) exitWith {};
if (debug) then {Slowhand globalChat format ["AutoGarrison en marcha, destinationX %1",_markerX]};
_destinationX = getMarkerPos _markerX;
_originX = getMarkerPos guer_respawn;

if ((worldName == "Tanoa") AND !([_originX, _destinationX] call AS_fnc_IslandCheck)) exitWith {};

_groups = [];
_soldiers = [];
_vehiclesX = [];

_size = [_markerX] call sizeMarker;

_divisor = 50;

if (_markerX in airportsX) then {_divisor = 100};
if (_markerX in bases) then {_divisor = 30};

_size = round (_size / _divisor);

if (_size == 0) then {_size = 1};

while {(_size > 0)} do
	{
	if (diag_fps > minimoFPS) then
		{
		_radiusX = 10;
		while {true} do
			{
			_roads = _originX nearRoads _radiusX;
			if (count _roads < 1) then {_radiusX = _radiusX + 10};
			if (count _roads > 0) exitWith {};
			};
		_road = _roads select 0;
		_typeVehX = [guer_veh_truck,guer_veh_offroad,guer_veh_quad,guer_veh_technical] call BIS_fnc_selectRandom;
		_pos = position _road findEmptyPosition [1,30,_typeVehX];
		_vehicle=[_pos, random 360,_typeVehX, side_blue] call bis_fnc_spawnvehicle;
		_veh = _vehicle select 0;
		_vehCrew = _vehicle select 1;
		{[_x] spawn AS_fnc_initialiseFIAUnit} forEach _vehCrew;
		[_veh] spawn VEHinit;
		[_veh,"Reinf"] spawn inmuneConvoy;
		_groupVeh = _vehicle select 2;
		_groupVeh setVariable ["esNATO",true,true];
		_soldiers = _soldiers + _vehCrew;
		_groups pushBack _groupVeh;
		_vehiclesX = _vehiclesX + [_veh];
		if (_typeVehX != guer_veh_technical) then
			{
			if (_typeVehX == guer_veh_quad) then
				{
				_soldierX = _groupVeh createUnit [guer_sol_SN, _pos, [], 0, "NONE"];
				[_soldierX] spawn AS_fnc_initialiseFIAUnit;
				_soldiers pushBack _soldierX;
				_soldierX moveInCargo _veh;
				}
			else
				{
				_typeGroup = guer_grp_squad;
				if (_typeVehX == guer_veh_offroad) then {_typeGroup = [guer_grp_team,guer_grp_AT] call BIS_fnc_selectRandom};
				_groupX = [_originX, side_blue, ([_typeGroup, "guer"] call AS_fnc_pickGroup)] call BIS_Fnc_spawnGroup;
				{[_x] call AS_fnc_initialiseFIAUnit; [_x] join _groupVeh; _x moveInCargo _veh; _soldiers pushBack _x} forEach units _groupX;
				deleteGroup _groupX;
				};
			//[_markerX,_groupVeh] spawn attackDrill;
			_Vwp0 = _groupVeh addWaypoint [_destinationX, 0];
			_Vwp0 setWaypointBehaviour "SAFE";
			_Vwp0 setWaypointType "GETOUT";
			_Vwp1 = _groupVeh addWaypoint [_destinationX, 1];
			_Vwp1 setWaypointType "SAD";
			_Vwp1 setWaypointBehaviour "AWARE";
			}
		else
			{
			_Vwp1 = _groupVeh addWaypoint [_destinationX, 0];
			_Vwp1 setWaypointType "SAD";
			_Vwp1 setWaypointBehaviour "AWARE";
			};
		};
	sleep 30;
	_size = _size - 1;
	hint "Supreme Commander Petros sent in the cavalry.";
	};

{
	_x setVariable ["generated",true,true];
} forEach _soldiers;

waitUntil {sleep 1;((not(_markerX in smallCAmrk)) or (_markerX in mrkAAF))};

{_vehiculo = _x;
waitUntil {sleep 1; {_x distance _vehiculo < distanceSPWN} count (allPlayers - (entities "HeadlessClient_F")) == 0};
deleteVehicle _vehiculo;
} forEach _vehiclesX;
{_soldierX = _x;
waitUntil {sleep 1; {_x distance _soldierX < distanceSPWN} count (allPlayers - (entities "HeadlessClient_F")) == 0};
deleteVehicle _soldierX;
} forEach _soldiers;
{deleteGroup _x} forEach _groups;