
_resourcesFIA = server getVariable "resourcesFIA";

if (_resourcesFIA < 5000) exitWith {hint localize "STR_HINTS_RA_YDNHEMTRAA"};

_destroyedCities = destroyedCities - citiesX;

openMap true;
positionTel = [];
hint localize "STR_HINTS_RA_COTZYWTR";

onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel = positionTel;

_siteX = [markers,_positionTel] call BIS_fnc_nearestPosition;

if (getMarkerPos _siteX distance _positionTel > 50) exitWith {hint localize "STR_HINTS_RA_YMCNAMM"};

if (not(_siteX in _destroyedCities)) exitWith {hint localize "STR_HINTS_RA_YCRT"};

_nameX = [_siteX] call AS_fnc_localizar;

hint format [localize "STR_HINTS_RA_1REBUILT"];

[0,10,_positionTel] remoteExec ["AS_fnc_changeCitySupport",2];
[5,0] remoteExec ["prestige",2];
destroyedCities = destroyedCities - [_siteX];
publicVariable "destroyedCities";
if (_siteX in power) then {[_siteX] call AS_fnc_powerReorg};
[0,-5000] remoteExec ["resourcesFIA",2];