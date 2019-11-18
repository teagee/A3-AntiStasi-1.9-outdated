private ["_textX","_oldUnittextX","_display","_setText"];
showStatistics = false;
sleep 3;
showStatistics = true;
disableSerialization;
//1 cutRsc ["H8erHUD","PLAIN",0,false];
_layer = ["estadisticas"] call bis_fnc_rscLayer;
_layer cutRsc ["H8erHUD","PLAIN",0,false];
waitUntil {!isNull (uiNameSpace getVariable "H8erHUD")};

_display = uiNameSpace getVariable "H8erHUD";
_setText = _display displayCtrl 1001;
_setText ctrlSetBackgroundColor [0,0,0,0];
_oldUnittextX = "";
if (isMultiplayer) then
	{
	private ["_nameC"];
	while {showStatistics} do
		{
		waitUntil {sleep 0.5; player == player getVariable ["owner",player]};
		if (player != Slowhand) then
			{
			if (isPlayer Slowhand) then {_nameC = name Slowhand} else {_nameC = "NONE"};
			if (activeBE) then {
				_textX = format ["<t size='0.55'>" + localize "STR_UI_TOP_TEXT1", server getVariable "hr", player getVariable ["Rank_PBar", "Init"], _nameC, player getVariable "moneyX",server getVariable "PrestigeNATO", server getVariable "prestigeCSAT", server getVariable "BE_PBar", [localize "STR_UI_TOP_OVERT",localize "STR_UI_TOP_INCOGNITO"] select (captive player), A3_Str_BLUE, A3_Str_RED];
			} else {
				_textX = format ["<t size='0.55'>" + localize "STR_UI_TOP_TEXT2", server getVariable "hr", player getVariable ["Rank_PBar", "Init"], _nameC, player getVariable "moneyX",server getVariable "PrestigeNATO", server getVariable "prestigeCSAT", [localize "STR_UI_TOP_OVERT",localize "STR_UI_TOP_INCOGNITO"] select (captive player), A3_Str_BLUE, A3_Str_RED];
			};
		}
		else
			{
				if (activeBE) then {
					_textX = format ["<t size='0.55'>" + localize "STR_UI_TOP_TEXT3", server getVariable "hr", server getVariable "resourcesFIA", server getVariable "PrestigeNATO", server getVariable "prestigeCSAT", player getVariable ["Rank_PBar", "Init"], player getVariable "moneyX", server getVariable "BE_PBar", [localize "STR_UI_TOP_OVERT",localize "STR_UI_TOP_INCOGNITO"] select (captive player), A3_Str_BLUE, A3_Str_RED];
				} else {
					_textX = format ["<t size='0.55'>" + localize "STR_UI_TOP_TEXT4", server getVariable "hr", server getVariable "resourcesFIA", server getVariable "PrestigeNATO", server getVariable "prestigeCSAT", player getVariable ["Rank_PBar", "Init"], player getVariable "moneyX", [localize "STR_UI_TOP_OVERT",localize "STR_UI_TOP_INCOGNITO"] select (captive player), A3_Str_BLUE, A3_Str_RED];
				};
			};
		//if (captive player) then {_textX = format ["%1 ON",_textX]} else {_textX = format ["%1 OFF",_textX]};
		if (_textX != _oldUnittextX) then
			{
			//[_textX,-0.1,-0.4,601,0,0,5] spawn bis_fnc_dynamicText;
			_setText ctrlSetStructuredText (parseText format ["%1", _textX]);
			_setText ctrlCommit 0;
			_oldUnittextX = _textX;
			};
		if (player == leader (group player)) then
			{
			if (not(group player in (hcAllGroups player))) then {player hcSetGroup [group player]};
			};
		sleep 1;
		};
	}
else
	{
	while {showStatistics} do
		{
		waitUntil {sleep 0.5; player == player getVariable ["owner",player]};
		if (activeBE) then {
			_textX = format ["<t size='0.55'>" + localize "STR_UI_TOP_TEXT5", server getVariable "hr", server getVariable "resourcesFIA", server getVariable "PrestigeNATO", server getVariable "prestigeCSAT", server getVariable "BE_PBar", [localize "STR_UI_TOP_OVERT",localize "STR_UI_TOP_INCOGNITO"] select (captive player), A3_Str_BLUE, A3_Str_RED];
		} else {
			_textX = format ["<t size='0.55'>" + localize "STR_UI_TOP_TEXT6", server getVariable "hr", server getVariable "resourcesFIA", server getVariable "PrestigeNATO", server getVariable "prestigeCSAT", [localize "STR_UI_TOP_OVERT",localize "STR_UI_TOP_INCOGNITO"] select (captive player), A3_Str_BLUE, A3_Str_RED];
		};
		//if (captive player) then {_textX = format ["%1 ON",_textX]} else {_textX = format ["%1 OFF",_textX]};
		if (_textX != _oldUnittextX) then
			{
			//[_textX,-0.1,-0.4,601,0,0,5] spawn bis_fnc_dynamicText;
			_setText ctrlSetStructuredText (parseText format ["%1", _textX]);
			_setText ctrlCommit 0;
			_oldUnittextX = _textX;
			};
		sleep 1;
		};
	};
