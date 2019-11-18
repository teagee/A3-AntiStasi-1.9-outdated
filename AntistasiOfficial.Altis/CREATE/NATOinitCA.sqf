//initilise NATO close airsport


private ["_unit","_victim","_killer"];

_unit = _this select 0;
//_unit setVariable ["BLUFORSpawn",true,true]; //Disable CAS spawning bases. Edited: 27.07.2017

_unit allowFleeing 0;
_unit setSkill 0.7;

if (sunOrMoon < 1) then
	{
	if (bluIR in primaryWeaponItems _unit) then {_unit action ["IRLaserOn", _unit]};
	};

_EHkilledIdx = _unit addEventHandler ["killed", {
	_victim = _this select 0;
	_victim setVariable ["BLUFORSpawn",nil,true];
	[_victim] spawn postmortem;
	[0.25,0,getPos _victim] remoteExec ["AS_fnc_changeCitySupport",2];
	//[-1,0] remoteExec ["prestige",2];
	//if (group _victim == group player) then {arrayids = arrayids + [name _victim]};
	}];

