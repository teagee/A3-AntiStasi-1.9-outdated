//////////////////////////////////////////////////////////////////////////////////////////////////////////
//boxX
	boxX allowDamage false;
	boxX addAction [localize "STR_ACT_UNLOADCARGO","[] call emptyX"];


	// Stef adding class selection in singleplayer
	if(!isMultiplayer) then{
	boxX addAction [localize "STR_ACT_CHANGEROLE",
		{CreateDialog "ROLECHANGE";},
		nil,
		0,
		false,
		true,
		"",
		"(_this == Slowhand)"
	];};


	boxX addAction [localize "STR_ACT_MOVEASSET",
		{[_this select 0,_this select 1,_this select 2] spawn AS_fnc_moveObject},
		nil,
		0,
		false,
		true,
		"",
		"(_this == Slowhand)"
	];
	//boxX addAction [localize "STR_ACT_SELLMENU", "UI\sellMenu.sqf",nil,0,false,true,"","(_this == Slowhand)", 5];   <- This is black market, gonna be enabled onced tweaked, remove the comment to try it.

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//mapX----------
	mapX allowDamage false;
	mapX addAction [localize "str_act_gameOptions",
		{
			hint format ["Arma 3 - Antistasi\n\nVersion: %1",antistasiVersion];
			nul=CreateDialog "game_options_commander";
		},
		nil,
		0,
		false,
		true,
		"",
		"(isPlayer _this) and (_this == Slowhand) and (_this == _this getVariable ['owner',objNull])"
	];
	mapX addAction [localize "str_act_gameOptions",
		{
			hint format ["Arma 3 - Antistasi\n\nVersion: %1",antistasiVersion];
			nul=CreateDialog "game_options_player";
		},
		nil,
		0,
		false,
		true,
		"",
		"(isPlayer _this) and !(_this == Slowhand) and (_this == _this getVariable ['owner',objNull])"
	];
	mapX addAction [localize "str_act_mapInfo",
		{
			nul = [] execVM "cityinfo.sqf";
		},
		nil,
		0,
		false,
		true,
		"",
		"(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"
	];
	/*mapX addAction [localize "str_act_tfar",    //Don't know if it works, might just cause confusion. TFAR have channel synced only if CBA dependency is on.
		{
			nul=CreateDialog "tfar_menu";
		},
		nil,
		0,
		false,
		true,
		"",
		"(isClass (configFile >> ""CfgPatches"" >> ""task_force_radio""))",
		5
	];*/
	mapX addAction [localize "str_act_moveAsset",
		"moveObject.sqf",
		nil,
		0,
		false,
		true,
		"",
		"(_this == Slowhand)",
		5
	];


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//flagX
	flagX allowDamage false;
	flagX addAction [localize "str_act_hqOptions",
		{
			nul=[] execVM "Dialogs\dialogHQ.sqf";
		},
		nil,
		0,
		false,
		true,
		"",
		"(isPlayer _this) and (player == Slowhand) and (_this == _this getVariable ['owner',objNull]) and (petros == leader group petros)"
	];
	flagX addAction [localize "str_act_recruitUnit",
		{
			nul=[] execVM "Dialogs\unit_recruit.sqf";
		},
		nil,
		0,
		false,
		true,
		"",
		"(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"
	];
	flagX addAction [localize "str_act_moveAsset",
		"moveObject.sqf",
		nil,
		0,
		false,
		true,
		"",
		"(_this == Slowhand)",
		5
	];


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//vehicleBox
	vehicleBox allowDamage false;
	vehicleBox addAction [localize "str_act_healRepair", "healandrepair.sqf",nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"];
	vehicleBox addAction [localize "str_act_buyVehicle",
		{
			nul = createDialog "vehicle_option"
		},
		nil,
		0,
		false,
		true,
		"",
		"(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"
	];
	vehicleBox addAction [localize "STR_ACT_BUYB", "REINF\buyBoat.sqf",nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"];
	vehicleBox addAction [localize "str_act_moveAsset", "moveObject.sqf",nil,0,false,true,"","(_this == Slowhand)",5];
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//campFire
	fireX allowDamage false;
	fireX addAction [localize "str_act_rest", "skiptime.sqf",nil,0,false,true,"","isPlayer _this"];
	fireX addAction [localize "str_act_moveAsset",
		"moveObject.sqf",
		nil,
		0,
		false,
		true,
		"",
		"(_this == Slowhand)",
		5
	];

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//petros
	groupPetros = group petros;
	groupPetros setGroupId ["Petros","GroupColor4"];
	petros setIdentity "friendlyX";
	petros setName "Petros";
	petros forceSpeed 0;
	petros setCombatMode "GREEN";
	petros addAction [localize "str_act_missionRequest", {nul=CreateDialog "mission_menu";},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"];
