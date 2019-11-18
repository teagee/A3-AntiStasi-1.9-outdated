private ["_roads","_pos","_positionX","_groupX"];

_markers = markers + [guer_respawn] - campsFIA;

_esHC = false;

if (count hcSelected player > 1) exitWith {hint localize "STR_HINTS_FTR_YCSOGOTFT"};
if (count hcSelected player == 1) then {_groupX = hcSelected player select 0; _esHC = true} else {_groupX = group player};

_boss = leader _groupX;

if ((_boss != player) and (!_esHC)) exitWith {hint localize "STR_HINTS_FTR_OAGLCAFFT"};

if (({isPlayer _x} count units _groupX > 1) and (!_esHC)) exitWith {hint localize "STR_HINTS_FTR_YCFTWOPIYG"};

if (player != player getVariable ["owner",player]) exitWith {hint localize "STR_HINTS_FTR_YCFTWYACAI"};

_checkX = false;
{_enemyX = _x;
{if (((side _enemyX == side_red) or (side _enemyX == side_green)) and (_enemyX distance _x < 500) and (not(captive _enemyX))) exitWith {_checkX = true}} forEach units _groupX;
if (_checkX) exitWith {};
} forEach allUnits;

if (_checkX) exitWith {Hint localize "STR_HINTS_FTR_YCFTWENTG"};

{if ((vehicle _x!= _x) and ((isNull (driver vehicle _x)) or (!canMove vehicle _x))) then
	{
	if (not(vehicle _x isKindOf "StaticWeapon")) then {_checkX = true};
	}
} forEach units _groupX;

if (_checkX) exitWith {Hint localize "STR_HINTS_FTR_YCFTIYDHADIAY"};

positionTel = [];

if (_esHC) then {hcShowBar false};
hint localize "STR_HINTS_FTR_COTZYWTT";
openMap true;
onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

_positionTel = positionTel;

if (count _positionTel > 0) then
	{
	_base = [_markers, _positionTel] call BIS_Fnc_nearestPosition;

	if (_base in mrkAAF) exitWith {hint localize "STR_HINTS_FTR_YCFTTAECZ"; openMap [false,false]};

	//experimental
	if (_base in campsFIA) exitWith {hint localize "STR_HINTS_FTR_YCFTTC"; openMap [false,false]};
	//if (_base in outpostsFIA) exitWith {hint localize "STR_HINTS_FTR_YCFTTRNW"; openMap [false,false]};

	{
		if (((side _x == side_red) or (side _x == side_green)) and (_x distance (getMarkerPos _base) < 500) and (not(captive _x))) then {_checkX = true};
	} forEach allUnits;

	if (_checkX) exitWith {Hint localize "STR_HINTS_FTR_YCFTTAAUAOWE"; openMap [false,false]};

	if (_positionTel distance getMarkerPos _base < 50) then
		{
		_positionX = [getMarkerPos _base, 10, random 360] call BIS_Fnc_relPos;
		_distancia = round (((position _boss) distance _positionX)/200);
		if (!_esHC) then {disableUserInput true; cutText ["Fast traveling, please wait","BLACK",2]; sleep 2;} else {hcShowBar false;hcShowBar true;hint format [localize "STR_HINTS_FTR_MG1TD",groupID _groupX]; sleep _distancia;};
		_forcedX = false;
		if (!isMultiplayer) then {if (not(_base in forcedSpawn)) then {_forcedX = true; forcedSpawn = forcedSpawn + [_base]}};
		if (!_esHC) then {sleep _distancia};
		{
		_unit = _x;
		//_unit hideObject true;
		_unit allowDamage false;
		if (_unit != vehicle _unit) then
			{
			if (driver vehicle _unit == _unit) then
				{
				sleep 3;
				_radiusX = 10;
				while {true} do
					{
					_roads = _positionX nearRoads _radiusX;
					if (count _roads < 1) then {_radiusX = _radiusX + 10};
					if (count _roads > 0) exitWith {};
					};
				_road = _roads select 0;
				_pos = position _road findEmptyPosition [1,50,typeOf (vehicle _unit)];
				vehicle _unit setPos _pos;
				};
			if ((vehicle _unit isKindOf "StaticWeapon") and (!isPlayer (leader _unit))) then
				{
				_pos = _positionX findEmptyPosition [1,50,typeOf (vehicle _unit)];
				vehicle _unit setPosATL _pos;
				};
			}
		else
			{
			if (!isNil {_unit getVariable "ASunconscious"}) then
				{
				if (!(_unit getVariable "ASunconscious")) then
					{
					_positionX = _positionX findEmptyPosition [1,50,typeOf _unit];
					_unit setPosATL _positionX;
					if (isPlayer leader _unit) then {_unit setVariable ["ASrearming",false]};
					_unit doWatch objNull;
					_unit doFollow leader _unit;
					};
				}
			else
				{
				_positionX = _positionX findEmptyPosition [1,50,typeOf _unit];
				_unit setPosATL _positionX;
				};
			};

		//_unit hideObject false;
		} forEach units _groupX;
		if (!_esHC) then {disableUserInput false;cutText ["You arrived to destination","BLACK IN",3]} else {hint format [localize "STR_HINTS_FTR_G1ATD",groupID _groupX]};
		if (_forcedX) then {forcedSpawn = forcedSpawn - [_base]};
		sleep 5;
		{_x allowDamage true} forEach units _groupX;
		}
	else
		{
		Hint localize "STR_HINTS_FTR_YMCNMUYC";
		};
	};
openMap false;