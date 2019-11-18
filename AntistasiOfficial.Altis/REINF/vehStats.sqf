if (count hcSelected player != 1) exitWith {hint "You must select one group on the HC bar"};

private ["_groupX","_veh","_textX"];

_groupX = (hcSelected player select 0);

_esStatic = false;
{if (vehicle _x isKindOf "StaticWeapon") then {_esStatic = true}} forEach units _groupX;
if (_esStatic) exitWith {hint "Static Weapon squad vehicles cannot be managed"};

_veh = objNull;

{
_owner = _x getVariable "owner";
if (!isNil "_owner") then {if (_owner == _groupX) then {_veh = _x}};
} forEach vehicles;

if (isNull _veh) exitWith {hint "The group has no vehicle assigned"};

if (_this select 0 == "stats") then
	{
	_textX = format ["Squad %1 Vehicle Stats\n\n%2",groupID _groupX,getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "displayName")];
	if (!alive _veh) then
		{
		_textX = format ["%1\n\nDESTROYED",_textX];
		}
	else
		{
		if (!canMove _veh) then {_textX = format ["%1\n\nDISABLED",_textX]};
		if (count allTurrets [_veh, false] > 0) then
			{
			if (!canFire _veh) then {_textX = format ["%1\n\nWEAPON DISABLED",_textX]};
			if (someAmmo _veh) then {_textX = format ["%1\n\nMunitioned",_textX]};
			};
		};
	hint format ["%1",_textX];
	};

if (_this select 0 == "mount") then
	{
	_transporte = true;
	if (count allTurrets [_veh, false] > 0) then {_transporte = false};
	if (_transporte) then
		{
		if (leader _groupX in _veh) then
			{
			hint format ["%1 dismounting",groupID _groupX];
			{[_x] orderGetIn false; [_x] allowGetIn false} forEach units _groupX;
			}
		else
			{
			hint format ["%1 boarding",groupID _groupX];
			{[_x] orderGetIn true; [_x] allowGetIn true} forEach units _groupX;
			};
		}
	else
		{
		if (leader _groupX in _veh) then
			{
			hint format ["%1 dismounting",groupID _groupX];
			if (canMove _veh) then
				{
				{[_x] orderGetIn false; [_x] allowGetIn false} forEach assignedCargo _veh;
				}
			else
				{
				_veh allowCrewInImmobile false;
				{[_x] orderGetIn false; [_x] allowGetIn false} forEach units _groupX;
				}
			}
		else
			{
			hint format ["%1 boarding",groupID _groupX];
			{[_x] orderGetIn true; [_x] allowGetIn true} forEach units _groupX;
			};
		};
	};

