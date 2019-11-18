private ["_unit","_Pweapon","_Sweapon","_countX","_magazines","_hasBox","_distancia","_objectsX","_target","_victim","_check","_timeOut","_weaponX","_weaponsX","_rearming","_basePossible","_hmd","_helmet"];

_unit = _this select 0;

if ((!alive _unit) or (isPlayer _unit) or (vehicle _unit != _unit) or (player != leader group player) or (captive _unit)) exitWith {};
if ([_unit] call AS_fnc_isUnconscious) exitWith {};
_medHelping = _unit getVariable "ASmedHelping";
if (!(isNil "_medHelping")) exitWith {_unit groupChat "I cannot rearm right now. I'm healing a comrade"};
_rearming = _unit getVariable "ASrearming";
if (_rearming) exitWith {_unit groupChat "I am currently rearming"};

_unit setVariable ["ASrearming",true];

_Pweapon = primaryWeapon _unit;
_Sweapon = secondaryWeapon _unit;

_objectsX = [];
_hasBox = false;
_weaponX = "";
_weaponsX = [];
_distancia = 51;
_objectsX = nearestObjects [_unit, ["ReammoBox_F","LandVehicle","WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 50];
if (boxX in _objectsX) then {_objectsX = _objectsX - [boxX]};
_needsRearm = false;
_victims = [];

{
_victim = _x;
if (_victim distance _unit < _distancia) then
	{
	_busy = _victim getVariable "busy";
	if (isNil "_busy") then
		{
		_victims pushBack _victim;
		};
	};
} forEach allDead;

if (_Pweapon != "") then
	{
	if (_Pweapon in baseRifles) then
		{
		_needsRearm = true;
		if (count _objectsX > 0) then
			{
			{
			_objectX = _x;
			if (_unit distance _objectX < _distancia) then
				{
				_busy = _objectX getVariable "busy";
				if ((count weaponCargo _objectX > 0) and (isNil "_busy")) then
					{
					_weaponsX = weaponCargo _objectX;
					for "_i" from 0 to (count _weaponsX - 1) do
						{
						_potential = _weaponsX select _i;
						_basePossible = [_potential] call BIS_fnc_baseWeapon;
						if (!(_potential in baseRifles) and ((_basePossible in gear_assaultRifles) or (_basePossible in gear_sniperRifles) or (_basePossible in gear_machineGuns))) then
							{
							_target = _objectX;
							_hasBox = true;
							_distancia = _unit distance _objectX;
							_weaponX = _potential;
							};
						};
					};
				};
			} forEach _objectsX;
			};
		if ((_hasBox) and (_unit getVariable "ASrearming")) then
			{
			_unit stop false;
			if ((!alive _target) or (not(_target isKindOf "ReammoBox_F"))) then {_target setVariable ["busy",true]};
			_unit doMove (getPosATL _target);
			_unit groupChat "Picking a better weapon";
			_timeOut = time + 60;
			waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
			if ((unitReady _unit) and (alive _unit) and (_unit distance _target > 3) and (_target isKindOf "ReammoBox_F") and (!isNull _target)) then {_unit setPos position _target};
			if (_unit distance _target < 3) then
				{
				_unit action ["TakeWeapon",_target,_weaponX];
				sleep 5;
				if (primaryWeapon _unit == _weaponX) then
					{
					_unit groupChat "I have a better weapon now";
					if (_target isKindOf "ReammoBox_F") then {_unit action ["rearm",_target]};
					}
				else
					{
					_unit groupChat "Couldn't take this weapon";
					};
				}
			else
				{
				_unit groupChat "Cannot take a better weapon";
				};
			_target setVariable ["busy",nil];
			_unit doFollow player;
			};
		_distancia = 51;
		_Pweapon = primaryWeapon _unit;
		sleep 3;
		};
	_hasBox = false;
	_countX = 4;
	if (_Pweapon in gear_machineGuns) then {_countX = 2};
	_magazines = getArray (configFile / "CfgWeapons" / _Pweapon / "magazines");
	if ({_x in _magazines} count (magazines _unit) < _countX) then
		{
		_needsRearm = true;
		_hasBox = false;
		if (count _objectsX > 0) then
			{
			{
			_objectX = _x;
			if (({_x in _magazines} count magazineCargo _objectX) > 0) then
				{
				if (_unit distance _objectX < _distancia) then
					{
					_target = _objectX;
					_hasBox = true;
					_distancia = _unit distance _objectX;
					};
				};
			} forEach _objectsX;
			};
		{
		_victim = _x;
		_busy = _victim getVariable "busy";
		if (({_x in _magazines} count (magazines _victim) > 0) and (isNil "_busy")) then
			{
			_target = _victim;
			_hasBox = true;
			_distancia = _victim distance _unit;
			};
		} forEach _victims;
		};
	if ((_hasBox) and (_unit getVariable "ASrearming")) then
		{
		_unit stop false;
		if ((!alive _target) or (not(_target isKindOf "ReammoBox_F"))) then {_target setVariable ["busy",true]};
		_unit doMove (getPosATL _target);
		_unit groupChat "ASrearming";
		_timeOut = time + 60;
		waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if ((unitReady _unit) and (alive _unit) and (_unit distance _target > 3) and (_target isKindOf "ReammoBox_F") and (!isNull _target)) then {_unit setPos position _target};
		if (_unit distance _target < 3) then
			{
			_unit action ["rearm",_target];
			if ({_x in _magazines} count (magazines _unit) >= _countX) then
				{
				_unit groupChat "Rearmed";
				}
			else
				{
				_unit groupChat "Partially Rearmed";
				};
			}
		else
			{
			_unit groupChat "Cannot rearm";
			};
		_target setVariable ["busy",nil];
		_unit doFollow player;
		}
	else
		{
		_unit groupChat "No source to rearm my primary weapon";
		};
	};
_hasBox = false;
if ((_Sweapon == "") and (loadAbs _unit < 340)) then
	{
	if (count _objectsX > 0) then
		{
		{
		_objectX = _x;
		if (_unit distance _objectX < _distancia) then
			{
			_busy = _objectX getVariable "busy";
			if ((count weaponCargo _objectX > 0) and (isNil "_busy")) then
				{
				_weaponsX = weaponCargo _objectX;
				for "_i" from 0 to (count _weaponsX - 1) do
					{
					_potential = _weaponsX select _i;
					if ((_potential in gear_missileLaunchers) or (_potential in gear_rocketLaunchers)) then
						{
						_target = _objectX;
						_hasBox = true;
						_distancia = _unit distance _objectX;
						_weaponX = _potential;
						};
					};
				};
			};
		} forEach _objectsX;
		};
	if ((_hasBox) and (_unit getVariable "ASrearming")) then
		{
		_unit stop false;
		if ((!alive _target) or (not(_target isKindOf "ReammoBox_F"))) then {_target setVariable ["busy",true]};
		_unit doMove (getPosATL _target);
		_unit groupChat "Picking a secondary weapon";
		_timeOut = time + 60;
		waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if ((unitReady _unit) and (alive _unit) and (_unit distance _target > 3) and (_target isKindOf "ReammoBox_F") and (!isNull _target)) then {_unit setPos position _target};
		if (_unit distance _target < 3) then
			{
			_unit action ["TakeWeapon",_target,_weaponX];
			sleep 3;
			if (secondaryWeapon _unit == _weaponX) then
				{
				_unit groupChat "I have a secondary weapon now";
				if (_target isKindOf "ReammoBox_F") then {sleep 3;_unit action ["rearm",_target]};
				}
			else
				{
				_unit groupChat "Couldn't take this weapon";
				};
			}
		else
			{
			_unit groupChat "Cannot take a secondary weapon";
			};
		_target setVariable ["busy",nil];
		_unit doFollow player;
		};
	_Sweapon = secondaryWeapon _unit;
	_distancia = 51;
	sleep 3;
	};
_hasBox = false;
if (_Sweapon != "") then
	{
	_magazines = getArray (configFile / "CfgWeapons" / _Sweapon / "magazines");
	if ({_x in _magazines} count (magazines _unit) < 2) then
		{
		_needsRearm = true;
		_hasBox = false;
		_distancia = 50;
		if (count _objectsX > 0) then
			{
			{
			_objectX = _x;
			if ({_x in _magazines} count magazineCargo _objectX > 0) then
				{
				if (_unit distance _objectX < _distancia) then
					{
					_target = _objectX;
					_hasBox = true;
					_distancia = _unit distance _objectX;
					};
				};
			} forEach _objectsX;
			};
		{
		_victim = _x;
		_busy = _victim getVariable "busy";
		if (({_x in _magazines} count (magazines _victim) > 0) and (isNil "_busy")) then
			{
			_target = _victim;
			_hasBox = true;
			_distancia = _victim distance _unit;
			};
		} forEach _victims;
		};
	if ((_hasBox) and (_unit getVariable "ASrearming")) then
		{
		_unit stop false;
		if (!alive _target) then {_target setVariable ["busy",true]};
		_unit doMove (position _target);
		_unit groupChat "ASrearming";
		_timeOut = time + 60;
		waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if ((unitReady _unit) and (alive _unit) and (_unit distance _target > 3) and (_target isKindOf "ReammoBox_F") and (!isNull _target)) then {_unit setPos position _target};
		if (_unit distance _target < 3) then
			{
			if ((backpack _unit == "") and (backPack _target != "")) then
				{
				_unit addBackPackGlobal ((backpack _target) call BIS_fnc_basicBackpack);
				_unit action ["rearm",_target];
				sleep 3;
				{_unit addMagazine [_x,1]} forEach (magazineCargo (backpackContainer _target));
				removeBackpackGlobal _target;
				}
			else
				{
				_unit action ["rearm",_target];
				};

			if ({_x in _magazines} count (magazines _unit) >= 2) then
				{
				_unit groupChat "Rearmed";
				}
			else
				{
				_unit groupChat "Partially Rearmed";
				};
			}
		else
			{
			_unit groupChat "Cannot rearm";
			};
		_target setVariable ["busy",nil];
		}
	else
		{
		_unit groupChat "No source to rearm my secondary weapon.";
		};
	sleep 3;
	};
_hasBox = false;
if (not("ItemRadio" in assignedItems _unit)) then
	{
	_needsRearm = true;
	_hasBox = false;
	_distancia = 50;
	{
	_victim = _x;
	_busy = _victim getVariable "busy";
	if (("ItemRadio" in (assignedItems _victim)) and (isNil "_busy")) then
		{
		_target = _victim;
		_hasBox = true;
		_distancia = _victim distance _unit;
		};
	} forEach _victims;
	if ((_hasBox) and (_unit getVariable "ASrearming")) then
		{
		_unit stop false;
		_target setVariable ["busy",true];
		_unit doMove (getPosATL _target);
		_unit groupChat "Picking a Radio";
		_timeOut = time + 60;
		waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if (_unit distance _target < 3) then
			{
			_unit action ["rearm",_target];
			_unit linkItem "ItemRadio";
			_target unlinkItem "ItemRadio";
			}
		else
			{
			_unit groupChat "Cannot pick the Radio";
			};
		_target setVariable ["busy",nil];
		_unit doFollow player;
		};
	};
_hasBox = false;
if (hmd _unit == "") then
	{
	_needsRearm = true;
	_hasBox = false;
	_distancia = 50;
	{
	_victim = _x;
	_busy = _victim getVariable "busy";
	if ((hmd _victim != "") and (isNil "_busy")) then
		{
		_target = _victim;
		_hasBox = true;
		_distancia = _victim distance _unit;
		};
	} forEach _victims;

	if ((_hasBox) and (_unit getVariable "ASrearming")) then
		{
		_hasBox = false;
		_distancia = 50;
		{
		_victim = _x;
		_busy = _victim getVariable "busy";
		if ((hmd _victim != "") and (isNil "_busy")) then
			{
			_target = _victim;
			_hasBox = true;
			_distancia = _victim distance _unit;
			};
		} forEach _victims;
		if (_hasBox) then
			{
			_unit stop false;
			_target setVariable ["busy",true];
			_hmd = hmd _target;
			_unit doMove (getPosATL _target);
			_unit groupChat "Picking NV Googles";
			_timeOut = time + 60;
			waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
			if (_unit distance _target < 3) then
				{
				_unit action ["rearm",_target];
				_unit linkItem _hmd;
				_target unlinkItem _hmd;
				}
			else
				{
				_unit groupChat "Cannot pick those NV Googles";
				};
			_target setVariable ["busy",nil];
			_unit doFollow player;
			};
		};
	};
_hasBox = false;
if (not(headgear _unit in genHelmets)) then
	{
	_needsRearm = true;
	_hasBox = false;
	_distancia = 50;
	{
	_victim = _x;
	_busy = _victim getVariable "busy";
	if (((headgear _victim) in genHelmets) and (isNil "_busy")) then
		{
		_target = _victim;
		_hasBox = true;
		_distancia = _victim distance _unit;
		};
	} forEach _victims;
	if ((_hasBox) and (_unit getVariable "ASrearming")) then
		{
		_unit stop false;
		_target setVariable ["busy",true];
		_helmet = headgear _target;
		_unit doMove (getPosATL _target);
		_unit groupChat "Picking a Helmet";
		_timeOut = time + 60;
		waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if (_unit distance _target < 3) then
			{
			_unit action ["rearm",_target];
			_unit addHeadgear _helmet;
			removeHeadgear _target;
			}
		else
			{
			_unit groupChat "Cannot pick this Helmet";
			};
		_target setVariable ["busy",nil];
		_unit doFollow player;
		};
	};

if (!_needsRearm) then {_unit groupChat "No need to rearm"} else {_unit groupChat "Rearming Done"};
_unit setVariable ["ASrearming",false];