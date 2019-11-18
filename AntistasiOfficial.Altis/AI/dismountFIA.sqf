// Select group, Y menu, dismount. Could be improved.
private ["_groupX","_modeX"];

_groupX = _this select 0;

while {{alive _x} count units _groupX > 0} do
	{
	sleep 3;
	_modeX = behaviour leader _groupX;

	if (_modeX != "SAFE") then
		{
		{[_x] orderGetIn false; [_x] allowGetIn false} forEach units _groupX;
		}
	else
		{
		{[_x] orderGetIn true; [_x] allowGetIn true} forEach units _groupX;
		};
	};
