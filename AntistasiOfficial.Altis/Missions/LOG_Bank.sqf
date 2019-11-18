if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_logBank";
_tskDesc = "STR_TSK_TD_DESC_logBank";

_banco = _this select 0;

_positionX = getPos _banco;
_markerX = [citiesX,_positionX] call BIS_fnc_nearestPosition;
_posbase = getMarkerPos guer_respawn;

_timeLimit = 120;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_cityX = [citiesX, _positionX] call BIS_fnc_nearestPosition;
_mrkFinal = createMarker [format ["LOG%1", random 100], _positionX];
_nameDest = [_cityX] call AS_fnc_localizar;
_mrkFinal setMarkerShape "ICON";

_pos = (getMarkerPos guer_respawn) findEmptyPosition [1,50,AS_misVehicleBox];

_truckX = AS_misVehicleBox createVehicle _pos;
_truckX allowDamage false;
[_truckX] spawn {sleep 1; (_this select 0) allowDamage true;};


{_x reveal _truckX} forEach (allPlayers - (entities "HeadlessClient_F"));
[_truckX] spawn vehInit;
_truckX setVariable ["destinationX",_nameDest,true];
_truckX addEventHandler ["GetIn",
	{
	if (_this select 1 == "driver") then
		{
		_textX = format ["Bring this truck to %1 Bank and park it in the main entrance",(_this select 0) getVariable "destinationX"];
		_textX remoteExecCall ["hint",_this select 2];
		};
	}];

[_truckX,"Mission Vehicle"] spawn inmuneConvoy;

_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkFinal],_positionX,"CREATED",5,true,true,"Interact"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
_mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], _positionX];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [30,30];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_mrk setMarkerAlphaLocal 0;

_typeGroup = [infSquad, side_green] call AS_fnc_pickGroup;
_groupX = [_positionX, side_green, _typeGroup] call BIS_Fnc_spawnGroup;
sleep 1;
[_groupX, _mrk, "SAFE","SPAWNED", "NOVEH2", "FORTIFY"] execVM "scripts\UPSMON.sqf";
{[_x] spawn genInitBASES} forEach units _groupX;

_positionX = _banco buildingPos 1;

waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or (!alive _truckX) or (_truckX distance _positionX < 7)};

if ((dateToNumber date > _dateLimitNum) or (!alive _truckX)) then
	{
	_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkFinal],_positionX,"FAILED",5,true,true,"Interact"] call BIS_fnc_setTask;
	_resourcesAAF = server getVariable "resourcesAAF";
	_resourcesAAF = _resourcesAAF + 5000;
	server setVariable ["resourcesAAF",_resourcesAAF,true];
	[-1800] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	}
else
	{
	_countX = 120;//120
	[_positionX] remoteExec ["patrolCA", call AS_fnc_getNextWorker];
	[10,-20,_markerX] remoteExec ["AS_fnc_changeCitySupport",2];
	{_friendX = _x;
	if (_friendX distance _truckX < 300) then
		{
		if ((captive _friendX) and (isPlayer _friendX)) then {[player,false] remoteExec ["setCaptive",_friendX]};
		{if (side _x == side_green) then {_x reveal [_friendX,4]};
		} forEach allUnits;
		};
	} forEach ([distanceSPWN,0,_positionX,"BLUFORSpawn"] call distanceUnits);
	while {(_countX > 0) or (_truckX distance _positionX < 7) and (alive _truckX) and (dateToNumber date < _dateLimitNum)} do
		{
		while {(_countX > 0) and (_truckX distance _positionX < 7) and (alive _truckX)} do
			{
			_formatX = format ["%1", _countX];
			{if (isPlayer _x) then {[petros,"countdown",_formatX] remoteExec ["commsMP",_x]}} forEach ([80,0,_truckX,"BLUFORSpawn"] call distanceUnits);
			sleep 1;
			_countX = _countX - 1;
			};
		if (_countX > 0) then
			{
			_countX = 120;//120
			if (_truckX distance _positionX > 6) then {[[petros,"hint","Don't get the truck far from the bank or count will restart"],"commsMP"] call BIS_fnc_MP};
			waitUntil {sleep 1; (!alive _truckX) or (_truckX distance _positionX < 7) or (dateToNumber date < _dateLimitNum)};
			}
		else
			{
			if (alive _truckX) then
				{
				{if (isPlayer _x) then {[petros,"hint","Drive the Truck back to base to finish this mission"] remoteExec ["commsMP",_x]}} forEach ([80,0,_truckX,"BLUFORSpawn"] call distanceUnits);
				};
			};
		};
	};


waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or (!alive _truckX) or (_truckX distance _posbase < 50)};
if ((_truckX distance _posbase < 50) and (dateToNumber date < _dateLimitNum)) then
	{
	_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkFinal],_positionX,"SUCCEEDED",5,true,true,"Interact"] call BIS_fnc_setTask;
	[0,5000] remoteExec ["resourcesFIA",2];
	[-20,0] remoteExec ["prestige",2];
	[1800] remoteExec ["AS_fnc_increaseAttackTimer",2];
	{if (_x distance _truckX < 500) then {[10,_x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
	[5,Slowhand] call playerScoreAdd;
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
	};
if (!alive _truckX) then
	{
	_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4, A3_Str_INDEP],_tskTitle,_mrkFinal],_positionX,"FAILED",5,true,true,"Interact"] call BIS_fnc_setTask;
	[1800] remoteExec ["AS_fnc_increaseAttackTimer",2];
	[-10,Slowhand] call playerScoreAdd;
	};

waitUntil {sleep 1; speed _truckX == 0};

[_truckX] call emptyX;
deleteVehicle _truckX;

[1200,_tsk] spawn deleteTaskX;

waitUntil {sleep 1; !([distanceSPWN,1,_positionX,"BLUFORSpawn"] call distanceUnits)};

{deleteVehicle _x} forEach units _groupX;
deleteGroup _groupX;

deleteMarker _mrk;
deleteMarker _mrkFinal;
