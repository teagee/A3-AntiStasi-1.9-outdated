private ["_timeX","_tsk"];

_timeX = _this select 0;
_tsk = _this select 1;

if (_timeX > 0) then {sleep ((_timeX/2) + random _timeX)};

[_tsk] call BIS_fnc_deleteTask;
missionsX = missionsX - [_tsk];
publicVariable "missionsX";
/*
[_tsk] call BIS_fnc_deleteTask;
sleep 10;
[[_tsk,true,false],"bis_fnc_deleteTask"] call bis_fnc_mp;
*/