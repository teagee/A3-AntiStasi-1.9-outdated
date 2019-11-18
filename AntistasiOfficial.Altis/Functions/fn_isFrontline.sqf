params ["_marker"];
private ["_isFrontline","_position", "_mrkFIA"];

_isFrontline = false;
_mrkFIA = airportsX + bases + outposts - mrkAAF;

if (count _mrkFIA > 0) then {
	_position = getMarkerPos _marker;
	{
		if (_position distance (getMarkerPos _x) < distanceSPWN) exitWith {_isFrontline = true};
	} forEach _mrkFIA;
};

_isFrontline