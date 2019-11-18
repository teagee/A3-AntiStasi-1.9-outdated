if (!isServer and hasInterface) exitWith {};

_tskTitle = "STR_TSK_TD_logSupply";
_tskDesc = "STR_TSK_TD_DESC_logSupply";

_markerX = _this select 0;
_positionX = getMarkerPos _markerX;

_timeLimit = 60;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_nameDest = [_markerX] call AS_fnc_localizar;

_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"CREATED",5,true,true,"Heal"] call BIS_fnc_setTask;
missionsX pushBack _tsk; publicVariable "missionsX";
_pos = (getMarkerPos guer_respawn) findEmptyPosition [1,50,AS_misSupplyBox];

_sbox = AS_misSupplyBox createVehicle _pos;
_sbox call jn_fnc_logistics_addAction;
//{_x reveal _sbox} forEach (allPlayers - (entities "HeadlessClient_F")); No sense to reveal an object to players
_sbox setVariable ["destinationX",_nameDest,true];
_sbox addAction ["Delivery infos",
	{
		_text = format ["Deliver this box to %1, unload it to start distributing to people",(_this select 0) getVariable "destinationX"];
		_text remoteExecCall ["hint",_this select 2];
	},
	nil,
	0,
	false,
	true,
	"",
	"(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"
];


[_sbox,"Supply Crate"] spawn inmuneConvoy;

waitUntil {sleep 1; (not alive _sbox) or (dateToNumber date > _dateLimitNum) or (_sbox distance _positionX < 40) and (isNull attachedTo _sbox)};

if (dateToNumber date > _dateLimitNum) then {
	_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"FAILED",5,true,true,"Heal"] call BIS_fnc_setTask;
	[5,-5,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
	[-10,Slowhand] call playerScoreAdd;
} else {
	_countX = 120;
	_counter = 0;
	_active = false;
	[_positionX] remoteExec ["patrolCA", call AS_fnc_getNextWorker]; //In future this will be small ca from outpost
	{_friendX = _x;
		if (captive _friendX) then {[_friendX,false] remoteExec ["setCaptive",_friendX];};
		{
			if ((side _x == side_green) and (_x distance _positionX < distanceSPWN)) then {
				if (_x distance _positionX < 300) then {_x doMove _positionX} else {_x reveal [_friendX,4]};
			};
			if ((side _x == civilian) and (_x distance _positionX < 300)) then {_x doMove position _sbox};
		} forEach allUnits;
	} forEach ([300,0,position _sbox,"BLUFORSpawn"] call distanceUnits);

	while {(_counter < _countX) and (dateToNumber date < _dateLimitNum)} do {
		while {
			(_counter < _countX) and
			(_sbox distance _positionX < 40) && (speed _sbox < 1) and
			(alive _sbox) and
			(isNull attachedTo _sbox) and
			!(
			  	{[_x] call AS_fnc_isUnconscious} count ([40,0,_sbox,"BLUFORSpawn"] call distanceUnits) ==
			  	count ([40,0,_sbox,"BLUFORSpawn"] call distanceUnits)) and
				({(side _x == side_green) and (_x distance _sbox < 50)} count allUnits == 0) and (dateToNumber date < _dateLimitNum)} do {
					if !(_active) then {   //this is not going to have any use since it is a crate.
						{
							_x action ["eject", _sbox];
						} forEach (crew (_sbox));
						_sbox lock 2;
						_sbox engineOn false;
						{if (isPlayer _x) then {[(_countX - _counter),false] remoteExec ["pBarMP",_x]; [_sbox,true] remoteExec ["AS_fnc_lockVehicle",_x];}} forEach ([80,0,_sbox,"BLUFORSpawn"] call distanceUnits);
						_active = true;
						[[petros,"globalChat","Guard the truck!"],"commsMP"] call BIS_fnc_MP;
					};

			_counter = _counter + 1;
  			sleep 1;
		};

		if (_counter < _countX) then {
			_counter = 0;
			_active = false;

			{if (isPlayer _x) then {[0,true] remoteExec ["pBarMP",_x]}} forEach ([100,0,_sbox,"BLUFORSpawn"] call distanceUnits);

			if (
				((_sbox distance _positionX > 40) or (not([40,1,_sbox,"BLUFORSpawn"] call distanceUnits)) or
			    ({(side _x == side_green) and (_x distance _sbox < 50)} count allUnits != 0)) and (alive _sbox))
			then {[[petros,"hint","Don't get the truck far from the city center, and stay close to it, and clean all AAF presence in the surroundings or count will restart"],"commsMP"] call BIS_fnc_MP};

			waitUntil {sleep 1; (
				(_sbox distance _positionX < 40) and ([40,1,_sbox,"BLUFORSpawn"] call distanceUnits) and
				({(side _x == side_green) and (_x distance _sbox < 50)} count allUnits == 0))
				or (dateToNumber date > _dateLimitNum)};
			};

				if !(_counter < _countX) exitWith {};
	};

	if (dateToNumber date < _dateLimitNum) then {
		[[petros,"hint","Supplies Delivered"],"commsMP"] call BIS_fnc_MP;
		_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"SUCCEEDED",5,true,true,"Heal"] call BIS_fnc_setTask;
		[0,15,_markerX] remoteExec ["AS_fnc_changeCitySupport",2];
		[5,0] remoteExec ["prestige",2];
		{if (_x distance _positionX < 500) then {[10,_x] call playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
		[5,Slowhand] call playerScoreAdd;
		// BE module
		if (activeBE) then {
			["mis"] remoteExec ["fnc_BE_XP", 2];
		};
		// BE module
	}
	else {
		_tsk = ["LOG",[side_blue,civilian],[[_tskDesc,_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4],_tskTitle,_markerX],_positionX,"FAILED",5,true,true,"Heal"] call BIS_fnc_setTask;
		[5,-5,_positionX] remoteExec ["AS_fnc_changeCitySupport",2];
		[-10,Slowhand] call playerScoreAdd;
	};
};
{if (isPlayer _x) then {[_sbox,false] remoteExec ["AS_fnc_lockVehicle",_x];}} forEach ([100,0,_sbox,"BLUFORSpawn"] call distanceUnits);

_ecpos = getpos _sbox;
deleteVehicle _sbox;
_empty = AS_misSupplyBoxEmpty createVehicle _ecpos;

//sleep (600 + random 1200);

//[_tsk,true] call BIS_fnc_deleteTask;
[600,_tsk] spawn deleteTaskX;
waitUntil {sleep 1; (not([distanceSPWN,1,_empty,"BLUFORSpawn"] call distanceUnits)) or ((_empty distance (getMarkerPos guer_respawn) < 60))};
deleteVehicle _empty;

