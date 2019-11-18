if (!isServer) exitWith {};

private ["_typeX","_costs","_groupX","_unit","_radiusX","_roads","_road","_pos","_truckX","_textX","_mrk","_hr","_unitsX","_formatX"];

_typeX = _this select 0;
_positionTel = _this select 1;

if (_typeX == "delete") exitWith {
	_mrk = [campsFIA,_positionTel] call BIS_fnc_nearestPosition;
	_pos = getMarkerPos _mrk;
	_txt = markerText _mrk;
	hint format ["Deleting %1", _txt];
	_costs = 0;
	_hr = 0;
	_formatX = ([guer_grp_sniper, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_costs = _costs + (server getVariable _x); _hr = _hr +1} forEach _typeGroup;
	[_hr,_costs] remoteExec ["resourcesFIA",2];
	deleteMarker _mrk;
	campsFIA = campsFIA - [_mrk]; publicVariable "campsFIA";
	campList = campList - [[_mrk, _txt]]; publicVariable "campList";
	usedCN = usedCN - [_txt]; publicVariable "usedCN";
	diag_log format ["deleting: %1", [_txt]];
	markers = markers - [_mrk]; publicVariable "markers";
};

_nameOptions = campNames - usedCN;
_textX = selectRandom _nameOptions;
_typeVehX = guer_veh_truck;

_mrk = createMarker [format ["FIACamp%1", random 1000], _positionTel];
_mrk setMarkerShape "ICON";

_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + 60];
_dateLimitNum = dateToNumber _dateLimit;

_tsk = ["campsFIA",[side_blue,civilian],["STR_TSK_DESC_CAMPSET","STR_TSK_CAMPSET",_mrk],_positionTel,"CREATED",5,true,true,"Move"] call BIS_fnc_setTask;
missionsX pushBackUnique _tsk; publicVariable "missionsX";

_radiusX = 10;
while {true} do {
	_roads = getMarkerPos guer_respawn nearRoads _radiusX;
	if (count _roads < 1) then {_radiusX = _radiusX + 10};
	if (count _roads > 0) exitWith {};
};
_road = _roads select 0;
_pos = position _road findEmptyPosition [1,30,guer_veh_truck];

_vehicle=[_pos, 0,guer_veh_truck, side_blue] call bis_fnc_spawnvehicle;
_truckX = _vehicle select 0;
_truckX deleteVehicleCrew driver _truckX;

_groupX = [getMarkerPos guer_respawn, side_blue, ([guer_grp_sniper, "guer"] call AS_fnc_pickGroup)] call BIS_Fnc_spawnGroup;
_groupX setGroupId ["Camp"];
{
	if (_forEachIndex == 0) then {
		_x moveInDriver _truckX;
	} else {
		_x moveInCargo _truckX;
	};
} forEach units _groupX;
{[_x] call AS_fnc_initialiseFIAUnit;} forEach units _groupX;

[_groupX, driver _truckX] remoteExec ["selectLeader", groupOwner _groupX];
leader _groupX setBehaviour "SAFE";
driver _truckX action ["engineOn", _truckX];
[_groupX] spawn dismountFIA;

Slowhand hcSetGroup [_groupX];
_groupX setVariable ["isHCgroup", true, true];

_crate = "Box_FIA_Support_F" createVehicle _pos;
_crate attachTo [_truckX,[0.0,-1.2,0.5]];

waitUntil {sleep 1; ({alive _x} count units _groupX == 0) or ({(alive _x) and (_x distance _positionTel < 10)} count units _groupX > 0) or (dateToNumber date > _dateLimitNum)};

if ({(alive _x) and (_x distance _positionTel < 10)} count units _groupX > 0) then {
	if (isPlayer leader _groupX) then {
		_owner = (leader _groupX) getVariable ["owner",leader _groupX];
		(leader _groupX) remoteExec ["removeAllActions",leader _groupX];
		_owner remoteExec ["selectPlayer",leader _groupX];
		(leader _groupX) setVariable ["owner",_owner,true];
		{[_x] joinsilent group _owner} forEach units group _owner;
		[group _owner, _owner] remoteExec ["selectLeader", _owner];
		"" remoteExec ["hint",_owner];
		waitUntil {!(isPlayer leader _groupX)};
	};
	campsFIA = campsFIA + [_mrk]; publicVariable "campsFIA";
	campList = campList + [[_mrk, _textX]]; publicVariable "campList";
	markers = markers + [_mrk];
	publicVariable "markers";
	spawner setVariable [_mrk,false,true];
	_tsk = ["campsFIA",[side_blue,civilian],["STR_TSK_DESC_CAMPSET","STR_TSK_CAMPSET",_mrk],_positionTel,"SUCCEEDED",5,true,true,"Move"] call BIS_fnc_setTask;
	_mrk setMarkerType "loc_bunker";
	_mrk setMarkerColor "ColorOrange";
	_mrk setMarkerText _textX;
	usedCN pushBack _textX;
}
else {
	_tsk = ["campsFIA",[side_blue,civilian],["STR_TSK_DESC_CAMPSET","STR_TSK_CAMPSET",_mrk],_positionTel,"FAILED",5,true,true,"Move"] call BIS_fnc_setTask;
	sleep 3;
	deleteMarker _mrk;
};

Slowhand hcRemoveGroup _groupX;
{deleteVehicle _x} forEach units _groupX;
deleteVehicle _truckX;
deleteGroup _groupX;
_crate enableSimulationGlobal false;
_crate hideObjectGlobal true;
sleep 15;

[0,_tsk] spawn deleteTaskX;