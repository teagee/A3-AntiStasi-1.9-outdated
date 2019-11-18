//This script is executed only after a "Create" is completed and spawner check return true
//The effect is enemy capture the territory.
if (!isServer) exitWith {};

private ["_markerX","_positionX","_mrk","_powerpl","_flagX"];

_markerX = _this select 0;
if (_markerX in mrkAAF) exitWith {};
_positionX = getMarkerPos _markerX;

mrkAAF = mrkAAF + [_markerX];
mrkFIA = mrkFIA - [_markerX];
publicVariable "mrkAAF";
publicVariable "mrkFIA";

// BE module
	if (activeBE) then {
		["territory", -1] remoteExec ["fnc_BE_update", 2];
	};

//remove FIA garrison variable
	garrison setVariable [_markerX,[],true];

_flagX = objNull;
_dist = 10;
while {isNull _flagX} do {
	_dist = _dist + 10;
	_flagsX = nearestObjects [_positionX, ["FlagCarrier"], _dist];
	_flagX = _flagsX select 0;
};

[[_flagX,"take"],"AS_fnc_addActionMP"] call BIS_fnc_MP;

_mrk = format ["Dum%1",_markerX];
_mrk setMarkerColor IND_marker_colour;

//Effects depending on marker type
	if ((not (_markerX in bases)) and (not (_markerX in airportsX))) then {
		[10,-10,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
		if (_markerX in outposts) then {
			_mrk setMarkerText localize "STR_GL_AAFOP";
			{["TaskFailed", ["", localize "STR_NTS_OPLOST"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		};
		if (_markerX in seaports) then {
			_mrk setMarkerText localize "STR_GL_MAP_SP";
			{["TaskFailed", ["", localize "STR_NTS_SPLOST"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		};
	};
	if (_markerX in power) then {
		[0,0] remoteExec ["prestige",2];
		_mrk setMarkerText localize "STR_GL_MAP_PP";
		{["TaskFailed", ["", localize "STR_NTS_POWLOST"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		[_markerX] spawn AS_fnc_powerReorg;
	};

	if ((_markerX in resourcesX) or (_markerX in factories)) then {
		[0,-8,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
		[0,0] remoteExec ["prestige",2];
		if (_markerX in resourcesX) then {
			_mrk setMarkerText localize "STR_GL_MAP_RS";
			{["TaskFailed", ["", localize "STR_NTS_RESLOST"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		} else {
			_mrk setMarkerText localize "STR_GL_MAP_FAC";
			{["TaskFailed", ["", localize "STR_NTS_FACLOST"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
		};
	};

	if ((_markerX in bases) or (_markerX in airportsX)) then {
		[20,-20,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
		_mrk setMarkerType IND_marker_type;
		[0,-8] remoteExec ["prestige",2];
		server setVariable [_markerX,dateToNumber date,true];
		[_markerX,60] spawn AS_fnc_addTimeForIdle;
		if (_markerX in bases) then {
			{["TaskFailed", ["", localize "STR_NTS_BASELOST"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
			_mrk setMarkerText localize "STR_GL_AAFBS";
			APCAAFmax = APCAAFmax + 2;
	        tanksAAFmax = tanksAAFmax + 1;
		} else {
			{["TaskFailed", ["", localize "STR_NTS_ABLOST"]] call BIS_fnc_showNotification} remoteExec ["call", 0];
			_mrk setMarkerText localize "STR_GL_AAFAB";
			server setVariable [_markerX,dateToNumber date,true];
			planesAAFmax = planesAAFmax + 1;
	        helisAAFmax = helisAAFmax + 2;
	    };
	};

_size = [_markerX] call sizeMarker;

//Remove static guns, enemies have already their own.
	_staticsToSave = staticsToSave;
	{
		if ((position _x) distance _positionX < _size) then {
			_staticsToSave = _staticsToSave - [_x];
			deleteVehicle _x;
		};
	} forEach staticsToSave;

	if (not(_staticsToSave isEqualTo staticsToSave)) then {
		staticsToSave = _staticsToSave;
		publicVariable "staticsToSave";
	};

//Reverting the owership in case of player manage to capture back.
	waitUntil {sleep 1;
		(not (spawner getVariable _markerX)) or
		(({	(not(vehicle _x isKindOf "Air")) and
		 	(alive _x) and
		 	(lifeState _x != "INCAPACITATED")}
		 	count ([_size,0,_positionX,"BLUFORSpawn"] call distanceUnits)) > 3*(
		  {	(alive _x) and
			(lifeState _x != "INCAPACITATED") and
			(!fleeing _x)}
			count ([_size,0,_positionX,"OPFORSpawn"] call distanceUnits))
		)
	};

	if (spawner getVariable _markerX) then{[_flagX] spawn mrkWIN;};