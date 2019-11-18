// usage: Activate via radio trigger, on act: [] execVM "airstrike.sqf";
if (!isServer) exitWith{};

private ["_markerX","_positionX","_ang","_angorig","_pos1","_origpos","_pos2","_finpos","_plane","_wp1","_wp2","_wp3","_typePlane","_sideX"];

_markerX = _this select 0;
_typePlane = _this select 1;
_positionX = getMarkerPos _markerX;

if (_typePlane in opCASFW) then {_sideX = side_red};
if (_typePlane in bluCASFW) then {_sideX = side_blue};

_ang = random 360;
_angorig = _ang + 180;

_pos1 = [_positionX, 400, _angorig] call BIS_Fnc_relPos;
_origpos = [_positionX, 4500, _angorig] call BIS_fnc_relPos;
_pos2 = [_positionX, 200, _ang] call BIS_Fnc_relPos;
_finpos = [_positionX, 4500, _ang] call BIS_fnc_relPos;

_planefn = [_origpos, _ang, _typePlane, _sideX] call bis_fnc_spawnvehicle;
_plane = _planefn select 0;
_plane setVariable ["OPFORSpawn",false]; //Vehicle not defined? Sparker.
_planeCrew = _planefn select 1;
_groupPlane = _planefn select 2;
_plane setPosATL [getPosATL _plane select 0, getPosATL _plane select 1, 1000];
_plane disableAI "TARGET";
_plane disableAI "AUTOTARGET";
_plane flyInHeight 100;


_wp1 = _groupPlane addWaypoint [_pos1, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "LIMITED";
_wp1 setWaypointBehaviour "CARELESS";
if (_typePlane in opCASFW) then
	{
	if ((_markerX in bases) or (_markerX in airportsX)) then
		{
		_wp1 setWaypointStatements ["true", "[this] execVM 'AI\airbomb.sqf'"];
		}
	else
		{
		if (_markerX in citiesX) then
			{
			_wp1 setWaypointStatements ["true", "[this,""NAPALM""] execVM 'AI\airbomb.sqf'"];
			}
		else
			{
			_wp1 setWaypointStatements ["true", "[this,""CLUSTER""] execVM 'AI\airbomb.sqf'"];
			};
		};
	}
else
	{
	_wp1 setWaypointStatements ["true", "[this] execVM 'AI\airbomb.sqf'"];
	};

_wp2 = _groupPlane addWaypoint [_pos2, 1];
_wp2 setWaypointSpeed "LIMITED";
_wp2 setWaypointType "MOVE";

_wp3 = _groupPlane addWaypoint [_finpos, 2];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "FULL";
_wp3 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew this; deleteVehicle this"];

waitUntil {sleep 2; (currentWaypoint _groupPlane == 4) or (!canMove _plane)};

{deleteVehicle _x} forEach _planeCrew;
deleteVehicle _plane;
deleteGroup _groupPlane;




