private ["_resourcesAAF","_prestigeCSAT","_costs","_destroyedCities","_destroyed","_nameX"];

_resourcesAAF = server getVariable "resourcesAAF";
_prestigeCSAT = server getVariable "prestigeCSAT";

waitUntil {!resourcesIsChanging};
resourcesIsChanging = true;

_multiplier = 1;

if (!isMultiplayer) then {_multiplier = 2};

_countX = count (mrkFIA - outpostsFIA - ["FIA_HQ"] - citiesX);


if (_resourcesAAF > 5000) then{
	_destroyedCities = destroyedCities - mrkFIA - citiesX;
	if (count _destroyedCities > 0) then{
		{
		_destroyed = _x;
		if ((_resourcesAAF > 5000) and (not(spawner getVariable _destroyed))) then
			{
			_resourcesAAF = _resourcesAAF - 5000;
			destroyedCities = destroyedCities - [_destroyed];
			publicVariable "destroyedCities";
			[10,0,getMarkerPos _destroyed] remoteExec ["AS_fnc_changeCitySupport",2];
			[-5,0] remoteExec ["prestige",2];
			if (_destroyed in power) then {[_destroyed] call AS_fnc_powerReorg};
			_nameX = [_destroyed] call AS_fnc_localizar;
			[_nameX,{["TaskFailed", ["", format [localize "STR_NTS_REB_AAF", _this]]] call BIS_fnc_showNotification}] remoteExec ["call", 0];

			};
		} forEach _destroyedCities;
	} else {
		/*if ((count antennasDead > 0) and (not("REP" in missionsX))) then{
			{
				if ((_resourcesAAF > 5000) and (not("REP" in missionsX))) then{
					_markerX = [markers, _x] call BIS_fnc_nearestPosition;
					if ((_markerX in mrkAAF) and (not(spawner getVariable _markerX))) then {
						diag_log format ["Repairing antenna: %1", _markerX];
						[_markerX,_x] remoteExec ["REP_Antenna", call AS_fnc_getNextWorker];
						_resourcesAAF = _resourcesAAF - (5000*_multiplier);
					};
				};
			} forEach antennasDead;
		}; */ //Stef disabled repair radiotower, the mission is buggy, reduntant and pointless
	};
};

if (_countX == 0) exitWith {resourcesIsChanging = false};

if (((planesAAFcurrent < planesAAFmax) and (helisAAFcurrent > 3)) and (_countX > 6)) then {
	if (_resourcesAAF > (17500*_multiplier)) then {
		if (count indAirForce < 2) then {
			indAirForce = indAirForce + planes;
			publicVariable "indAirForce"
		};
	diag_log format ["Econ: airplanes. Current number: %1; current resources: %2", planesAAFcurrent, _resourcesAAF];
	planesAAFcurrent = planesAAFcurrent + 1;
	publicVariable "planesAAFcurrent";
	_resourcesAAF = _resourcesAAF - (17500*_multiplier);
	};
};

if (((tanksAAFcurrent < tanksAAFmax) and (APCAAFcurrent > 3)) and (_countX > 5) and (planesAAFcurrent != 0)) then {
	if (_resourcesAAF > (10000*_multiplier)) then {
		_length = count (enemyMotorpool - vehTank);
		if (_length == count enemyMotorpool) then {
			enemyMotorpool = enemyMotorpool + vehTank;
			publicVariable "enemyMotorpool";
		};
		diag_log format ["Econ: tanks. Current number: %1; current resources: %2", tanksAAFcurrent, _resourcesAAF];
		tanksAAFcurrent = tanksAAFcurrent + 1; publicVariable "tanksAAFcurrent";
	    _resourcesAAF = _resourcesAAF - (10000*_multiplier);
	};
};

if (((helisAAFcurrent < helisAAFmax) and ((helisAAFcurrent < 4) or (planesAAFcurrent > 3))) and (_countX > 3)) then {
	if (_resourcesAAF > (10000*_multiplier)) then {
		_length = count (indAirForce - heli_armed);
		if (_length == count indAirForce) then {
			indAirForce = indAirForce + heli_armed;
			publicVariable "indAirForce"
		};
		diag_log format ["Econ: helicopters. Current number: %1; current resources: %2", helisAAFcurrent, _resourcesAAF];
		helisAAFcurrent = helisAAFcurrent + 1; publicVariable "helisAAFcurrent";
		_resourcesAAF = _resourcesAAF - (7000*_multiplier);
	};
};

if ((APCAAFcurrent < APCAAFmax) and ((tanksAAFcurrent > 2) or (APCAAFcurrent < 4)) and (_countX > 2)) then {
	if (_resourcesAAF > (5000*_multiplier)) then{
		_length = count (enemyMotorpool - vehAPC);
		if (_length == count enemyMotorpool) then {
	        enemyMotorpool = enemyMotorpool +  vehAPC;
			publicVariable "enemyMotorpool";
	    };
		_length = count (enemyMotorpool - vehIFV);
	    if (_length == count enemyMotorpool) then {
	        enemyMotorpool = enemyMotorpool +  vehIFV;
			publicVariable "enemyMotorpool";
	    };
	    diag_log format ["Econ: APCs/IFVs. Current number: %1; current resources: %2", APCAAFcurrent, _resourcesAAF];
	    APCAAFcurrent = APCAAFcurrent + 1; publicVariable "APCAAFcurrent";
	    _resourcesAAF = _resourcesAAF - (5000*_multiplier);
	};
};

_skillFIA = server getVariable "skillFIA";
if ((skillAAF < (_skillFIA + 2)) && (skillAAF < 17)) then {
	_costs = 1000 + (1.5*(skillAAF *750));
	diag_log format ["Econ: AAF skill. Current level: %1; current cost: %2; current resources: %3", skillAAF, _costs, _resourcesAAF];
	if (_costs < _resourcesAAF) then {
		skillAAF = skillAAF + 1;
		publicVariable "skillAAF";
		_resourcesAAF = _resourcesAAF - _costs;
		{
			_costs = server getVariable _x;
			_costs = round (_costs + (_costs * (skillAAF/280)));
			server setVariable [_x,_costs,true];
		} forEach units_enemySoldiers;
	};
};

if (_resourcesAAF > 2000) then{
	{
		if (_resourcesAAF < 2000) exitWith {};
		if ([_x] call AS_fnc_isFrontline) then {
			_nearX = [mrkFIA,getMarkerPos _x] call BIS_fnc_nearestPosition;
			_minefieldDone = false;
			_minefieldDone = [_nearX,_x] call minefieldAAF;
			if (_minefieldDone) then {_resourcesAAF = _resourcesAAF - 2000};
			diag_log format ["Econ: minefield deployed. Location: %1; current resources: %2", _x, _resourcesAAF];
		};
	} forEach (bases - mrkFIA);
};

_resourcesAAF = round _resourcesAAF;

server setVariable ["resourcesAAF",_resourcesAAF,true];

resourcesIsChanging = false;