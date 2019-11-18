params [["_ignoreDistance", false]]; //Use true to ignore the distance checks. Sparker.

if(((petros distance boxX) > 30 || (petros distance vehicleBox) > 30) && !_ignoreDistance) exitWith {hint "Move the ammoboxes closer to Petros.";};
if(((!isNull (attachedTo boxX)) || !(isNull (attachedTo vehicleBox))) && !_ignoreDistance) exitWith {hint "You need to unload both ammoboxes first.";};
//Remove actions to load the boxes with Jeroen's script
boxX call jn_fnc_logistics_removeAction;
vehicleBox call jn_fnc_logistics_removeAction;

private ["_pos","_rnd"];
_movedX = false;
if (group petros != groupPetros) then
	{
	_movedX = true;
	[petros] join groupPetros;
	};
[[petros,"remove"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
petros forceSpeed 0;
guer_respawn setMarkerPos getPos petros;
"FIA_HQ" setMarkerPos getPos petros;
posHQ = getMarkerPos guer_respawn; publicVariable "posHQ";
server setVariable ["posHQ", getMarkerPos guer_respawn, true];

if (isMultiplayer) then
	{
	boxX hideObjectGlobal false;
	vehicleBox hideObjectGlobal false;
	mapX hideObjectGlobal false;
	fireX hideObjectGlobal false;
	flagX hideObjectGlobal false;
	}
else
	{
	if (_movedX) then {hint "Please wait while moving HQ Assets to selected position"};
	//sleep 5
	boxX hideObject false;
	vehicleBox hideObject false;
	mapX hideObject false;
	fireX hideObject false;
	flagX hideObject false;
	};
fireX inflame true;
guer_respawn setMarkerAlpha 1;
_pos = [getPos petros, 3, getDir petros] call BIS_Fnc_relPos;
fireX setPos _pos;
_rnd = getdir Petros;
if (isMultiplayer) then {sleep 5};
_pos = [getPos fireX, 3, _rnd] call BIS_Fnc_relPos;
if(_ignoreDistance) then
{
	boxX setPos _pos; //Set it up for Jeroen's cargo loading script. Sparker.
};
_rnd = _rnd + 45;
_pos = [getPos fireX, 3, _rnd] call BIS_Fnc_relPos;
mapX setPos _pos;
mapX setDir ([fireX, mapX] call BIS_fnc_dirTo);
_rnd = _rnd + 45;
_pos = [getPos fireX, 3, _rnd] call BIS_Fnc_relPos;
flagX setPos _pos;
_rnd = _rnd + 45;
_pos = [getPos fireX, 3, _rnd] call BIS_Fnc_relPos;
if(_ignoreDistance) then
{
	vehicleBox setPos _pos;
};
if (_movedX) then {[] call emptyX};
placementDone = true; publicVariable "placementDone";
sleep 5;
[[Petros,"mission"],"AS_fnc_addActionMP"] call BIS_fnc_MP;


//Stef Check if road is found within 500m
_arr1 = [(getMarkerPos guer_respawn), [citiesX, (getMarkerPos guer_respawn)] call BIS_fnc_nearestPosition] call AS_fnc_findRoadspot;
if(_arr1 isequalto []) then {hint localize "STR_HINTS_COMMANDER_HQBUILDFAR"; petros globalChat localize "STR_HINTS_COMMANDER_HQBUILDFAR"; petros globalChat localize "STR_HINTS_HQFAR_BUILD"};

//[] remoteExec ["petrosAnimation", 2];
