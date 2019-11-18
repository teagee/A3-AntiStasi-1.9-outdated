private ["_destinationX","_originX","_radiusX","_dif","_roads","_road","_dist","_result","_threat"];

_destinationX = _this select 0;
_originX = _this select 1;
_threat = _this select 2;
_radiusX = 400 + (10*_threat);
_dif = (_destinationX select 2) - (_originX select 2);

if (_dif > 0) then
	{
	_radiusX = _radiusX + (_dif * 2);
	};

while {true} do
	{
	_roads = _destinationX nearRoads _radiusX;
	if (_roads isEqualTo []) then {_radiusX = _radiusX + 50};
	if !(_roads isEqualTo []) exitWith {};
	};

_road = _roads select 0;
_dist = _originX distance (position _road);
{
if ((_originX distance (position _x)) < _dist) then
	{
	_dist = _originX distance (position _x);
	_road = _x;
	};
} forEach _roads - [_road];

_result = position _road;

_result
