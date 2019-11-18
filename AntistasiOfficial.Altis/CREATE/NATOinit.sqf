private ["_unit","_victim","_killer"];

_unit = _this select 0;
//_unit setVariable ["BLUFORSpawn",true,true]; // trial

_unit allowFleeing 0;
_unit setSkill 0.7;

_unit addEventHandler ["killed", {
	_victim = _this select 0;
	[0.25,0,getPos _victim] remoteExec ["AS_fnc_changeCitySupport",2];
	[_victim] spawn postmortem;
	}];

if (sunOrMoon < 1) then
	{
	if (bluIR in primaryWeaponItems _unit) then {_unit action ["IRLaserOn", _unit]};
	};