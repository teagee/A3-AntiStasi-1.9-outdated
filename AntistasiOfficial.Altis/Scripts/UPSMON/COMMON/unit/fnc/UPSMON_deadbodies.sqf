/****************************************************************
File: UPSMON_deadbodies.sqf
Author: Monsada

Description:
	Funci�n que devuelve un array con los vehiclesX terrestres m�s nearXs
Parameter(s):
	<--- object for  position search
	<---  max distance from npc
Returns:
	---> _vehicles:  array of vehiclesnetid object
****************************************************************/
private["_vehicles","_npc","_bodies","_closeX","_distance","_side"];

_npc = _this select 0;
_distance = _this select 1;

_closeX = [];
_bodies = objNull;

//Buscamos objectsX nearXs
_closeX = nearestObjects [_npc,["Man"],_distance];

{
	if (!alive _x) then
	{
		if ([_npc,_x,_distance,130] call UPSMON_Haslos) exitwith
		{
			_bodies = _x;
			_bodies
		};
	};
}foreach _closeX;

_bodies;
