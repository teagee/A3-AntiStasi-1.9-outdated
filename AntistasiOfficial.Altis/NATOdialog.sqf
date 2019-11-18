//if (player != Slowhand) exitWith {hint localize "STR_HINTS_NATOD_OCCAFNATOS"};
_typeX = _this select 0;

if (!allowPlayerRecruit) exitWith {hint localize "STR_HINTS_NATOD_SIVLWOMOCFPS"};
if (_typeX in missionsX) exitWith {hint localize "STR_HINTS_NATOD_NATOIABWTKOM"};
if (!([player] call hasRadio)) exitWith {hint localize "STR_HINTS_NATOD_YNARIYITBATGOTOS"};

// check if FIA controls a radio tower
// /begin
/*
_s = antennas - mrkAAF;
_c = 0;

if (count _s > 0) then {
	for "_i" from 0 to (count _s - 1) do {
		_antenna = _s select _i;
		_nearX = [markers, getPos _antenna] call BIS_fnc_nearestPosition;
		if (_nearX in mrkFIA) then {_c = _c + 1};
	};
};


if (_c < 1) exitWith {
	_l1 = ["Radio Operator", "I cannot get NATO on the horn. I might have more luck if I were able to jerry-rig this radio to a proper radio tower..."];
	[[_l1],"SIDE",0.15] execVM "createConv.sqf";
};
*/
// /end

_bases = bases - mrkAAF;
_airportsX = airportsX - mrkAAF;

if (((_typeX == "NATOArty") or (_typeX == "NATOArmor") or (_typeX == "NATORoadblock")) and (count _bases == 0)) exitWith {hint localize "STR_HINTS_NATOD_YNYCALOBTPTA"};

_costsNATO = 5;
_textXHint = "";

switch (_typeX) do {
	case "NATOCA": {
		_costsNATO = 20;
		_textXhint = localize "STR_HINTS_NATOD_COTBOAYWNATOTA";
	};
	case "NATOArmor": {
		_costsNATO = 20;
		_textXhint = localize "STR_HINTS_NATOD_COTBFWYWNATOTOTA";
	};
	case "NATOAmmo": {
		_costsNATO = 5;
		_textXhint = localize "STR_HINTS_NATOD_COTSWYWTA";
	};
	case "NATOArty": {
		_costsNATO = 10;
		_textXhint = localize "STR_HINTS_NATOD_COTBFWYWAS";
	};
	case "NATOCAS": {
		_costsNATO = 10;
		_textXhint = localize "STR_HINTS_NATOD_COTAFWYWNATOTA";
	};
	case "NATORoadblock": {
		_costsNATO = 10;
		_textXhint = localize "STR_HINTS_NATOD_COTSWYWNATOTSAR";
	};
	case "NATOQRF": {
		_costsNATO = 10;
		_textXhint = localize "STR_HINTS_NATOD_COTBOACFWYWNATOTDAQRF";
	};
	case "NATORED": {           //Stef 30-08 adding a way to reduce CSATprestige by spending NATO
		_costsNATO = 100;
		_textXhint = localize "STR_HINTS_NATOD_YIASEFEIDWRTCATI";
	};
};

_NATOSupp = server getVariable "prestigeNATO";

if (_NATOSupp < _costsNATO) exitWith {hint format [localize "STR_HINTS_NATOD_WLOENATOSIOTPWTR",_costsNATO]};

if (_typeX == "NATOCAS") exitWith {[] remoteExec [_typeX, call AS_fnc_getNextWorker]};
if (_typeX == "NATOUAV") exitWith {[] remoteExec [_typeX, call AS_fnc_getNextWorker]};

if (_typeX == "NATORED") exitWith {[-100,-10] remoteExec ["prestige",2];}; //Stef 30-08 added the support change, maybe add a sleep 5 minute to take effect to simulate jets moving to them.


positionTel = [];

hint format ["%1",_textXhint];

openMap true;
onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel =+ positionTel;
if ((_typeX != "NATOArmor") or (_typeX == "NATORoadblock")) then {openMap false};

// break, in case no valid point of origin was selected
_leave = false;

// location for the QRF to depart from -- default: NATO carrier
_loc = "spawnNATO";


// roadblocks, only allowed on roads
if (_typeX == "NATORoadblock") exitWith {
	_check = isOnRoad _positionTel;
	if !(_check) exitWith {hint localize "STR_HINTS_NATOD_RBCOBPOR"};
	[_positionTel] remoteExec [_typeX, call AS_fnc_getNextWorker];
};

if (_typeX == "NATOAmmo") exitWith {[_positionTel,_NATOSupp] remoteExec [_typeX,  call AS_fnc_getNextWorker]};

_siteX = [markers, _positionTel] call BIS_Fnc_nearestPosition;

if (_typeX == "NATOQRF") exitWith {
	_siteXName = "the NATO carrier";
	if ((_siteX in _bases) || (_siteX in _airportsX)) then {
		_loc = _siteX;
		_siteXName = [_siteX] call AS_fnc_localizar;
	};

	positionTel = [];
	hint format [localize "STR_HINTS_NATOD_QRFDF1MTTFTQRF",_siteXName];

	openMap true;
	onMapSingleClick "positionTel = _pos;";

	waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
	onMapSingleClick "";

	if (!visibleMap) exitWith {};

	_destinationX =+ positionTel;
	openMap false;

	if (surfaceIsWater _destinationX) exitWith {hint localize "STR_HINTS_NATOD_NLCSATDQRFIRTL"};
	hint localize "STR_HINTS_NATOD_QRFI";
	[_loc,_destinationX] remoteExec ["NATOQRF", call AS_fnc_getNextWorker];
};

if (_positionTel distance getMarkerPos _siteX > 50) exitWith {hint localize "STR_HINTS_NATOD_YMCNAMM"};

if (_typeX == "NATOArty") exitWith {
	if (not(_siteX in _bases)) exitWith {hint localize "STR_HINTS_NATOD_ASCOBOFB"};
	[_siteX] remoteExec ["NATOArty",  call AS_fnc_getNextWorker];
};

if (_typeX == "NATOArmor") then {
	if (not(_siteX in _bases)) then {
		_leave = true;
		hint localize "STR_HINTS_NATOD_YMCNAFB";
	}
	else {
		positionTel = [];
		hint localize "STR_HINTS_NATOD_COTACD";

		openMap true;
		onMapSingleClick "positionTel = _pos;";

		waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
		onMapSingleClick "";

		if (!visibleMap) then {_leave = true};

		_positionTel =+ positionTel;
		openMap false;
		_destinationX = [markers, _positionTel] call BIS_Fnc_nearestPosition;
		if (_positionTel distance getMarkerPos _destinationX > 50) then {
			hint localize "STR_HINTS_NATOD_YMCNAMM";
			_leave = true
		}
		else {
			[[_siteX,_destinationX], "CREATE\NATOArmor.sqf"] remoteExec ["execVM", call AS_fnc_getNextWorker];
		};
	};
};

if (_typeX == "NATOCA") then {
	if ((_siteX in citiesX) or (_siteX in controlsX) or (_siteX in colinas)) then {_leave = true; hint localize "STR_HINTS_NATOD_NATOWATKOZ"};
	if (_siteX in mrkFIA) then {_leave = true; hint localize "STR_HINTS_NATOD_NATOAMBOOOAAFCZ"};
};

if (_leave) exitWith {};

if (_typeX == "NATOCA") then {
	[_siteX] remoteExec [_typeX, call AS_fnc_getNextWorker];
};
