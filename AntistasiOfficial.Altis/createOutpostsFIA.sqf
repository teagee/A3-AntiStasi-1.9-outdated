if (!isServer) exitWith {};

private ["_typeX","_costs","_groupX","_unit","_radiusX","_roads","_road","_pos","_truckX","_textX","_mrk","_hr","_unitsX","_formatX"];

_typeX = _this select 0;
_positionTel = _this select 1;

if (_typeX == "delete") exitWith {
	_mrk = [outpostsFIA,_positionTel] call BIS_fnc_nearestPosition;
	_pos = getMarkerPos _mrk;
	hint format ["Deleting %1",markerText _mrk];
	_costs = 0;
	_hr = 0;
	_typeGroup = guer_grp_sniper;
	if (markerText _mrk != "FIA Observation Post") then
		{
		_typeGroup = guer_grp_AT;
		_costs = _costs + ([guer_veh_technical] call vehiclePrice) + (server getVariable guer_sol_RFL);
		_hr = _hr + 1;
		};
	_formatX = ([_typeGroup, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _hr = _hr +1} forEach _typeGroup;
	[_hr,_costs] remoteExec ["resourcesFIA",2];
	deleteMarker _mrk;
	outpostsFIA = outpostsFIA - [_mrk]; publicVariable "outpostsFIA";
	mrkFIA = mrkFIA - [_mrk]; publicVariable "mrkFIA";
	markers = markers - [_mrk]; publicVariable "markers";
	if (_mrk in FIA_RB_list) then {
		FIA_RB_list = FIA_RB_list - [_mrk]; publicVariable "FIA_RB_list";
	} else {
		FIA_WP_list = FIA_WP_list - [_mrk]; publicVariable "FIA_WP_list";
	};
};

_isRoad = isOnRoad _positionTel;

_textX = "FIA Observation Post";
_typeGroup = guer_grp_sniper;
_typeVehX = guer_veh_quad;

if (_isRoad) then
	{
	_textX = "FIA Roadblock";
	_typeGroup = guer_grp_AT;
	_typeVehX = guer_veh_offroad;
	};

_mrk = createMarker [format ["FIAPost%1", random 1000], _positionTel];
_mrk setMarkerShape "ICON";

_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + 60];
_dateLimitNum = dateToNumber _dateLimit;

_tsk = ["outpostsFIA", [side_blue, civilian],["STR_TSK_DESC_OPDEPLOY", "STR_TSK_OPDEPLOY", _mrk],_positionTel, "CREATED", 5, true, true, "Move"] call BIS_fnc_setTask;
missionsX pushBackUnique _tsk; publicVariable "missionsX";
_groupX = [getMarkerPos guer_respawn, side_blue, ([_typeGroup, "guer"] call AS_fnc_pickGroup)] call BIS_Fnc_spawnGroup;
_groupX setGroupId ["Watch"];

_radiusX = 10;
while {true} do
	{
	_roads = getMarkerPos guer_respawn nearRoads _radiusX;
	if (count _roads < 1) then {_radiusX = _radiusX + 10};
	if (count _roads > 0) exitWith {};
	};
_road = _roads select 0;
_pos = position _road findEmptyPosition [1,30,guer_veh_truck];
_truckX = _typeVehX createVehicle _pos;
[_groupX] spawn dismountFIA;
_groupX addVehicle _truckX;
{[_x] call AS_fnc_initialiseFIAUnit} forEach units _groupX;
leader _groupX setBehaviour "SAFE";
Slowhand hcSetGroup [_groupX];
_groupX setVariable ["isHCgroup", true, true];

waitUntil {sleep 1; ({alive _x} count units _groupX == 0) or ({(alive _x) and (_x distance _positionTel < 10)} count units _groupX > 0) or (dateToNumber date > _dateLimitNum)};

if ({(alive _x) and (_x distance _positionTel < 10)} count units _groupX > 0) then
	{
	if (isPlayer leader _groupX) then
		{
		_owner = (leader _groupX) getVariable ["owner",leader _groupX];
		(leader _groupX) remoteExec ["removeAllActions",leader _groupX];
		_owner remoteExec ["selectPlayer",leader _groupX];
		(leader _groupX) setVariable ["owner",_owner,true];
		{[_x] joinsilent group _owner} forEach units group _owner;
		[group _owner, _owner] remoteExec ["selectLeader", _owner];
		"" remoteExec ["hint",_owner];
		waitUntil {!(isPlayer leader _groupX)};
		};
	outpostsFIA = outpostsFIA + [_mrk]; publicVariable "outpostsFIA";
	mrkFIA = mrkFIA + [_mrk]; publicVariable "mrkFIA";
	markers = markers + [_mrk]; publicVariable "markers";
	if (_isRoad) then {
		FIA_RB_list pushBackUnique _mrk;
		publicVariable "FIA_RB_list";
	} else {
		FIA_WP_list pushBackUnique _mrk;
		publicVariable "FIA_WP_list";
		// BE module
		_advanced = false;
		if (activeBE) then {
			if (BE_current_FIA_RB_Style == 1) then {_advanced = true};
		};
		if (_advanced) then {
			_posDes = [_positionTel, 5, round (random 359)] call BIS_Fnc_relPos;
			_remDes = ([_posDes, 0,guer_rem_des, side_blue] call bis_fnc_spawnvehicle) select 0;
			_normalPos = surfaceNormal (position _remDes);
			_remDes setVectorUp _normalPos;
		};
		// BE module
	};
	spawner setVariable [_mrk,false,true];
	_tsk = ["outpostsFIA", [side_blue, civilian],["STR_TSK_DESC_OPDEPLOY", "STR_TSK_OPDEPLOY", _mrk],_positionTel, "SUCCEEDED", 5, true, true, "Move"] call BIS_fnc_setTask;
	[-5,5,_positionTel] remoteExec ["AS_fnc_changeCitySupport",2];
	_mrk setMarkerType "loc_bunker";
	_mrk setMarkerColor "ColorYellow";
	_mrk setMarkerText _textX;
	}
else
	{
	_tsk = ["outpostsFIA", [side_blue, civilian],["STR_TSK_DESC_OPDEPLOY", "STR_TSK_OPDEPLOY", _mrk],_positionTel, "FAILED", 5, true, true, "Move"] call BIS_fnc_setTask;
	sleep 3;
	deleteMarker _mrk;
	};

Slowhand hcRemoveGroup _groupX;
{deleteVehicle _x} forEach units _groupX;
deleteVehicle _truckX;
deleteGroup _groupX;
sleep 15;

[0,_tsk] spawn deleteTaskX;