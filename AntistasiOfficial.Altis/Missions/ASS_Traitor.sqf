if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_ASSTraitor";
_tskDesc = "STR_TSK_TD_DESC_ASSTraitor";

_initialMarker = _this select 0;
_source = _this select 1;

_initialPosition = getMarkerPos _initialMarker;

_timeLimit = 60;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_radiusX = [_initialMarker] call sizeMarker;
_houses = nearestObjects [_initialPosition, ["house"], _radiusX];
_housePosition = [];
_house = _houses select 0;
while {count _housePosition < 3} do
	{
	_house = _houses call BIS_Fnc_selectRandom;
	_housePosition = [_house] call BIS_fnc_buildingPositions;
	if (count _housePosition < 3) then {_houses = _houses - [_house]};
	};

_max = (count _housePosition) - 1;
_rnd = floor random _max;
_traitorPosition = _housePosition select _rnd;
_posSol1 = _housePosition select (_rnd + 1);
_posSol2 = (_house buildingExit 0);

_nameDest = [_initialMarker] call AS_fnc_localizar;

_traitorGroup = createGroup side_red;

_arraybases = bases - mrkFIA;
_base = [_arraybases, _initialPosition] call BIS_Fnc_nearestPosition;
_posBase = getMarkerPos _base;

_traitor = ([_traitorPosition, 0, opI_OFF2, _traitorGroup] call bis_fnc_spawnvehicle) select 0;
_traitor setVariable ["VCOM_NOAI", true, true]; //No VCOM AI for traitor
[_traitor] spawn {
	params ["_subject"];
	_subject allowDamage false;
	sleep 15;
	_subject allowDamage true;
};

_sol1 = ([_posSol1, 0, opI_SL, _traitorGroup] call bis_fnc_spawnvehicle) select 0;
_sol2 = ([_posSol2, 0, opI_RFL1, _traitorGroup] call bis_fnc_spawnvehicle) select 0;
_traitorGroup selectLeader _traitor;

_posTsk = (position _house) getPos [random 100, random 360];

_spawnData = [_traitorPosition, _posBase] call AS_fnc_findRoadspot;
if (count _spawnData < 1) exitWith {diag_log format ["Error in traitor: no suitable roads found near %1",_initialMarker]};
_roadPos = _spawnData select 0;
_roadDir = _spawnData select 1;

if (_source == "civ") then {
	_val = server getVariable "civActive";
	server setVariable ["civActive", _val + 1, true];
};

_tsk = ["ASS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_initialMarker],_posTsk,"CREATED",5,true,true,"Kill"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";

{[_x] spawn CSATinit; _x allowFleeing 0} forEach units _traitorGroup;

_posVeh = [_roadPos, 3, _roadDir + 90] call BIS_Fnc_relPos;

_veh = opMRAPu createVehicle _posVeh;
_veh allowDamage false;
_veh setDir _roadDir;
sleep 15;
_veh allowDamage true;
[_veh] spawn genVEHinit;
{_x disableAI "MOVE"; _x setUnitPos "UP"} forEach units _traitorGroup;

_mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], getPos _house];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [50,50];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_mrk setMarkerAlphaLocal 0;

_typeGroup = [infSquad, side_green] call AS_fnc_pickGroup;
_groupX = [_initialPosition, side_green, _typeGroup] call BIS_Fnc_spawnGroup;
sleep 1;
if (random 10 < 2.5) then
	{
	_doggo = _groupX createUnit ["Fin_random_F",_initialPosition,[],0,"FORM"];
	[_doggo] spawn guardDog;
	};
[_groupX, _mrk, "SAFE","SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";
{[_x] spawn genInitBASES} forEach units _groupX;

waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or (not alive _traitor) or ({_traitor knowsAbout _x > 1.4} count ([500,0,_traitor,"BLUFORSpawn"] call distanceUnits) > 0)};

if ({_traitor knowsAbout _x > 1.4} count ([500,0,_traitor,"BLUFORSpawn"] call distanceUnits) > 0) then
	{
	//hint "You have been discovered. The traitor is fleeing to the nearest base. Go and kill him!";
	_tsk = ["ASS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_initialMarker],_traitor,"CREATED",5,true,true,"Kill"] call BIS_fnc_setTask;
	{_x enableAI "MOVE"} forEach units _traitorGroup;
	_traitor assignAsDriver _veh;
	[_traitor] orderGetin true;
	_wp0 = _traitorGroup addWaypoint [_posVeh, 0];
	_wp0 setWaypointType "GETIN";
	_wp1 = _traitorGroup addWaypoint [_posBase,1];
	_wp1 setWaypointType "MOVE";
	_wp1 setWaypointBehaviour "CARELESS";
	_wp1 setWaypointSpeed "FULL";
	};

waitUntil  {sleep 1; (dateToNumber date > _dateLimitNum) or (not alive _traitor) or (_traitor distance _posBase < 50)};

if (not alive _traitor) then
	{
	_tsk = ["ASS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_initialMarker],_traitor,"SUCCEEDED",5,true,true,"Kill"] call BIS_fnc_setTask;
	[0,0] remoteExec ["prestige",2];
	[0,300] remoteExec ["resourcesFIA",2];
	{
	if (!isPlayer _x) then
		{
		_skill = skill _x;
		_skill = _skill + 0.1;
		_x setSkill _skill;
		}
	else
		{
		[10,_x] call playerScoreAdd;
		};
	} forEach ([_radiusX,0,_initialPosition,"BLUFORSpawn"] call distanceUnits);
	[5,Slowhand] call playerScoreAdd;
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
	}
else
	{
	_tsk = ["ASS",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_initialMarker],_traitor,"FAILED",5,true,true,"Kill"] call BIS_fnc_setTask;
	[-10,Slowhand] call playerScoreAdd;
	if (dateToNumber date > _dateLimitNum) then
		{
		_hrT = server getVariable "hr";
		_resourcesFIAT = server getVariable "resourcesFIA";
		[-1*(round(_hrT/3)),-1*(round(_resourcesFIAT/3))] remoteExec ["resourcesFIA",2];
		}
	else
		{
		if (isPlayer Slowhand) then
			{
			if (!("DEF_HQ" in missionsX)) then
				{
				[] remoteExec ["attackHQ", call AS_fnc_getNextWorker];
				};
			}
		else
			{
			_minesFIA = allmines - (detectedMines side_red);
			if (count _minesFIA > 0) then
				{
				{if (random 100 < 30) then {side_red revealMine _x;}} forEach _minesFIA;
				};
			};
		};
	};

[5400,_tsk] spawn deleteTaskX;

if (_source == "civ") then {
	_val = server getVariable "civActive";
	server setVariable ["civActive", _val - 1, true];
};

waitUntil {sleep 1; !([distanceSPWN,1,_veh,"BLUFORSpawn"] call distanceUnits)};

{
waitUntil {sleep 1; !([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)};
deleteVehicle _x
} forEach units _traitorGroup;
deleteGroup _traitorGroup;

{
waitUntil {sleep 1; !([distanceSPWN,1,_x,"BLUFORSpawn"] call distanceUnits)};
deleteVehicle _x
} forEach units _groupX;
deleteGroup _groupX;

waitUntil {sleep 1; !([distanceSPWN,1,_veh,"BLUFORSpawn"] call distanceUnits)};
deleteVehicle _veh;
