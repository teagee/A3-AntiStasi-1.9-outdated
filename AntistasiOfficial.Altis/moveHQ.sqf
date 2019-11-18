if (player != Slowhand) exitWith {hint localize "STR_HINTS_MHQ_OCSHATTF"};

//if ((count weaponCargo boxX >0) or (count magazineCargo boxX >0) or (count itemCargo boxX >0) or (count backpackCargo boxX >0)) exitWith {hint localize "STR_HINTS_MHQ_YMFEYAIOTMTHQ"};

hint localize "STR_HINTS_MHQ_MTAACNTVACNPTTNL";

petros enableAI "MOVE";
petros enableAI "AUTOTARGET";
petros forceSpeed -1;

[[petros,"remove"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
//removeAllActions petros;
//[true] remoteExecCall ["AS_fnc_togglePetrosAnim", 2];
[petros] join Slowhand;
petros setBehaviour "AWARE";
if (isMultiplayer) then
	{
	//boxX hideObjectGlobal true; //Redo it with Jeroen's crate loading script. Sparker
	//vehicleBox hideObjectGlobal true;
	mapX hideObjectGlobal true;
	fireX hideObjectGlobal true;
	flagX hideObjectGlobal true;
	}
else
	{
	//boxX hideObject true;
	//vehicleBox hideObject true;
	mapX hideObject true;
	fireX hideObject true;
	flagX hideObject true;
	};

fireX inflame false;

if (count (server getVariable ["obj_vehiclePad",[]]) > 0) then {
	[obj_vehiclePad, {deleteVehicle _this}] remoteExec ["call", 0];
	[obj_vehiclePad, {obj_vehiclePad = nil}] remoteExec ["call", 0];
	server setVariable ["AS_vehicleOrientation", 0, true];
	server setVariable ["obj_vehiclePad",[],true];
};

//guer_respawn setMarkerPos [0,0,0];
guer_respawn setMarkerAlpha 0;
_garrison = garrison getVariable ["FIA_HQ", []];
_positionX = getMarkerPos "FIA_HQ";
if (count _garrison > 0) then
	{
	_costs = 0;
	_hr = 0;
	if ({(alive _x) and (!captive _x) and ((side _x == side_green) or (side _x == side_red)) and (_x distance _positionX < 500)} count allUnits > 0) then
		{
		hint localize "STR_HINTS_MHQ_HQGWSHNHTE";
		}
	else
		{
		_size = ["FIA_HQ"] call sizeMarker;
		{
		if ((side _x == side_blue) and (not(_x getVariable ["BLUFORSpawn",false])) and (_x distance _positionX < _size) and (_x != petros)) then
			{
			if (!alive _x) then
				{
				if (typeOf _x in guer_soldierArray) then
					{
					if (typeOf _x == guer_sol_HMG) then {_costs = _costs - ([guer_stat_MGH] call vehiclePrice)};
					_hr = _hr - 1;
					_costs = _costs - (server getVariable (typeOf _x));
					};
				};
			if (typeOf (vehicle _x) == guer_stat_MGH) then {deleteVehicle vehicle _x};
			deleteVehicle _x;
			};
		} forEach allUnits;
		};
	{
	if (_x == guer_sol_HMG) then {_costs = _costs + ([guer_stat_MGH] call vehiclePrice)};
	_hr = _hr + 1;
	_costs = _costs + (server getVariable _x);
	} forEach _garrison;
	[_hr,_costs] remoteExec ["resourcesFIA",2];
	garrison setVariable ["FIA_HQ",[],true];
	hint format ["Garrison removed\n\nRecovered Money: %1 €\nRecovered HR: %2",_costs,_hr];
	};

sleep 5;

petros addAction [localize "STR_act_buildHQ", {[] spawn buildHQ},nil,0,false,true];

//Add actions to load the cargo boxes
boxX call jn_fnc_logistics_addAction;
vehicleBox call jn_fnc_logistics_addAction;
