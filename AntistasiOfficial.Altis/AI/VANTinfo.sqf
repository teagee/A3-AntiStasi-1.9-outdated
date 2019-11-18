private ["_veh","_markerX","_positionX","_groups","_knownX","_groupX","_LeaderX"];

_veh = _this select 0;
_markerX = _this select 1;

_positionX = getMarkerPos _markerX;

while {alive _veh} do
	{
	_knownX = [];
	_groups = [];
	_enemiesX = [distanceSPWN,0,_positionX,"OPFORSpawn"] call distanceUnits;
	sleep 60;
	{
	_LeaderX = leader _x;
	if ((_LeaderX in _enemiesX) and (vehicle _LeaderX != _LeaderX)) then {_groups pushBack _x};
	} forEach allGroups;
	{
	if ((side _x == side_blue) and (alive _x) and (_x distance _positionX < 500)) then
		{
		_knownX pushBack _x;
		};
	} forEach allUnits;
	{
	_groupX = _x;
		{
		_groupX reveal [_x,4];
		} forEach _knownX;
	} forEach _groups;

	};