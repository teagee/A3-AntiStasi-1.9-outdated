if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_HQATTACK";
_tskDesc = "STR_TSK_TD_DESC_HQATTACK";

_positionX = getMarkerPos guer_respawn;

_pilots = [];
_vehiclesX = [];
_groups = [];
_soldiers = [];

if (server getVariable "blockCSAT") exitWith {};

if ({(_x distance _positionX < 500) and ((typeOf _x == guer_stat_AA) or (typeOf _x == statAA))} count staticsToSave > 4) exitWith {};

_tsk = ["DEF_HQ",[side_blue,civilian],[_tskDesc,_tskTitle,guer_respawn],_positionX,"CREATED",5,true,true,"Defend"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";

_pos = [_positionX, distanceSPWN * 3, random 360] call BIS_Fnc_relPos;
_vehicle=[_pos, 0, opGunship, side_red] call bis_fnc_spawnvehicle;
_heli = _vehicle select 0;
_heliCrew = _vehicle select 1;
_groupHeli = _vehicle select 2;
_pilots = _pilots + _heliCrew;
_groups = _groups + [_groupHeli];
_vehiclesX = _vehiclesX + [_heli];
[_heli] spawn CSATVEHinit;
{[_x] spawn CSATinit} forEach _heliCrew;
_wp1 = _groupHeli addWaypoint [_positionX, 0];
_wp1 setWaypointType "SAD";
[_heli,"CSAT Air Attack"] spawn inmuneConvoy;
sleep 30;

for "_i" from 0 to (round random 2) do
	{
	_pos = [_positionX, distanceSPWN * 3, random 360] call BIS_Fnc_relPos;
	_vehicle=[_pos, 0, opHeliFR, side_red] call bis_fnc_spawnvehicle;
	_heli = _vehicle select 0;
	_heliCrew = _vehicle select 1;
	_groupHeli = _vehicle select 2;
	_pilots = _pilots + _heliCrew;
	_groups = _groups + [_groupHeli];
	_vehiclesX = _vehiclesX + [_heli];

	{_x setBehaviour "CARELESS";} forEach units _groupHeli;
	_typeGroup = [opGroup_SpecOps, side_red] call AS_fnc_pickGroup;
	_groupX = [_pos, side_red, _typeGroup] call BIS_Fnc_spawnGroup;
	{_x assignAsCargo _heli; _x moveInCargo _heli; _soldiers = _soldiers + [_x]; [_x] spawn CSATinit} forEach units _groupX;
	_groups = _groups + [_groupX];
	[_heli,"CSAT Air Transport"] spawn inmuneConvoy;
	[_heli,_groupX,_positionX,_pos,_groupHeli] spawn fastropeCSAT;
	sleep 10;
	};

waitUntil {sleep 1;({not (captive _x)} count _soldiers < {captive _x} count _soldiers) or ({alive _x} count _soldiers < {fleeing _x} count _soldiers) or ({alive _x} count _soldiers == 0) or (_positionX distance getMarkerPos guer_respawn > 999) or !(alive petros)};

call {
	if !(alive petros) exitWith {
		_tsk = ["DEF_HQ",[side_blue,civilian],[_tskDesc,_tskTitle,guer_respawn],_positionX,"FAILED",5,true,true,"Defend"] call BIS_fnc_setTask;
	};

	if (_positionX distance getMarkerPos guer_respawn > 999) exitWith {
		_tsk = ["DEF_HQ",[side_blue,civilian],[_tskDesc,_tskTitle,guer_respawn],_positionX,"SUCCEEDED",5,true,true,"Defend"] call BIS_fnc_setTask;
	};

	_tsk = ["DEF_HQ",[side_blue,civilian],[_tskDesc,_tskTitle,guer_respawn],_positionX,"SUCCEEDED",5,true,true,"Defend"] call BIS_fnc_setTask;
	[0,0] remoteExec ["prestige",2];
	[0,300] remoteExec ["resourcesFIA",2];
	{if (isPlayer _x) then {[10,_x] call playerScoreAdd}} forEach ([500,0,_positionX,"BLUFORSpawn"] call distanceUnits);
};


[1200,_tsk] spawn deleteTaskX;
{
waitUntil {sleep 1; !([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)};
deleteVehicle _x;
} forEach _soldiers;
{
waitUntil {sleep 1; !([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)};
deleteVehicle _x;
} forEach _pilots;
{
if (!([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)) then {deleteVehicle _x};
} forEach _vehiclesX;
{deleteGroup _x} forEach _groups;