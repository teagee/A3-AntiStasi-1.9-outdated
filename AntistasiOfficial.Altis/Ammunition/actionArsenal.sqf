private ["_box","_unit"];

_box = _this select 0;
_unit = _this select 1;

if (([_unit] call isMember) && ((server getVariable "enableMemAcc"))) exitWith {
	["Open",[nil,_box,_unit]] call BIS_fnc_arsenal;
};

_switch = false;
_bpitems = [];
_backpack = backpack _unit;
if (_backpack != "") then {
	_bpitems = backpackItems _unit;

	removeBackpack _unit;
	_unit addBackpack (_backpack call BIS_fnc_basicBackpack);
	_switch = true;

	if ((count _bpitems > 0) && (_switch)) then {
		for "_i" from 0 to (count _bpitems - 1) do {
			_unit addItemToBackpack  (_bpitems select _i);
		};
	};
};

_weaponsX = [];
_items = [];
_mags = [];
_destinationX = vehicleBox;

if ([_unit] call isMember) then {_destinationX = boxX} else {"Your locked items will be placed in the vehicle ammo box." remoteExec ["hint", player];};

_helmet = headgear _unit;

if ((!(_helmet in unlockedItems)) and (_helmet in genHelmets)) then {_items pushBack _helmet; removeHeadgear _unit};

if (activeTFAR) then {
	{
	if (!(_x in unlockedItems)) then {
		if !(toLower _x find "tf_anprc" >= 0) then {
			_items pushBack _x;
		};
	};
	} forEach ((items _unit) + (assignedItems _unit) - (weapons _unit));
}
else {
	{
	if (!(_x in unlockedItems)) then {
		_items pushBack _x;
		};
	} forEach ((items _unit) + (assignedItems _unit) - (weapons _unit));
	};

{
_ameter = false;
_weaponX = _x select 0;
_weaponXTrad = [_weaponX] call BIS_fnc_baseWeapon;
if (!(_weaponXTrad in unlockedWeapons)) then
	{
	_weaponsX pushBack _weaponXTrad;
	_ameter = true;
	};
for "_i" from 1 to (count _x) - 1 do
	{
	_thingX = _x select _i;
	if (_thingX isEqualType "") then
		{
		if (_thingX != "") then
			{
			if (!(_thingX in unlockedItems)) then
				{
				_items pushBack _thingX;
				_ameter = true;
				};
			};
		}
	else
		{
		if (_thingX isEqualType []) then
			{
			if (!((_thingX select 0) in unlockedMagazines)) then
				{
				_mags pushBack (_thingX select 0);
				_ameter = true;
				};
			};
		};
	};


if (_ameter) then
	{
	if ((_weaponX == primaryWeapon _unit) or (_weaponX == secondaryWeapon _unit) or (_weaponX == handgunWeapon _unit)) then
		{
		_unit removeWeapon _weaponX;
		}
	else
		{
		_unit removeItem _weaponX;
		};
	};
} forEach weaponsItems _unit;


if (count _weaponsX > 0) then
	{
	_weaponsXDef = [];
	_weaponsXDefCount = [];
	{
	_weaponX = _x;
	if (!(_weaponX in _weaponsXDef)) then
		{
		_weaponsXDef pushBack _weaponX;
		_weaponsXDefCount pushBack ({_x == _weaponX} count _weaponsX);
		};
	} forEach _weaponsX;
	_textX = "";
	if (_destinationX == vehicleBox) then {_textX = "The following weapons have been added to the Vehicle Ammobox:"} else {_textX = "The following weapons have been added to the Main Ammobox:"};
	for "_i" from 0 to (count _weaponsXDef - 1) do
		{
		_destinationX addWeaponCargoGlobal [_weaponsXDef select _i,_weaponsXDefCount select _i];
		if (_i == 0) then {_textX = format ["%1 %2",_textX, getText (configfile >> "CfgWeapons" >> (_weaponsXDef select _i) >> "displayName")]} else {_textX = format ["%1, %2",_textX, getText (configfile >> "CfgWeapons" >> (_weaponsXDef select _i) >> "displayName")]};
		};
	player globalChat _textX;
	};

if (count _items > 0) then
	{
	_itemsDef = [];
	_itemsDefCount = [];
	{
	_item = _x;
	if (_item in assignedItems _unit) then {_unit unassignItem _item};
	_unit removeItem _item;
	if (!(_item in _itemsDef)) then
		{
		_itemsDef pushBack _item;
		_itemsDefCount pushBack ({_x == _item} count _items);
		};
	} forEach _items;
	_textX = "";
	if (_destinationX == vehicleBox) then {_textX = "The following items have been added to the Vehicle Ammobox:"} else {_textX = "The following items have been added to the Main Ammobox:"};
	for "_i" from 0 to (count _itemsDef) - 1 do
		{
		if (_i == 0) then {_textX = format ["%1 %2",_textX, getText (configfile >> "CfgWeapons" >> (_itemsDef select _i) >> "displayName")]} else {_textX = format ["%1, %2",_textX, getText (configfile >> "CfgWeapons" >> (_itemsDef select _i) >> "displayName")]};
		_destinationX addItemCargoGlobal [_itemsDef select _i,_itemsDefCount select _i];
		};
	player globalChat _textX;
	};

{
if (!(_x in unlockedMagazines)) then
	{
	_mags pushBack _x;
	};
} forEach magazines _unit;

// experimental
{
if (!(_x in unlockedMagazines)) then
	{
	_mags pushBack _x;
	};
} forEach primaryWeaponMagazine _unit;

{
if (!(_x in unlockedMagazines)) then
	{
	_mags pushBack _x;
	};
} forEach secondaryWeaponMagazine _unit;
// experimental

if (count _mags > 0) then
	{
	_magsDef = [];
	_magsDefCount = [];
	{
	_mag = _x;
	_unit removeMagazine _mag;
	if(!(_mag in _magsDef)) then
		{
		_magsDef pushBack _mag;
		_magsDefCount pushBack ({_x == _mag} count _mags);
		};
	} forEach _mags;
	_textX = "";
	if (_destinationX == vehicleBox) then {_textX = "The following magazines have been added to the Vehicle Ammobox:"} else {_textX = "The following magazines have been added to the Main Ammobox:"};
	for "_i" from 0 to (count _magsDef) - 1 do
		{
		if (_i == 0) then {_textX = format ["%1 %2",_textX, getText (configfile >> "CfgMagazines" >> (_magsDef select _i) >> "displayName")]} else {_textX = format ["%1, %2",_textX, getText (configfile >> "CfgMagazines" >> (_magsDef select _i) >> "displayName")]};
		_destinationX addMagazineCargoGlobal [_magsDef select _i,_magsDefCount select _i];
		};
	player globalChat _textX;
	};


_backpack = backpack _unit;
if ( _backpack != "" ) then
	{
	if (not (_backpack in unlockedBackpacks)) then
		{
		_inScope = false;
		{
		if ( isNumber( configFile >> "CfgVehicles" >> _backpack >> _x ) && { getNumber( configFile >> "CfgVehicles" >> _backpack >> _x ) isEqualTo 2 } ) exitWith { true };
		}forEach [ "scope", "scopearsenal" ];
		if !( _inScope ) then
			{
			_tmpWhitelistBackpacks = [];
			// XLA fixed arsenal
			missionNamespace setVariable [ "BIS_fnc_arsenal_data", nil ];
			["Preload"] call BIS_fnc_arsenal;
			_tmpWhitelistBackpacks = ( missionNamespace getVariable "BIS_fnc_arsenal_data" ) select 5;
			_tmpWhitelistBackpacks pushBack _backpack;

			};
		};
	};

if ([_unit] call isMember) then {player globalChat "Your locked items will be placed in the vehicle ammo box."};


["Open",[nil,_box,_unit,false]] call BIS_fnc_arsenal;
