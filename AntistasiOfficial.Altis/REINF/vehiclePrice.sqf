private ["_typeX","_costs"];

_typeX = _this select 0;

if (isNil {_typeX}) exitWith {};

_costs = server getVariable [_typeX,0];

if (_costs == 0) then {
	call {
		if ((_typeX in vehTrucks) or (_typeX in vehPatrol) or (_typeX in vehSupply)) exitWith {_costs = 300};
		if (_typeX in vehAPC) exitWith {_costs = 1000};
		if (_typeX in vehIFV) exitWith {_costs = 2000};
		if (_typeX in vehTank) exitWith {_costs = 5000};
		if (_typeX == "C_Van_01_fuel_F") exitWith {_costs = 50};
		if (_typeX in CIV_vehicles) exitWith {_costs = 25};
		if (_typeX in guer_vehicleArray) exitWith {_costs = 200};

		_costs = 0;
		diag_log format ["Antistasi: Error en vehicle prize con este: %1",_typeX];
		};
	}
else
	{
	//_costs = _costs + (_costs * ({_x in mrkAAF} count seaports));
	_costs = round (_costs - (_costs * (0.1 * ({_x in mrkFIA} count seaports))));
	};

_costs