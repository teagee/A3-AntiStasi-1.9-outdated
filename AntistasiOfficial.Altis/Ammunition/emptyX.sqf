private ["_trucksX","_truckX","_weaponsX","_ammunition","_items","_backpcks","_containers","_todo"];

_truckX = objNull;

if (count _this > 0) then
	{
	_truckX = _this select 0;
	if (_truckX isKindOf "StaticWeapon") then {_truckX = objNull};
	}
else
	{
	//_trucksX = nearestObjects [boxX, ["LandVehicle"], 20];
	_trucksX = nearestObjects [boxX, ["LandVehicle", "ReammoBox_F", "Box_IED_Exp_F", "Land_PlasticCase_01_medium_F", "Box_Syndicate_Wps_F"], 20]; //To enable jeroen's loading script. Sparker.
	_trucksX = _trucksX select {not (_x isKindOf "StaticWeapon")};
	_trucksX = _trucksX - [boxX];
	_trucksX = _trucksX - [vehicleBox]; //To enable jeroen's unloading script. Sparker.
	if (count _trucksX < 1) then {_truckX = vehicleBox} else {_truckX = _trucksX select 0};
	};

if (isNull _truckX) exitWith {};


if (server getVariable ["lockTransfer",false]) exitWith {
	if (isMultiplayer) then {
		{if (_x distance boxX < 20) then {
			[petros,"hint","Currently unloading another ammobox. Please wait a few seconds."] remoteExec ["commsMP",_x];
		};
		} forEach playableUnits;
	}
	else {
		hint "Unloading ammobox..."
	};
};


_weaponsX = weaponCargo _truckX;
_ammunition = magazineCargo _truckX;
_items = itemCargo _truckX;
_backpcks = backpackCargo _truckX;

_todo = _weaponsX + _ammunition + _items + _backpcks;

if (count _todo < 1) exitWith
	{
	if (count _this == 0) then {hint "Closest vehicle cargo is empty"};
	if (count _this == 2) then {
		if (count (nearestObjects [getPos fireX, ["AllVehicles"], 50]) > 0) then {
			{[[_x,player], SA_Put_Away_Tow_Ropes] remoteExec ["call", 0];} forEach nearestObjects [getPos fireX, ["AllVehicles"], 50];
		};
		deleteVehicle _truckX};
	};

server setVariable ["lockTransfer", true, true];
if (isMultiplayer) then {{if (_x distance boxX < 20) then {[petros,"hint","Unloading ammobox..."] remoteExec ["commsMP",_x]}} forEach playableUnits} else {hint "Unloading ammobox..."};
if (count _this == 2) then {[_truckX,boxX,true] remoteExec ["AS_fnc_transferGear",2]} else {[_truckX,boxX] remoteExec ["AS_fnc_transferGear",2]};
[] spawn {
	sleep 5;
	server setVariable ["lockTransfer", false, true];
};
