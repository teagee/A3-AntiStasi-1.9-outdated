_unit = _this select 0;
_playerX = _this select 1;

[[_unit,"remove"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
//removeAllActions _unit;

_playerX globalChat "You are free. Come with us!";
if (captive _playerX) then
	{
	[_playerX,false] remoteExec ["setCaptive",_playerX];
	};
sleep 3;
_unit globalChat "Thank you. I owe you my life!";
_unit enableAI "MOVE";
_unit enableAI "AUTOTARGET";
_unit enableAI "TARGET";
_unit enableAI "ANIM";
[_unit] join group _playerX;
[_unit] spawn AS_fnc_initialiseFIAUnit;
