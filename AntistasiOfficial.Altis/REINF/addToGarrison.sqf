private ["_positionTel","_nearX","_thingX","_groupX","_unitsX","_leave"];
openMap true;
positionTel = [];
_thingX = _this select 0;

onMapSingleClick "positionTel = _pos";

hint "Select the zone on which sending the selected troops as garrison";

waitUntil {sleep 0.5; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel = positionTel;

_nearX = [markers,_positionTel] call BIS_fnc_nearestPosition;

if !(_positionTel inArea _nearX) exitWith {hint "You must click near a marked zone"};

if (not(_nearX in mrkFIA)) exitWith {hint "That zone does not belong to Syndikat"};

if ((_nearX in outpostsFIA) and !(isOnRoad getMarkerPos _nearX)) exitWith {hint "You cannot manage garrisons on this kind of zone"};

_thingX = _this select 0;

_groupX = grpNull;
_unitsX = objNull;

if ((_thingX select 0) isEqualType grpNull) then
	{
	_groupX = _thingX select 0;
	_unitsX = units _groupX;
	}
else
	{
	_unitsX = _thingX;
	};

_leave = false;

{
if ((typeOf _x == guer_POW) or (typeOf _x in CIV_units) or (!alive _x)) exitWith {_leave = true}
} forEach _unitsX;

if (_leave) exitWith {hint "Static crewman, prisoners, refugees or dead units cannot be added to any garrison"};

if ((groupID _groupX == "MineSw") or (groupID _groupX == "Watch") or (isPlayer(leader _groupX))) exitWith {hint "You cannot garrison player led, Watchpost, Roadblocks or Minefield building squads"};


if (isNull _groupX) then
	{
	_groupX = createGroup side_blue;
	_unitsX joinSilent _groupX;
	hint "Adding units to garrison";
	{arrayids pushBackUnique (name _x)} forEach _unitsX;
	}
else
	{
	hint format ["Adding %1 squad to garrison", groupID _groupX];
	};

_garrison = [];
_garrison = _garrison + (garrison getVariable [_nearX,[]]);
{_garrison pushBack (typeOf _x)} forEach _unitsX;
garrison setVariable [_nearX,_garrison,true];
[_nearX] call  AS_fnc_markerUpdate;

_noBorrar = false;

if (spawner getVariable _nearX) then
	{
	{deleteWaypoint _x} forEach waypoints _groupX;
	_wp = _groupX addWaypoint [(getMarkerPos _nearX), 0];
	_wp setWaypointType "MOVE";
	{
	_x setVariable ["markerX",_nearX,true];
	_x addEventHandler ["killed",
		{
		_victim = _this select 0;
		_markerX = _victim getVariable "markerX";
		if (!isNil "_markerX") then
			{
			if (_markerX in mrkFIA) then
				{
				_garrison = [];
				_garrison = _garrison + (garrison getVariable [_markerX,[]]);
				if (_garrison isEqualType []) then
					{
					for "_i" from 0 to (count _garrison -1) do
						{
						if (typeOf _victim == (_garrison select _i)) exitWith {_garrison deleteAt _i};
						};
					garrison setVariable [_markerX,_garrison,true];
					};
				[_markerX] call AS_fnc_markerUpdate;
				_victim setVariable [_markerX,nil,true];
				};
			};
		}];
	} forEach _unitsX;

	waitUntil {sleep 1; (!(spawner getVariable _nearX) or !(_nearX in mrkFIA))};
	if (!(_nearX in mrkFIA)) then {_noBorrar = true};
	};

if (!_noBorrar) then
	{
	{
	if (alive _x) then
		{
		deleteVehicle _x
		};
	} forEach _unitsX;
	deleteGroup _groupX;
	}
else
	{
	//añadir el grupo al HC y quitarles variables
	{
	if (alive _x) then
		{
		_x setVariable ["markerX",nil,true];
		_x removeAllEventHandlers "killed";
		_x addEventHandler ["killed", {
			_victim = _this select 0;
			_killer = _this select 1;
			[_victim] remoteExec ["postmortem",2];
			if ((isPlayer _killer) and (side _killer == side_blue)) then
				{
				if (!isMultiPlayer) then
					{
					_nul = [0,20] remoteExec ["resourcesFIA",2];
					_killer addRating 1000;
					};
				}; /* Stef, will do later
			else
				{
				if (side _killer == side_green) then
					{
					_nul = [0.25,0,getPos _victim] remoteExec ["citySupportChange",2];
					[-0.25,0] remoteExec ["prestige",2];
					}
				else
					{
					if (side _killer == side_red) then {[0,-0.25] remoteExec ["prestige",2]};
					};
				};*/
			_victim setVariable ["BLUFORSpawn",nil,true];
			}];
		};
	} forEach _unitsX;
	Slowhand hcSetGroup [_groupX];
	hint format ["Group %1 is back to HC control because the zone which was pointed to garrison has been lost",groupID _groupX];
	};
