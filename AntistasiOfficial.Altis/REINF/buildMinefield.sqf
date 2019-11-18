if (!isServer and hasInterface) exitWith {};

private ["_typeX","_quantity","_typeAmmunition","_groupX","_unit","_radiusX","_roads","_road","_pos","_truckX","_textX","_mrk","_ATminesAdd","_APminesAdd","_positionTel","_tsk","_magazines","_typeMagazines","_cantMagazines","_newCantMagazines","_mineX","_typeX","_truckX"];

_typeX = _this select 0;
_positionTel = _this select 1;
_quantity = _this select 2;
_costs = (2*(server getVariable guer_sol_EXP)) + ([guer_veh_truck] call vehiclePrice);
[-2,-1*_costs] remoteExec [resourcesFIA,2];

if (_typeX == "ATMine") then
	{
	_typeAmmunition = atMine;
	};
if (_typeX == "APERSMine") then
	{
	_typeAmmunition = apMine;
	};

_magazines = getMagazineCargo boxX;
_typeMagazines = _magazines select 0;
_cantMagazines = _magazines select 1;
_newCantMagazines = [];

for "_i" from 0 to (count _typeMagazines) - 1 do
	{
	if ((_typeMagazines select _i) != _typeAmmunition) then
		{
		_newCantMagazines pushBack (_cantMagazines select _i);
		}
	else
		{
		_hasQuantity = (_cantMagazines select _i);
		_hasQuantity = _hasQuantity - _quantity;
		if (_hasQuantity < 0) then {_countXsHay = 0};
		_newCantMagazines pushBack _hasQuantity;
		};
	};

clearMagazineCargoGlobal boxX;

for "_i" from 0 to (count _typeMagazines) - 1 do
	{
	boxX addMagazineCargoGlobal [_typeMagazines select _i,_newCantMagazines select _i];
	};

_mrk = createMarker [format ["Minefield%1", random 1000], _positionTel];
_mrk setMarkerShape "ELLIPSE";
_mrk setMarkerSize [100,100];
_mrk setMarkerType "hd_warning";
_mrk setMarkerColor "ColorRed";
_mrk setMarkerBrush "DiagGrid";
_mrk setMarkerText _textX;

_tsk = ["Mines",[side_blue,civilian],[["STR_TSK_MINEFIELD_DESC",_quantity],"STR_MINEFIELD_TITLE",_mrk],_positionTel,"CREATED",5,true,true,"map"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";

_groupX = createGroup side_blue;

_unit = _groupX createUnit [guer_sol_EXP, (getMarkerPos guer_respawn), [], 0, "NONE"];
sleep 1;
_unit = _groupX createUnit [guer_sol_EXP, (getMarkerPos guer_respawn), [], 0, "NONE"];
_groupX setGroupId ["MineF"];

_radiusX = 10;
while {true} do
	{
	_roads = getMarkerPos guer_respawn nearRoads _radiusX;
	if (count _roads < 1) then {_radiusX = _radiusX + 10};
	if (count _roads > 0) exitWith {};
	};
_road = _roads select 0;
_pos = position _road findEmptyPosition [1,30,guer_veh_truck];

_truckX = guer_veh_truck createVehicle _pos;

_groupX addVehicle _truckX;
{[_x] spawn AS_fnc_initialiseFIAUnit; [_x] orderGetIn true} forEach units _groupX;
[_truckX] spawn VEHinit;
leader _groupX setBehaviour "SAFE";
Slowhand hcSetGroup [_groupX];
_groupX setVariable ["isHCgroup", true, true];
_truckX allowCrewInImmobile true;

//waitUntil {sleep 1; (count crew _truckX > 0) or (!alive _truckX) or ({alive _x} count units _groupX == 0)};

waitUntil {sleep 1; (!alive _truckX) or ((_truckX distance _positionTel < 50) and ({alive _x} count units _groupX > 0))};

if ((_truckX distance _positionTel < 50) and ({alive _x} count units _groupX > 0)) then
	{
	if (isPlayer leader _groupX) then
		{
		_owner = player getVariable ["owner",player];
		//removeAllActions player;  ----- might cause issues
		selectPlayer _owner;
		(leader _groupX) setVariable ["owner",player,true];
		{[_x] joinsilent group player} forEach units group player;
		group player selectLeader player;
		hint "";
		};
	Slowhand hcRemoveGroup _groupX;
	[[petros,"locHint","STR_TSK_MINEFIELD_HINT"],"commsMP"] call BIS_fnc_MP;
	[_groupX, _mrk, "SAFE","SPAWNED", "SHOWMARKER"] execVM "scripts\UPSMON.sqf";
	sleep 30*_quantity;
	if ((alive _truckX) and ({alive _x} count units _groupX > 0)) then
		{
		{deleteVehicle _x} forEach units _groupX;
		deleteGroup _groupX;
		deleteVehicle _truckX;
		for "_i" from 1 to _quantity do
			{
			_mineX = createMine [_typeX,_positionTel,[],100];
			side_blue revealMine _mineX;
			};
		_tsk = ["Mines",[side_blue,civilian],[["STR_TSK_MINEFIELD_DESC",_quantity],"STR_MINEFIELD_TITLE",_mrk],_positionTel,"SUCCEEDED",5,true,true,"Map"] call BIS_fnc_setTask;
		sleep 15;
		//[_tsk,true] call BIS_fnc_deleteTask;
		[0,_tsk] spawn deleteTaskX;
		[2,_costs] remoteExec ["resourcesFIA",2];
		}
	else
		{
		_tsk = ["Mines",[side_blue,civilian],[["STR_TSK_MINEFIELD_DESC",_quantity],"STR_MINEFIELD_TITLE",_mrk],_positionTel,"FAILED",5,true,true,"Map"] call BIS_fnc_setTask;
		sleep 15;
		Slowhand hcRemoveGroup _groupX;
		//[_tsk,true] call BIS_fnc_deleteTask;
		[0,_tsk] spawn deleteTaskX;
		{deleteVehicle _x} forEach units _groupX;
		deleteGroup _groupX;
		deleteVehicle _truckX;
		deleteMarker _mrk;
		};
	}
else
	{
	_tsk = ["Mines",[side_blue,civilian],[["STR_TSK_MINEFIELD_DESC",_quantity],"STR_MINEFIELD_TITLE",_mrk],_positionTel,"FAILED",5,true,true,"Map"] call BIS_fnc_setTask;
	sleep 15;
	Slowhand hcRemoveGroup _groupX;
	//[_tsk,true] call BIS_fnc_deleteTask;
	[0,_tsk] spawn deleteTaskX;
	{deleteVehicle _x} forEach units _groupX;
	deleteGroup _groupX;
	deleteVehicle _truckX;
	deleteMarker _mrk;
	};

