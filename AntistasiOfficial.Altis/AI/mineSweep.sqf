if (!isServer and hasInterface) exitWith {};

private ["_costs","_groupX","_unit","_minesX","_radiusX","_roads","_truckX","_mineX"];

_costs = (server getVariable guer_sol_EXP) + ([guer_veh_engineer] call vehiclePrice);

[-1,-1*_costs] remoteExec ["resourcesFIA",2];

_groupX = createGroup side_blue;

_unit = _groupX createUnit [guer_sol_EXP, getMarkerPos guer_respawn, [], 0, "NONE"];
_groupX setGroupId ["MineSw"];
_minesX = [];
sleep 1;
_radiusX = 10;
while {true} do
	{
	_roads = getMarkerPos guer_respawn nearRoads _radiusX;
	if (count _roads < 1) then {_radiusX = _radiusX + 10};
	if (count _roads > 0) exitWith {};
	};
_road = _roads select 0;
_pos = position _road findEmptyPosition [1,30,guer_veh_truck];

_truckX = guer_veh_engineer createVehicle _pos;

[_truckX] spawn VEHinit;
[_unit] spawn AS_fnc_initialiseFIAUnit;
_groupX addVehicle _truckX;
_truckX setVariable ["owner",_groupX,true];
_unit assignAsDriver _truckX;
[_unit] orderGetIn true;
//_unit setBehaviour "SAFE";
Slowhand hcSetGroup [_groupX];
_groupX setVariable ["isHCgroup", true, true];

while {alive _unit} do
	{
	waitUntil {sleep 1;(!alive _unit) or (unitReady _unit)};
	if (alive _unit) then
		{
		if (alive _truckX) then
			{
			if ((count magazineCargo _truckX > 0) and (_unit distance (getMarkerPos guer_respawn) < 50)) then
				{
				[_truckX,boxX] remoteExec ["AS_fnc_transferGear",2];
				sleep 30;
				};
			};
		_minesX = (detectedMines side_blue) select {(_x distance _unit) < 100};
		if (count _minesX == 0) then
			{
			waitUntil {sleep 1;(!alive _unit) or (!unitReady _unit)};
			}
		else
			{
			moveOut _unit;
			[_unit] orderGetin false;
			_minesX = [_minesX,[],{_unit distance _x},"ASCEND"] call BIS_fnc_sortBy;
			_countX = 0;
			_total = count _minesX;
			while {(alive _unit) and (_countX < _total)} do
				{
				_mineX = _minesX select _countX;
				_unit doMove position _mineX;
				_timeOut = time + 120;
				waitUntil {sleep 0.5; (_unit distance _mineX < 8) or (!alive _unit) or (time > _timeOut)};
				if (alive _unit) then
					{
					_unit action ["Deactivate",_unit,_mineX];
					//_unit action ["deactivateMine", _unit];
					sleep 3;
					_toDelete = nearestObjects [position _unit, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 9];
					if (count _toDelete > 0) then
						{
						_wh = _toDelete select 0;
						if (alive _truckX) then {_truckX addMagazineCargoGlobal [((magazineCargo _wh) select 0),1]};
						deleteVehicle _mineX;
						deleteVehicle _wh;
						};
					_countX = _countX + 1;
					};
				};
			[_unit] orderGetIn true;
			};
		};
	sleep 1;
	};