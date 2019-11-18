private ["_markerX","_threat","_isMarker","_positionX","_isFIA","_analyzed","_size"];

_threat = 0;


{if (_x in unlockedWeapons) then {_threat = 5};} forEach genAALaunchers;


_markerX = _this select 0;
_isMarker = true;
if (_markerX isEqualType []) then {_isMarker = false; _positionX = _markerX} else {_positionX = getMarkerPos _markerX};

_isFIA = false;
if (_isMarker) then {
	if (_markerX in mrkAAF) then {
		{
			if (getMarkerPos _x distance _positionX < (distanceSPWN*1.5)) then {
				if ((_x in bases) or (_x in airportsX)) then {_threat = _threat + 3} else {_threat = _threat + 1};
			};
		} forEach (controlsX + outposts + colinas + bases + airportsX - mrkFIA);
	} else {_isFIA = true;};
} else { _isFIA = true;};

if (_isFIA) then {
	{
		if (getMarkerPos _x distance _positionX < distanceSPWN) then {
			_analyzed = _x;
			_garrison = garrison getVariable [_analyzed,[]];
			_threat = _threat + (floor((count _garrison)/4));
			_size = [_analyzed] call sizeMarker;
			_staticsX = staticsToSave select {_x distance (getMarkerPos _analyzed) < _size};
			if (count _staticsX > 0) then {
				_threat = _threat + ({typeOf _x in statics_allMGs} count _staticsX) + (5*({typeOf _x in statics_allAAs} count _staticsX));
			};
		};
	} forEach (mrkFIA - citiesX - controlsX - colinas - outpostsFIA);
};

_threat