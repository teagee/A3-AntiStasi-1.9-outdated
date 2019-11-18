//#define DEBUG_SYNCHRONOUS
//#define DEBUG_MODE_FULL
#include "script_component.hpp"
if (!isServer and hasInterface) exitWith{};
params ["_veh", "_text"];
TRACE_2("START inmuneConvoy", _veh, _text);
private ["_veh","_text","_mrkFinal","_pos","_side","_typeX","_newPos","_road","_friendlies"];

_enemyX = true;
_convoy = false;

waitUntil {sleep 1; (not(isNull driver _veh))};

_side = side (driver _veh);
_typeX = "hd_destroy";
if ((_side == side_blue) or (_side == civilian)) then {_enemyX = false};

if (_side == side_green) then {
	if ((typeOf _veh) in CIV_vehicles) then {_typeX = "n_unknown"}
	else {
		if (((typeOf _veh) in vehPatrol) or ((typeOf _veh) in vehTrucks)) then {_typeX = "n_motor_inf"}
		else {
			if (((typeOf _veh) in vehAPC) or ((typeOf _veh) in vehIFV)) then {_typeX = "n_mech_inf"}
			else {
				if ((typeOf _veh) in vehTank) then {_typeX = "n_armor"}
				else {
					if (_veh isKindOf "Plane_Base_F") then {_typeX = "n_plane"}
					else {
						if (_veh isKindOf "UAV_02_base_F") then {_typeX = "n_uav"}
						else {
							if (_veh isKindOf "Helicopter") then {_typeX = "n_air"}
							else {
								if (_veh isKindOf "Boat_F") then {_typeX = "n_naval"}
							};
						};
					};
				};
			};
		};
	};
};

if (_side == side_red) then {
	_typeX = "o_air";
};

if ((_side == side_blue) or (_side == civilian)) then
	{
	if ((typeOf _veh == guer_veh_truck) or (typeOf _veh == AS_misVehicleBox)) then {_typeX = "b_motor_inf"}
	else
		{
		if (typeOf _veh in bluMBT) then {_typeX = "b_armor"}
		else
			{
			if (typeOf _veh in bluCASFW) then {_typeX = "b_plane"}
			else
				{
				if ((typeOf _veh) in planesNATO) then {_typeX = "b_air"}
				else {_typeX = "b_unknown"};
				};
			};
		};
	};
if ((_text == "AAF Convoy Objective") or (_text == "Mission Vehicle") or (debug)) then {_convoy = true;};

if (!_convoy) exitWith {};

if (debug) then {revealX = true};

waitUntil {sleep 1;(not alive _veh) or ({(_x knowsAbout _veh > 1.4) and (side _x == side_blue)} count allUnits >0) or (!_enemyX) or (revealX)};

if (!alive _veh) exitWith {};

if (_enemyX) then {[_text,{["TaskSucceeded", ["", format ["%1 Spotted",_this]]] call BIS_fnc_showNotification}] remoteExec ["call", 0];};
_mrkFinal = createMarker [format ["%2%1", random 100,_text], position _veh];
_mrkFinal setMarkerShape "ICON";
_mrkFinal setMarkerType _typeX;
if (_typeX == "hd_destroy") then
	{
	if (_enemyX) then {_mrkFinal setMarkerColor OPFOR_marker_colour} else {_mrkFinal setMarkerColor BLUFOR_marker_colour};
	};
_mrkFinal setMarkerText _text;
while {(alive _veh) and ((side (driver _veh) == _side) or _convoy)} do
	{
	_pos = getPos _veh;
	_mrkFinal setMarkerPos _pos;
	sleep 60;
	_newPos = getPos _veh;
	if (_newPos distance _pos < 5) then
		{
		if (_veh isKindOf "Air") then
			{
			if (isTouchingGround _veh) then
				{
				{
				unAssignVehicle _x;
	   			moveOut _x;
	   			sleep 1.5;
				} forEach assignedCargo _veh;
				};
			}
		else
			{
			if ({_x distance _newPos < 500} count (allPlayers - (entities "HeadlessClient_F")) == 0) then
				{
				_road = [_newPos,100] call BIS_fnc_nearestRoad;
				if (!isNull _road) then
					{
					_veh setPos getPos _road;
					};
				};
			};
		};
	};
deleteMarker _mrkFinal;
