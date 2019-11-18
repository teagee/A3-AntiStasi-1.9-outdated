params [["_defPos", "none"]];
private ["_dir"];

if !(typeName "_defPos" == "ARRAY") then {
	_dir = fireX getdir vehicleBox;
	_defPos = [getPos fireX, 3, _dir + 45] call BIS_Fnc_relPos;
};

petros setPos _defPos;
petros setDir (petros getDir fireX);

diag_log "Maintenance: Petros repositioned";