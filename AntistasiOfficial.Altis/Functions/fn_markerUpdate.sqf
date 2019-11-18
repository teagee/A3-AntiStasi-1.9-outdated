params ["_marker"];
private _mrkD = format ["Dum%1",_marker];

if (markerColor _mrkD != guer_marker_colour) then {_mrkD setMarkerColor guer_marker_colour};

call {
	if (_marker in outposts) exitWith {
		_mrkD setMarkerText format [localize "STR_GL_MAP_OP1", count (garrison getVariable _marker), A3_Str_PLAYER];
	};
	if (_marker in bases) exitWith {
		_mrkD setMarkerText format [localize "STR_GL_MAP_MB1", count (garrison getVariable _marker), A3_Str_BLUE];
		_mrkD setMarkerType guer_marker_type;
	};
	if (_marker in power) exitWith {
		_mrkD setMarkerText format [localize "STR_GL_MAP_PP"+": %1", count (garrison getVariable _marker)];
	};
	if (_marker in resourcesX) exitWith {
		_mrkD setMarkerText format [localize "STR_GL_MAP_RS"+": %1", count (garrison getVariable _marker)];
	};
	if (_marker in airportsX) exitWith {
		_mrkD setMarkerText format [localize "STR_GL_MAP_AP1", count (garrison getVariable _marker), A3_Str_BLUE];
		_mrkD setMarkerType guer_marker_type;
	};
	if (_marker in factories) exitWith {
		_mrkD setMarkerText format [localize "STR_GL_MAP_FAC"+": %1", count (garrison getVariable _marker)];
	};
	if (_marker in seaports) exitWith {
		_mrkD setMarkerText format [localize "STR_GL_MAP_SP"+": %1", count (garrison getVariable _marker)];
	};
};