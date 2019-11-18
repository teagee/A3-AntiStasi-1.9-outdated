if (!isServer and hasInterface) exitWith{};

_tskTitle = "STR_TSK_TD_NATOSupply";
_tskDesc = "STR_TSK_TD_DESC_NATOSupply";

_positionX = _this select 0;
_NATOSupp = _this select 1;

private ["_crate","_chute","_smokeX"];

_mrkFinal = createMarker ["AmmoSupp", _positionX];
_mrkFinal setMarkerShape "ICON";
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + 60];
_dateLimitNum = dateToNumber _dateLimit;

_tsk = ["NATOAmmo",[side_blue,civilian],[[_tskDesc, A3_Str_BLUE],[_tskTitle, A3_Str_BLUE],_mrkFinal],_positionX,"CREATED",5,true,true,"rifle"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
[-5,0] remoteExec ["prestige",2];

_airportsX = airportsX - mrkAAF + ["spawnNATO"];

_originX = [_airportsX,_positionX] call BIS_fnc_nearestPosition;
_orig = getMarkerPos _originX;
_vehiclesX = [];

_helifn = [_orig, 0, selectRandom bluHeliDis, side_blue] call bis_fnc_spawnvehicle;
_heli = _helifn select 0;
_heli setVariable ["BLUFORSpawn",false];
_heliCrew = _helifn select 1;
_groupHeli = _helifn select 2;
{[_x] spawn NATOinitCA} forEach _heliCrew;
//[_heli] spawn NATOVEHinit; //This was causing the _heli to automatically despawn as it appeared, so I commented it out. Not very important for this helicopter anyway. Sparker.
_vehiclesX = _vehiclesX + [_heli];
_heli setPosATL [getPosATL _heli select 0, getPosATL _heli select 1, 1000];
_heli disableAI "TARGET";
_heli disableAI "AUTOTARGET";
_heli flyInHeight 200;
_groupHeli setCombatMode "BLUE";

Slowhand hcSetGroup [_groupHeli];
_groupHeli setVariable ["isHCgroup", true, true];

waitUntil {sleep 2; (_heli distance _positionX < 300) or (!canMove _heli) or (dateToNumber date > _dateLimitNum)};

Slowhand hcRemoveGroup _groupHeli;

if (_heli distance _positionX < 300) then {
	_chute = createVehicle ["B_Parachute_02_F", [100, 100, 200], [], 0, 'FLY'];
    _chute setPos [getPosASL _heli select 0, getPosASL _heli select 1, (getPosASL _heli select 2) - 50];
    _crate = createVehicle ["B_supplyCrate_F", position _chute, [], 0, 'NONE'];
    if (activeACE) then {_crate setVariable ["ace_cookoff_enable", false, true]};
    _crate allowDamage false;
    _crate attachTo [_chute, [0, 0, -1.3]];
    [_crate,_NATOSupp] call NATOCrate;
     _vehiclesX = _vehiclesX + [_chute,_crate];
    _wp3 = _groupHeli addWaypoint [_orig, 0];
	_wp3 setWaypointType "MOVE";
	_wp3 setWaypointSpeed "FULL";
    waitUntil {position _crate select 2 < 0.5 || isNull _chute};
    detach _crate;
    private _pos = getPos _crate;
    _pos set [2, 0.5];
    _crate setPos _pos;
    _tsk = ["NATOAmmo",[side_blue,civilian],[[_tskDesc, A3_Str_BLUE],[_tskTitle, A3_Str_BLUE],_mrkFinal],_positionX,"SUCCEEDED",5,true,true,"rifle"] call BIS_fnc_setTask;
	_smokeX = "SmokeShellBlue" createVehicle position _crate;
	_vehiclesX = _vehiclesX + [_smokeX];
} else {
	_tsk = ["NATOAmmo",[side_blue,civilian],[[_tskDesc, A3_Str_BLUE],[_tskTitle, A3_Str_BLUE],_mrkFinal],_positionX,"FAILED",5,true,true,"rifle"] call BIS_fnc_setTask;
};

sleep 15;

deleteMarker _mrkFinal;

[300,_tsk] spawn deleteTaskX;
{
_soldierX = _x;
waitUntil {sleep 1; {_x distance _soldierX < distanceSPWN} count (allPlayers - (entities "HeadlessClient_F")) == 0};
deleteVehicle _soldierX;
} forEach _heliCrew;
deleteGroup _groupHeli;
{_vehiculo = _x;
waitUntil {sleep 1; {_x distance _vehiculo < distanceSPWN} count (allPlayers - (entities "HeadlessClient_F")) == 0};
deleteVehicle _vehiculo;
} forEach _vehiclesX;
