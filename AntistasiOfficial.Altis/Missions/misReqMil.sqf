if (!isServer and hasInterface) exitWith {};

private ["_typeX","_posbase","_potentials","_sites","_exists","_siteX","_pos","_cityX"];

_typeX = _this select 0;

_posbase = getMarkerPos guer_respawn;
_potentials = [];
_sites = [];
_exists = false;

_excl = [posNomad];

_fnc_info = {
	params ["_text", ["_hint", "none"]];
	{
		[[["Nomad", _text]],"DIRECT",0.15] remoteExec ["createConv",_x];
		if !(_hint == "none") then {[_hint] remoteExec ["hint",_x];}
	} forEach ([15,0,position Nomad,"BLUFORSpawn"] call distanceUnits);
};

_silencio = false;
if (count _this > 1) then {_silencio = true};

if (_typeX in missionsX) exitWith {
	if (!_silencio) then {
		["I already gave you a mission of this type."] call _fnc_info;
	};
};

if ((server getVariable "milActive") > 1) exitWith {
	if (!_silencio) then {
		["How about you prove yourself first by doing what I told you to do..."] call _fnc_info;
	};
};

if (_typeX == "AS") then {
	_sites = bases + citiesX - mrkFIA;
	if (count _sites > 0) then {
		for "_i" from 0 to ((count _sites) - 1) do {
			_siteX = _sites select _i;
			_pos = getMarkerPos _siteX;
			if ((_pos distance _posbase < 4500) and (not(spawner getVariable _siteX))) then {_potentials = _potentials + [_siteX]};
		};
	};
	if (_potentials isEqualTo []) then {
		if (!_silencio) then {
			["I have no assassination missions for you. Move our HQ closer to the enemy or finish some other assassination missions in order to have better intel.", "Assasination Missions require AAF cities, Observation Posts or bases closer than 4Km from your HQ."] call _fnc_info;
		};
	}
	else {
		_ran = ((floor random 10) < 3);
		if ((count (_potentials arrayIntersect bases) > 0) && _ran) exitWith {[selectRandom (_potentials arrayIntersect bases), "mil"] remoteExec ["AS_Official", call AS_fnc_getNextWorker]};
		_siteX = _potentials call BIS_fnc_selectRandom;
		if (_siteX in citiesX) then {[_siteX, "mil"] remoteExec ["AS_specOP", call AS_fnc_getNextWorker];};
		if (_siteX in bases) then {[_siteX, "mil"] remoteExec ["AS_Official", call AS_fnc_getNextWorker];};
	};
};
/*if (_typeX == "CON") then {
	_sites = colinasAA - mrkFIA - _excl;
	if (count _sites > 0) then {
		for "_i" from 0 to ((count _sites) - 1) do {
			_siteX = _sites select _i;
			_pos = getMarkerPos _siteX;
			if ((_pos distance _posbase < 4000) and (_siteX in mrkAAF)) then {_potentials = _potentials + [_siteX]};
		};
	};
	if (_potentials isEqualTo []) then {
		if (!_silencio) then {
			["I have no Conquest missions for you. Move our HQ closer to the enemy or finish some other conquest missions in order to have better intel.", "Conquest Missions require AAF roadblocks or outposts closer than 4Km from your HQ."] call _fnc_info;
		};
	}
	else {
		_siteX = _potentials call BIS_fnc_selectRandom;
		if (_siteX in colinasAA) then {[_siteX, "mil"] remoteExec ["CON_AA", call AS_fnc_getNextWorker];};
	};
}; */  // Stef 14/09 removed conquer AA hilltop because it has no more sense.
if (_typeX == "DES") then {
	_sites = airportsX + bases - mrkFIA;
	if (count _sites > 0) then {
		for "_i" from 0 to ((count _sites) - 1) do {
			_siteX = _sites select _i;
			if (_siteX in markers) then {_pos = getMarkerPos _siteX} else {_pos = getPos _siteX};
			if (_pos distance _posbase < 4000) then {
				if (_siteX in markers) then {
					if (not(spawner getVariable _siteX)) then {_potentials = _potentials + [_siteX]};
				}
				else {
					_nearX = [markers, getPos _siteX] call BIS_fnc_nearestPosition;
					if (_nearX in mrkAAF) then {_potentials = _potentials + [_siteX]};
				};
			};
		};
	};
	if (_potentials isEqualTo []) then {
		if (!_silencio) then {
			["I have no destroy missions for you. Move our HQ closer to the enemy or finish some other destroy missions in order to have better intel.", "Destroy Missions require AAF bases, Radio Towers or airports closer than 4Km from your HQ."] call _fnc_info;
		};
	}
	else {
		_siteX = _potentials call BIS_fnc_selectRandom;
		if (_siteX in bases) then {[_siteX, "mil"] remoteExec ["DES_Vehicle", call AS_fnc_getNextWorker]};
		if (_siteX in airportsX) then {[_siteX, "mil"] remoteExec ["DES_Heli", call AS_fnc_getNextWorker]};
	};
};

if (_typeX == "CONVOY") then {
	_sites = bases + airportsX - mrkFIA;
	if (count _sites > 0) then {
		for "_i" from 0 to ((count _sites) - 1) do {
			_siteX = _sites select _i;
			_pos = getMarkerPos _siteX;
			_base = [_siteX] call AS_fnc_findBaseForConvoy;
			if ((_pos distance _posbase < 4000) and (_base !="")) then {
				_potentials = _potentials + [_siteX];
			};
		};
	};
	if (_potentials isEqualTo []) then {
		if (!_silencio) then {
			["I have no Convoy missions for you. Move our HQ closer to the enemy or finish some other rescue missions in order to have better intel.", "Convoy Missions require AAF Airports, Bases or Cities closer than 4Km from your HQ, and they must have an idle friendly base in their surroundings."] call _fnc_info;
		};
	}
	else {
		_siteX = _potentials call BIS_fnc_selectRandom;
		_base = [_siteX] call AS_fnc_findBaseForConvoy;
		[_siteX,_base,"mil"] remoteExec ["CONVOY", call AS_fnc_getNextWorker];
	};
};

if ((count _potentials > 0) and (!_silencio)) then {
	["I have a mission for you..."] call _fnc_info;
};
