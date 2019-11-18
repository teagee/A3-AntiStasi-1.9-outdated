if (player!= Slowhand) exitWith {hint localize "STR_HINTS_ST_OTCCOTR"};
_presente = false;

{
if ((side _x == side_green) or (side _x == side_red)) then
	{
	if ([500,1,_x,"BLUFORSpawn"] call distanceUnits) then {_presente = true};
	};
} forEach allUnits;
if (_presente) exitWith {hint localize "STR_HINTS_ST_YCRWENOU"};
if ("AttackAAF" in missionsX) exitWith {hint localize "STR_HINTS_ST_YCRWAAFOCSATIC"};
if ("DEF_HQ" in missionsX) exitWith {hint localize "STR_HINTS_ST_YCRWYHQIUA"};

_checkX = false;
_posHQ = getMarkerPos guer_respawn;
{
if (_x distance _posHQ > 100) then {_checkX = true};
} forEach (allPlayers - (entities "HeadlessClient_F"));

if (_checkX) exitWith {hint localize "STR_HINTS_ST_APMBIA100MRFHQ"};

[[],"resourcecheckSkipTime"] call BIS_fnc_MP;


