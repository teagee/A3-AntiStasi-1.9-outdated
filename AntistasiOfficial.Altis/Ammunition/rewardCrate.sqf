if (!isServer) exitWith {};

_crate = _this select 0;


if (random 10 < 5) then {
	for [{_i=1},{_i<=(1 + round random 2)},{_i=_i+1}] do {
		_thingX = genMines call BIS_Fnc_selectRandom;
		_num = 1 + (floor random 5);
		if (not(_thingX in unlockedMagazines)) then {_crate addMagazineCargoGlobal [_thingX, _num]};
	};
}
else {
	if (_ran == 1) then {
		for [{_i=1},{_i<=(1 + round random 2)},{_i=_i+1}] do {
			_thingX = genOptics call BIS_Fnc_selectRandom;
			_num = 1 + (floor random 5);
			if (not(_thingX in unlockedOptics)) then {_crate addItemCargoGlobal [_thingX, _num]};
		};
	}
	else {
		for [{_i=1},{_i<=(1 + round random 2)},{_i=_i+1}] do {
			_thingX = genWeapons call BIS_Fnc_selectRandom;
				_num = 1 + (floor random 5);
			if (not(_thingX in unlockedWeapons)) then {
				_crate addItemCargoGlobal [_thingX, _num];
				_magazines = getArray (configFile / "CfgWeapons" / _thingX / "magazines");
				_crate addMagazineCargoGlobal [_magazines select 0, _num * 3];
			};
		};
	};
};