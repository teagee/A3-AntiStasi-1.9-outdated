private ["_staticX","_nearX","_playerX"];

_staticX = _this select 0;
_playerX = _this select 1;

if (!alive _staticX) exitWith {hint "You cannot steal a destroyed static weapon"};

if (alive gunner _staticX) exitWith {hint "You cannot steal a static weapon when someone is using it"};

if ((alive assignedGunner _staticX) and (!isPlayer (assignedGunner _staticX))) exitWith {hint "The gunner of this static weapon is still alive"};

_nearX = [markers,_staticX] call BIS_fnc_nearestPosition;

if (_nearX in mrkAAF) exitWith {hint "You have to conquer this zone in order to be able to steal this Static Weapon"};

_staticX setOwner (owner _playerX);

_typeStaticX = typeOf _staticX;
_typeB1 = "";
_typeB2 = "";

switch _typeStaticX do {
	case statMG: {
		_typeB1 = statMGBackpacks select 0;
		_typeB2 = statMGBackpacks select 1;
	};
	case statAA: {
		_typeB1 = statAABackpacks select 0;
		_typeB2 = statAABackpacks select 1;
	};
	case statAT: {
		_typeB1 = statATBackpacks select 0;
		_typeB2 = statATBackpacks select 1;
	};
	case statMortar: {
		_typeB1 = statMortarBackpacks select 0;
		_typeB2 = statMortarBackpacks select 1;
	};
	case statMGlow: {
		_typeB1 = statMGlowBackpacks select 0;
		_typeB2 = statMGlowBackpacks select 1;
	};
	case statMGtower: {
		_typeB1 = statMGtowerBackpacks select 0;
		_typeB2 = statMGtowerBackpacks select 1;
	};
	default {hint "You cannot steal this weapon."};
	};

_positionX1 = [_playerX, 1, (getDir _playerX) - 90] call BIS_fnc_relPos;
_positionX2 = [_playerX, 1, (getDir _playerX) + 90] call BIS_fnc_relPos;

deleteVehicle _staticX;

if (_typeB1 == "") exitWith {};

_bag1 = _typeB1 createVehicle _positionX1;
_bag2 = _typeB2 createVehicle _positionX2;

[_bag1] spawn VEHinit;
[_bag2] spawn VEHinit;