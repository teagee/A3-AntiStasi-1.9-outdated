params ["_spawnPos"];
private ["_corpse"];

if !(_spawnPos isEqualType "ARRAY") exitWith {diag_log format ["Info: respawning Petros failed, bad coordinates: %1", _spawnPos]};
_corpse = petros;
groupPetros = createGroup side_blue;
publicVariable "groupPetros";
petros = groupPetros createUnit [guer_sol_OFF, _spawnPos, [], 0,"NONE"];
groupPetros setGroupId ["Petros","GroupColor4"];
petros setIdentity "friendlyX";
petros setName "Petros";
petros forceSpeed 0;
if (group _corpse == groupPetros) then {
      [[Petros,"mission"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
} else {
      [[Petros,"buildHQ"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
};

call compile preprocessFileLineNumbers "initPetros.sqf";
deleteVehicle _corpse;
publicVariable "petros";