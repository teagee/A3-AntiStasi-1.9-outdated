_weapCargo = weaponCargo boxX;
_magCargo = magazineCargo boxX;
_itemCargo = itemCargo boxX;
_bpCargo = backpackCargo boxX;

[[], [], [], []] params ["_uWc", "_uMc", "_uIc", "_uBc"];

if (count _weapCargo > 0) then {
	for "_i" from 0 to (count _weapCargo - 1) do {
		_z = _weapCargo select _i;
		if (_z in gear_allWeapons) then {
			if !(_z in unlockedWeapons) then {_uWc pushBack _z};
		};
	};
	clearWeaponCargoGlobal boxX;
	{boxX addWeaponCargoGlobal [_x,1]} forEach _uWc;
};

if (count _magCargo > 0) then {
	for "_i" from 0 to (count _magCargo - 1) do {
		_z = _magCargo select _i;
		if (_z in gear_allMagazines) then {
			if !(_z in unlockedMagazines) then {_uMc pushBack _z};
		};
	};
	clearMagazineCargoGlobal boxX;
	{boxX addMagazineCargoGlobal [_x,1]} forEach _uMc;
};

if (count _itemCargo > 0) then {
	for "_i" from 0 to (count _itemCargo - 1) do {
		_z = _itemCargo select _i;
		if !(_z in unlockedItems) then {_uIc pushBack (_itemCargo select _i)};
	};
	clearItemCargoGlobal boxX;
	{boxX addItemCargoGlobal [_x,1]} forEach _uIc;
};

if (count _bpCargo > 0) then {
	for "_i" from 0 to (count _bpCargo - 1) do {
		_z = _bpCargo select _i;
		if !(_z in unlockedBackpacks) then {_uBc pushBack (_bpCargo select _i)};
	};
	clearBackpackCargoGlobal boxX;
	{boxX addBackpackCargoGlobal [_x,1]} forEach _uBc;
};