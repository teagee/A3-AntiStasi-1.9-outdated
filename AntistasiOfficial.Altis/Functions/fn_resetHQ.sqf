//#define DEBUG_SYNCHRONOUS
//#define DEBUG_MODE_FULL
#include "script_component.hpp"
if !(isServer) exitWith {};
LOG("START AS_fnc_resetHQ");
params [["_position",static_defPosHQ,[[]]]];
[petros] params ["_oldUnit"];
TRACE_1("Call params",_position);
if (typeName _position != "ARRAY") then {
	_position = static_defPosHQ;
};

if (_position isEqualTo [0,0,0]) then {
	LOG("Error in resetHQ: target position was defined as [0,0,0]");
	_position = static_defPosHQ;
};

groupPetros = createGroup side_blue;
publicVariable "groupPetros";
petros = groupPetros createUnit [ guer_sol_OFF, _position, [], 0, "NONE" ];
groupPetros setGroupId ["Petros","GroupColor4"];
petros setIdentity "friendlyX";
petros setName "Petros";
petros forceSpeed 0;
if (group _oldUnit == groupPetros) then {
      [Petros,"mission"] remoteExec ["AS_fnc_addActionMP"];
} else {
      [Petros,"buildHQ"] remoteExec ["AS_fnc_addActionMP"];
};
call compile preprocessFileLineNumbers "initPetros.sqf";
deleteVehicle _oldUnit;
publicVariable "petros";

AS_flag_resetDone = true;
publicVariable "AS_flag_resetDone";
LOG("END AS_fnc_resetHQ");