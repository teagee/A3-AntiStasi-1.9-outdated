private ["_veh","_cargo","_groupX","_modeX"];

_veh = _this select 0;

_cargo = assignedCargo _veh;
_groupX = group (driver _veh);

while {sleep 1;({alive _x} count units _groupX > 0) and (canMove _veh) and (alive _veh)} do
	{
	sleep 1;
	_modeX = behaviour leader _groupX;
	if (_modeX == "COMBAT") then
		{
		waitUntil {(!alive _veh) or (speed _veh < 1)};
		if (alive _veh) then
			{
			_veh fire "SmokeLauncher";
			[_veh] call entriesLand;
				//sleep 2;
			{[_x] orderGetIn false; [_x] allowGetIn false} forEach _cargo;
			//sleep ({alive _x} count units _groupX);
			[_veh] call entriesLand;
			waitUntil {sleep 1; ({alive _x} count units _groupX == 0) or (not canMove _veh) or (behaviour leader _groupX != "COMBAT")};
			if (canMove _veh) then {{[_x] orderGetIn true; [_x] allowGetIn true} forEach _cargo};
			};
		};
	};
