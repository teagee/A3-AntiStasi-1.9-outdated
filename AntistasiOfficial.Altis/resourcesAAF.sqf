if (!isPlayer Slowhand) exitWith {};

private ["_resourcesAAF","_costs"];

waitUntil {!resourcesIsChanging};
resourcesIsChanging = true;
_costs = _this select 0;

if (isNil "_costs") then {_costs = 0};

_resourcesAAF = server getVariable "resourcesAAF";
_resourcesAAF = _resourcesAAF + _costs;
if (_resourcesAAF < 0) then {_resourcesAAF = 0};
server setVariable ["resourcesAAF",_resourcesAAF,true];
resourcesIsChanging = false;