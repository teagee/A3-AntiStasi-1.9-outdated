//if (!isServer) exitWith{};

if (player != leader group player) exitWith {hint "You cannot dismiss anyone if you are not the squad leader"};

private ["_units","_hr","_resourcesFIA","_unit","_newGroup"];

_units = _this select 0;

player globalChat "Get out of my sight you useless scum!";

_ai = false;

if ({isPlayer _x} count units group player == 1) then {_ai = true; _newGroup = createGroup side_blue};

{if (!isPlayer _x) then
	{
	if (typeOf _x != guer_POW) then
		{
		[_x] join _newGroup;
		arrayids = arrayids + [name _x];
		};
	}
else
	{
	_otherGroup = createGroup side_blue;
	[_x] join _otherGroup;
	};
} forEach _units;

if (recruitCooldown < time) then {recruitCooldown = time + 60} else {recruitCooldown = recruitCooldown + 60};

if (_ai) then
	{
	_LeaderX = leader _newGroup;

	{_x domove getMarkerPos guer_respawn} forEach units _newGroup;

	_timeX = time + 120;

	waitUntil {sleep 1; (time > _timeX) or ({(_x distance getMarkerPos guer_respawn < 50) and (alive _x)} count units _newGroup == {alive _x} count units _newGroup)};

	_hr = 0;
	_resourcesFIA = 0;
	_items = [];
	_ammunition = [];
	_weaponsX = [];

	{_unit = _x;
	if ((alive _unit) and !([_x] call AS_fnc_isUnconscious)) then
		{
		_resourcesFIA = _resourcesFIA + (server getVariable (typeOf _unit));
		_hr = _hr +1;
		{if (not(([_x] call BIS_fnc_baseWeapon) in unlockedWeapons)) then {_weaponsX pushBack ([_x] call BIS_fnc_baseWeapon)}} forEach weapons _unit;
		{if (not(_x in unlockedMagazines)) then {_ammunition pushBack _x}} forEach magazines _unit;
		_items = _items + (items _unit) + (primaryWeaponItems _unit) + (assignedItems _unit) + (secondaryWeaponItems _unit);
		};
	deleteVehicle _x;
	} forEach units _newGroup;
	if (!isMultiplayer) then {[_hr,_resourcesFIA/2] remoteExec ["resourcesFIA",2];} else {[_hr,0] remoteExec ["resourcesFIA",2]; [_resourcesFIA/2] call resourcesPlayer};
	{boxX addWeaponCargoGlobal [_x,1]} forEach _weaponsX;
	{boxX addMagazineCargoGlobal [_x,1]} forEach _ammunition;
	{boxX addItemCargoGlobal [_x,1]} forEach _items;
	deleteGroup _newGroup;
	};
