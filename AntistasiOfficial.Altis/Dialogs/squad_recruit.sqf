private ["_display","_childControl","_costs","_costHR","_unitsX","_formatX"];
if (!([player] call hasRadio)) exitWith {hint "You need a radio in your inventory to be able to give orders to other squads"};
createDialog "squad_recruit";

sleep 1;
disableSerialization;

_display = findDisplay 100;

if (str (_display) != "no display") then
{
	_ChildControl = _display displayCtrl 104;
	_costs = 0;
	_costHR = 0;
	_typeGroup = guer_grp_squad;
	_formatX = ([guer_grp_squad, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach _typeGroup;
	_ChildControl  ctrlSetTooltip format ["Cost: %1 €. HR: %2",_costs,_costHR];

	_ChildControl = _display displayCtrl 105;
	_costs = 0;
	_costHR = 0;
	_typeGroup = guer_grp_team;
	_formatX = ([guer_grp_team, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach _typeGroup;
	_ChildControl  ctrlSetTooltip format ["Cost: %1 €. HR: %2",_costs,_costHR];

	_ChildControl = _display displayCtrl 106;
	_costs = 0;
	_costHR = 0;
	_typeGroup = guer_grp_AT;
	_formatX = ([guer_grp_AT, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach _typeGroup;
	_ChildControl  ctrlSetTooltip format ["Cost: %1 €. HR: %2",_costs,_costHR];

	_ChildControl = _display displayCtrl 107;
	_costs = 0;
	_costHR = 0;
	_typeGroup = guer_grp_sniper;
	_formatX = ([guer_grp_sniper, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach _typeGroup;
	_ChildControl  ctrlSetTooltip format ["Cost: %1 €. HR: %2",_costs,_costHR];

	_ChildControl = _display displayCtrl 108;
	_costs = 0;
	_costHR = 0;
	_typeGroup = guer_grp_sentry;
	_formatX = ([guer_grp_sentry, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach _typeGroup;
	_ChildControl  ctrlSetTooltip format ["Cost: %1 €. HR: %2",_costs,_costHR];


	_ChildControl = _display displayCtrl 109;
	_costs = (2*(server getVariable guer_sol_R_L));
	_costHR = 2;
	_costs = _costs + ([guer_veh_truck] call vehiclePrice) + ([guer_stat_AT] call vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1 €. HR: %2",_costs,_costHR];

	_ChildControl = _display displayCtrl 110;
	_costs = (2*(server getVariable guer_sol_R_L));
	_costHR = 2;
	_costs = _costs + ([guer_veh_truck] call vehiclePrice) + ([guer_stat_AA] call vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1 €. HR: %2",_costs,_costHR];

	_ChildControl = _display displayCtrl 111;
	_costs = (2*(server getVariable guer_sol_R_L));
	_costHR = 2;
	_costs = _costs + ([guer_veh_truck] call vehiclePrice) + ([guer_stat_mortar] call vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1 €. HR: %2",_costs,_costHR];
};