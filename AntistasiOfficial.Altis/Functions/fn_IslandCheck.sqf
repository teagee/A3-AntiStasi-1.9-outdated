params ["_markerOne", "_markerTwo"];

private _return = false;

if (_markerOne isEqualType "") then {_markerOne = getMarkerPos _markerOne};
if (_markerTwo isEqualType "") then {_markerTwo = getMarkerPos _markerTwo};

call {
	if (_markerOne distance getMarkerPos "island" <= 5500) exitWith {
		if (_markerTwo distance getMarkerPos "island" <= 5500) then {_return = true};
	};
	if (_markerOne distance getMarkerPos "island_1" <= 2000) exitWith {
		if (_markerTwo distance getMarkerPos "island_1" <= 2000) then {_return = true};
	};
	if (_markerOne distance getMarkerPos "island_2" <= 2000) exitWith {
		if (_markerTwo distance getMarkerPos "island_2" <= 2000) then {_return = true};
	};
	if (_markerOne distance getMarkerPos "island_3" <= 3000) exitWith {
		if (_markerTwo distance getMarkerPos "island_3" <= 3000) then {_return = true};
	};
	if (_markerOne distance getMarkerPos "island_4" <= 2500) exitWith {
		if (_markerTwo distance getMarkerPos "island_4" <= 2500) then {_return = true};
	};
};

_return