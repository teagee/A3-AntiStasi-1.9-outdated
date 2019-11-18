// Not working properly, check what's wrong
_unit = _this select 0;
_truckX = _this select 1;

if ((!alive _unit) or (isPlayer _unit) or (player != leader group player) or (captive _unit)) exitWith {};
if (lifestate _unit == "INCAPACITATED") exitWith {};
_medHelping = _unit getVariable "ASmedHelping";
if (!(isNil "_medHelping")) exitWith {_unit groupChat "I cannot rearm right now. I'm healing a comrade"};
_rearming = _unit getVariable "ASrearming";
if (_rearming) exitWith {_unit groupChat "I am currently rearming. Cancelling."; _unit setVariable ["ASrearming",false]};
if (_unit == gunner _truckX) exitWith {_unit groupChat "I cannot rearm right now. I'm manning this gun"};
if (!canMove _truckX) exitWith {_unit groupChat "It is useless to load my vehicle, as it needs repairs"};

_objectsX = [];
_hasBox = false;
_weaponX = "";
_weaponsX = [];
_bigTimeOut = time + 120;
_objectsX = nearestObjects [_unit, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 50];
if (count _objectsX == 0) exitWith {_unit groupChat "I see no corpses here to loot"};

_target = objNull;
_distancia = 51;
{
_objectX = _x;
if (_unit distance _objectX < _distancia) then
	{
	if ((count weaponCargo _objectX > 0) and !(_objectX getVariable ["busy",false])) then
		{
		_weaponsX = weaponCargo _objectX;
		for "_i" from 0 to (count _weaponsX - 1) do
			{
			_potential = _weaponsX select _i;
			_basePossible = [_potential] call BIS_fnc_baseWeapon;
			if ((not(_basePossible in unlockedWeapons)) and ((_basePossible in arifles) or (_basePossible in srifles) or (_basePossible in mguns) or (_potential in mlaunchers) or (_potential in rlaunchers))) then
				{
				_target = _objectX;
				_distancia = _unit distance _objectX;
				_weaponX = _potential;
				};
			};
		};
	};
} forEach _objectsX;

if (isNull _target) exitWith {_unit groupChat "There is nothing to loot"};
_target setVariable ["busy",true];
_unit setVariable ["ASrearming",true];
_unit groupChat "Starting looting";

_Pweapon = primaryWeapon _unit;
_Sweapon = secondaryWeapon _unit;

_unit action ["GetOut",_truckX];
[_unit] orderGetin false;
sleep 3;
if (_Pweapon != "") then {_unit action ["DropWeapon",_truckX,_Pweapon]; sleep 3};
if (_Sweapon != "") then {_unit action ["DropWeapon",_truckX,_Sweapon]};

_continuar = true;

while {_continuar and (alive _unit) and (!(lifestate _unit == "INCAPACITATED")) and (_unit getVariable "ASrearming") and (alive _truckX) and (_bigTimeout > time)} do
	{
	if (isNull _target) exitWith {_continuar = false};
	_target setVariable ["busy",true];
	_unit doMove (getPosATL _target);
	_timeOut = time + 60;
	waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
	if (_unit distance _target < 3) then
		{
		_unit action ["TakeWeapon",_target,_weaponX];
		sleep 3;
		};
	_target setVariable ["busy",false];
	_tempPrimary = primaryWeapon _unit;
	if (_tempPrimary != "") then
		{
		_magazines = getArray (configFile / "CfgWeapons" / _tempPrimary / "magazines");
		_victims = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
		_hasBox = false;
		_distancia = 51;
		{
		_victim = _x;
		if (({_x in _magazines} count (magazines _victim) > 0) and (_unit distance _victim < _distancia)) then
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
			_timeOut = time + 60;
			waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
			if (_unit distance _target < 3) then
				{
				_unit action ["rearm",_target];
				};
			_target setVariable ["busy",false];
			};
		};

	_unit doMove (getPosATL _truckX);
	_timeOut = time + 60;
	waitUntil {sleep 1; (!alive _unit) or (!alive _truckX) or (_unit distance _truckX < 8) or (_timeOut < time)};
	if ((alive _truckX) and (alive _unit)) then
		{
		if (_tempPrimary != "") then
			{
			_unit action ["DropWeapon",_truckX,_tempPrimary];
			sleep 3;
			};
		if (secondaryWeapon _unit != "") then
			{
			_unit action ["DropWeapon",_truckX,secondaryWeapon _unit];
			sleep 3;
			};
		};
	_target = objNull;
	_distancia = 51;
	{
	_objectX = _x;
	if (_unit distance _objectX < _distancia) then
		{
		if ((count weaponCargo _objectX > 0) and !(_objectX getVariable ["busy",false])) then
			{
			_weaponsX = weaponCargo _objectX;
			for "_i" from 0 to (count _weaponsX - 1) do
				{
				_potential = _weaponsX select _i;
				_basePossible = [_potential] call BIS_fnc_baseWeapon;
				if ((not(_basePossible in unlockedWeapons)) and ((_basePossible in arifles) or (_basePossible in srifles) or (_basePossible in mguns) or (_potential in mlaunchers) or (_potential in rlaunchers))) then
					{
					_target = _objectX;
					_distancia = _unit distance _objectX;
					_weaponX = _potential;
					};
				};
			};
		};
	} forEach _objectsX;
	};
if (!_continuar) then
	{
	_unit groupChat "No more weapons to loot"
	};
if (primaryWeapon _unit == "") then {_unit action ["TakeWeapon",_truckX,_Pweapon]; sleep 3};
if ((secondaryWeapon _unit == "") and (_Sweapon != "")) then {_unit action ["TakeWeapon",_truckX,_Sweapon]};
_unit doFollow player;
_unit setVariable ["ASrearming",false];
