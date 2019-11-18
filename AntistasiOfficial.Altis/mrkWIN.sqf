//This script is triggered only when a player capture the flag. Passive winning conditions are somewhere else.
private ["_flagX","_pos","_markerX","_positionX","_size","_powerpl","_arevealX"];

_flagX = _this select 0;
_playerX = objNull;
if (count _this > 1) then {_playerX = _this select 1};

if ((player != _playerX) and (!isServer)) exitWith {};

_pos = getPos _flagX;
_markerX = [markers,_pos] call BIS_fnc_nearestPosition;
if (_markerX in mrkFIA) exitWith {};
_positionX = getMarkerPos _markerX;
_size = [_markerX] call sizeMarker;

if ((!isNull _playerX) and (captive _playerX)) exitWith {hint localize "STR_HINTS_MRKW_YCCTFWIUM"};

//Reveal enemy units to player within a range
	if (!isNull _playerX) then {
		if (_size > 300) then {_size = 300};
		_arevealX = [];
		{ if (((side _x == side_green) or (side _x == side_red)) and (alive _x) and (not(fleeing _x)) and (_x distance _positionX < _size)) then {_arevealX pushBack _x};} forEach allUnits;
		if (player == _playerX) then {
			_playerX playMove "MountSide";
			sleep 8;
			_playerX playMove "";
			{player reveal _x} forEach _arevealX;
		};
	};

if (!isServer) exitWith {};

{ //add score and give info to player
	if (isPlayer _x) then {
		[5,_x] remoteExec ["playerScoreAdd",_x];
		[[_markerX], "intelFound.sqf"] remoteExec ["execVM",_x];
		if (captive _x) then {[_x,false] remoteExec ["setCaptive",_x]};
	}
} forEach ([_size,0,_positionX,"BLUFORSpawn"] call distanceUnits);

//if (!isNull _playerX) then {[5,_playerX] call playerScoreAdd};
[[_flagX,"remove"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
_flagX setFlagTexture guer_flag_texture;

sleep 5;
[[_flagX,"unit"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
[[_flagX,"vehicle"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
_flagX addAction [localize "str_act_mapInfo",
		{
			nul = [] execVM "cityinfo.sqf";
		},
		nil,
		0,
		false,
		true,
		"",
		"(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"
	];
// [[_flagX,"garage"],"AS_fnc_addActionMP"] call BIS_fnc_MP; Stef 27/10 disabled old garage

_antenna = [antennas,_positionX] call BIS_fnc_nearestPosition;
if (getPos _antenna distance _positionX < 100) then {
	[_flagX,"jam"] remoteExec ["AS_fnc_addActionMP"];
};

mrkAAF = mrkAAF - [_markerX];
mrkFIA = mrkFIA + [_markerX];
publicVariable "mrkAAF";
publicVariable "mrkFIA";

reducedGarrisons = reducedGarrisons - [_markerX];
publicVariable "reducedGarrisons";

[_markerX] call AS_fnc_markerUpdate;

[_markerX] remoteExec ["patrolCA", call AS_fnc_getNextWorker];

//Depending on marker type
	if (_markerX in airportsX) then {
		[0,10,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
		{["TaskSucceeded", ["", localize "STR_NTS_AIRPORT_TKN"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		[5,8] remoteExec ["prestige",2];
		planesAAFmax = planesAAFmax - 1;
	    helisAAFmax = helisAAFmax - 2;
	   	if (activeBE) then {["con_bas"] remoteExec ["fnc_BE_XP", 2]};
	    };
	if (_markerX in bases) then {
		[0,10,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
		{["TaskSucceeded", ["", localize "STR_NTS_BASE_TKN"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		[5,8] remoteExec ["prestige",2];
		APCAAFmax = APCAAFmax - 2;
		tanksAAFmax = tanksAAFmax - 1;
		_minesAAF = allmines - (detectedMines side_blue);
		if (count _minesAAF > 0) then {
			{if (_x distance _pos < 1000) then {side_blue revealMine _x}} forEach _minesAAF;
		};
		if (activeBE) then {["con_bas"] remoteExec ["fnc_BE_XP", 2]};
	};

	if (_markerX in power) then {
		{["TaskSucceeded", ["", localize "STR_NTS_POWER_TKN"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		[0,0] remoteExec ["prestige",2];
		if (activeBE) then {["con_ter"] remoteExec ["fnc_BE_XP", 2]};
		[_markerX] call AS_fnc_powerReorg;
	};
	if (_markerX in outposts) then{
		{["TaskSucceeded", ["", localize "STR_NTS_OP_TKN"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		if (activeBE) then {["con_ter"] remoteExec ["fnc_BE_XP", 2]};
	};
	if (_markerX in seaports) then {
		{["TaskSucceeded", ["", localize "STR_NTS_SEA_TKN"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		[0,0] remoteExec ["prestige",2];
		if (activeBE) then {["con_ter"] remoteExec ["fnc_BE_XP", 2]};
		[[_flagX,"seaport"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
	};
	if ((_markerX in factories) or (_markerX in resourcesX)) then {
		if (_markerX in factories) then {{["TaskSucceeded", ["", localize "STR_NTS_FACT_TKN"]] call BIS_fnc_showNotification} remoteExec ["call", 0];};
		if (_markerX in resourcesX) then {{["TaskSucceeded", ["", localize "STR_NTS_RES_TKN"]] call BIS_fnc_showNotification} remoteExec ["call", 0];};
		if (activeBE) then {["con_ter"] remoteExec ["fnc_BE_XP", 2]};
		[0,0] remoteExec ["prestige",2];
		_powerpl = [power, _positionX] call BIS_fnc_nearestPosition;
		if (_powerpl in mrkAAF) then {
			sleep 5;
			{["TaskFailed", ["", localize "STR_NTS_RES_OUT_POWER"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
			[_markerX, false] call AS_fnc_adjustLamps;
		} else {
			[_markerX, true] call AS_fnc_adjustLamps;
		};
	};

//Old roadblock removal, no longer working and autogarrison is disabled to save units.
{[_markerX,_x] spawn AS_fnc_deleteRoadblock} forEach controlsX;
//sleep 15;
[_markerX] remoteExec ["autoGarrison", call AS_fnc_getNextWorker];

waitUntil {sleep 1;
	(not (spawner getVariable _markerX)) or
	(
	({(not(vehicle _x isKindOf "Air")) and (alive _x) and (lifeState _x != "INCAPACITATED") and (!fleeing _x)}
	count ([_size,0,_positionX,"OPFORSpawn"] call distanceUnits)) > 3* ({(alive _x) and (lifeState _x != "INCAPACITATED")}
	count ([_size,0,_positionX,"BLUFORSpawn"] call distanceUnits))
	)
}; //need to add check for unconscious

if (spawner getVariable _markerX) then {
	[_markerX] spawn mrkLOOSE;
};