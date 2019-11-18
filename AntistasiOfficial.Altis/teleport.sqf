// for easier testing

openMap true;
positionTel = [];
hint localize "STR_HINTS_TELEPORT";

onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel = positionTel;
_pos = [];

if (player != vehicle player) then {
	_pos = _positionTel findEmptyPosition [1,50,typeOf (vehicle player)];
	vehicle player setPosATL _pos;
} else {
	_pGroup = group player;
	{
		_unit = _x;
		_unit allowDamage false;
		_unit setPosATL _positionTel;
	} forEach units _pGroup;
};

openMap false;