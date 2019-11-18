private ["_markerX","_threat","_positionX","_analyzed","_size"];

_threat = 0;

{if (_x in unlockedWeapons) then {_threat = 3};} forEach genATLaunchers;

if (activeAFRF) then {{if (_x in unlockedWeapons) then {_threat = 2};} forEach genATLaunchers;};

_markerX = _this select 0;

if (_markerX isEqualType []) then {_positionX = _markerX} else {_positionX = getMarkerPos _markerX};
_threat = _threat + 2 * ({(isOnRoad getMarkerPos _x) and (getMarkerPos _x distance _positionX < distanceSPWN)} count outpostsFIA);

{
if (getMarkerPos _x distance _positionX < distanceSPWN) then {
	_analyzed = _x;
	_garrison = garrison getVariable [_analyzed,[]];
	_threat = _threat + (2*({(_x == guer_sol_LAT)} count _garrison)) + (floor((count _garrison)/8));
	_size = [_analyzed] call sizeMarker;
	_staticsX = staticsToSave select {_x distance (getMarkerPos _analyzed) < _size};
	if (count _staticsX > 0) then {
		_threat = _threat + ({typeOf _x in statics_allMortars} count _staticsX) + (2*({typeOf _x in statics_allATs} count _staticsX));
	};
};
} forEach (mrkFIA - citiesX - controlsX - colinas - outpostsFIA);

_threat