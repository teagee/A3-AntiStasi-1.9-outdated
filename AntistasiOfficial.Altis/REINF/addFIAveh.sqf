if (player != player getVariable ["owner",player]) exitWith {hint "You cannot buy vehicles while you are controlling AI"};

_checkX = false;
{
	if (((side _x == side_red) or (side _x == side_green)) and (_x distance player < safeDistance_recruit) and (not(captive _x))) then {_checkX = true};
} forEach allUnits;

if (_checkX) exitWith {Hint "You cannot buy vehicles with enemies nearby"};

private ["_typeVehX","_costs","_resourcesFIA","_markerX","_pos","_veh"];

_typeVehX = _this select 0;
_milveh = vfs select [3,10];
_milstatics = vfs select [7,4];

_costs = [_typeVehX] call vehiclePrice;

if (!isMultiPlayer) then {_resourcesFIA = server getVariable "resourcesFIA"} else
	{
	if (player != Slowhand) then
		{
		_resourcesFIA = player getVariable "moneyX";
		}
	else
		{
		if ((_typeVehX in _milveh) or (_typeVehX == civHeli)) then {_resourcesFIA = server getVariable "resourcesFIA"} else {_resourcesFIA = player getVariable "moneyX"};
		};
	};

if (_resourcesFIA < _costs) exitWith {hint format ["You do not have enough money for this vehicle: %1 € required",_costs]};
_pos = position player findEmptyPosition [10,50,_typeVehX];
if (count _pos == 0) exitWith {hint "Not enough space to place this type of vehicle"};
_veh = _typeVehX createVehicle _pos;
//If it's a quadbike, make it loadable with logistics script
if (_typeVehX == (vfs select 3)) then
{
	_veh call jn_fnc_logistics_addAction;
};
if (!isMultiplayer) then
	{
	[0,(-1* _costs)] remoteExec ["resourcesFIA", 2];
	}
else
	{
	if (player != Slowhand) then
		{
		[-1* _costs] call resourcesPlayer;
		_veh setVariable ["vehOwner",getPlayerUID player,true];
		}
	else
		{
		if ((_typeVehX in _milveh) or (_typeVehX == civHeli)) then
			{
			[0,(-1* _costs)] remoteExecCall ["resourcesFIA",2]
			}
		else
			{
			[-1* _costs] call resourcesPlayer;
			_veh setVariable ["vehOwner",getPlayerUID player,true];
			};
		};
	};
[_veh] spawn VEHinit;
if (_typeVehX in _milstatics) then {
	_veh addAction [localize "STR_ACT_MOVEASSET", {[_this select 0,_this select 1,_this select 2,"static"] spawn AS_fnc_moveObject},nil,0,false,true,"","(_this == Slowhand)"];
	[_veh, {_this setOwner 2; staticsToSave pushBackUnique _this; publicVariable "staticsToSave"}] remoteExec ["call", 2];
};
hint "Vehicle Purchased";
player reveal _veh;
petros directSay "SentGenBaseUnlockVehicle";