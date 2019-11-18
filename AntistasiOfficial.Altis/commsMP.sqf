if (!hasInterface) exitWith {};

params ["_unit","_typeX","_textX"];

if (_typeX == "sideChat") exitWith {_unit sideChat _textX;};

if (_typeX == "locSideChat") exitWith {_unit sideChat localize _textX;};

if (_typeX == "hint") exitWith {hint _textX;};

if (_typeX == "locHint") exitWith {hint localize _textX;};

if (_typeX == "hintCS") exitWith {hintC _textX;}; //not using

if (_typeX == "globalChat") exitWith {_unit globalChat _textX;};

if (_typeX == "locGlobalChat") exitWith {_unit globalChat localize _textX;};

if (_typeX == "income") exitWith {
	waitUntil {sleep 0.2; !incomeRep};
	incomeRep = true;
	//playSound3D ["a3\sounds_f\sfx\beep_target.wss", player];
	playSound "3DEN_notificationDefault";
	//[_textX,0.8,0.5,5,0,0,2] spawn bis_fnc_dynamicText;
	[_textX, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], 0.5, 5, 0, 0, 2] spawn bis_fnc_dynamicText;
	incomeRep = false;
};

if (_typeX == "countdown") exitWith {hint format ["Time Remaining: %1 secs",_textX];};

if (_typeX == "taxRep") exitWith {
	incomeRep = true;
	playSound "3DEN_notificationDefault";
	//playSound3D ["a3\sounds_f\sfx\beep_target.wss", player];
	//[_textX,0.8,0.5,5,0,0,2] spawn bis_fnc_dynamicText;
	[_textX, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], 0.5, 5, 0, 0, 2] spawn bis_fnc_dynamicText;
	sleep 10;
	incomeRep = false;
};

if (_typeX == "BE") exitWith {
	sleep 0.5;
	"AXP Details" hintC _textX;
	hintC_arr_EH = findDisplay 72 displayAddEventHandler ["unload", {
		0 = _this spawn {
			_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
			hintSilent "";
		};
	}];
};

if (_typeX == "status") exitWith {
	sleep 0.5;
	"FIA Details" hintC _textX;
	hintC_arr_EH = findDisplay 72 displayAddEventHandler ["unload", {
		0 = _this spawn {
			_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
			hintSilent "";
		};
	}];
};

if (_typeX == "save") exitWith {
	sleep 0.5;
	"Progress Saved" hintC  [localize "STR_HINTS_SAVE_COM_1", localize "STR_HINTS_SAVE_COM_2",localize "STR_HINTS_SAVE_COM_3",localize "STR_HINTS_SAVE_COM_4"];
	hintC_arr_EH = findDisplay 72 displayAddEventHandler ["unload", {
		0 = _this spawn {
			_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
			hintSilent "";
		};
	}];
};