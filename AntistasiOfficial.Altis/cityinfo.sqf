
private ["_textX","_dataX","_numCiv","_prestigeOPFOR","_prestigeBLUFOR","_supplyLevels","_power","_busy","_siteX","_positionTel","_garrison"];
positionTel = [];

_popFIA = 0;
_popAAF = 0;
_pop = 0;
{
_dataX = server getVariable _x;
_numCiv = _dataX select 0;
_prestigeOPFOR = _dataX select 2;
_prestigeBLUFOR = _dataX select 3;
_supplyLevels = _dataX select 4;
_popFIA = _popFIA + (_numCiv * (_prestigeBLUFOR / 100));
_popAAF = _popAAF + (_numCiv * (_prestigeOPFOR / 100));
_pop = _pop + _numCiv;
} forEach citiesX;
_popFIA = round _popFIA;
_popAAF = round _popAAF;
hint format [localize "STR_HINTS_MAP_TEXT_1",_pop, _popFIA, _popAAF, {_x in destroyedCities} count citiesX,count allunits,worldname];

openMap true;

onMapSingleClick "positionTel = _pos;";


//Plot the frontline. Sparker
[ws_frontlineSmooth, 1, false] call WS_fnc_plotGrid;
////////////////////////////////

//waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
while {visibleMap} do {
	sleep 1;
	if (count positionTel > 0) then {
		_positionTel = positionTel;
		//_siteX = [markersX, _positionTel] call BIS_Fnc_nearestPosition;
		_siteX = [markers, _positionTel] call BIS_Fnc_nearestPosition; //Sparker
		_textX = "Click on a zone";
		if (_siteX == "FIA_HQ") then {
			_textX = format ["FIA HQ%1",[_siteX] call AS_fnc_getGarrisonInfo];
		};
		if (_siteX in citiesX) then {
			_dataX = server getVariable _siteX;

			_numCiv = _dataX select 0;
			_prestigeOPFOR = _dataX select 2;
			_prestigeBLUFOR = _dataX select 3;
			_supplyLevels = _dataX select 4;
			_power = [_siteX] call AS_fnc_powercheck;
			//_textX = format ["%1\n\nPop %2\nAAF Support: %3 %5\nFIA Support: %4 %5",[_siteX,false] call fn_location,_numCiv,_prestigeOPFOR,_prestigeBLUFOR,"%"];
			_textX = format ["%1\n\nPop %2\nAAF Support: %3 %5\nFIA Support: %4 %5\nFood Supply: %6\nWater Supply: %7\nFuel Supply: %8",[_siteX,false] call AS_fnc_location,_numCiv,_prestigeOPFOR,_prestigeBLUFOR,"%",_supplyLevels select 0, _supplyLevels select 1, _supplyLevels select 2];
			if (_power) then {_textX = format ["%1\nPowered",_textX]} else {_textX = format ["%1\nNot Powered",_textX]};
			//if (_siteX in mrkAAF) then {if ([_siteX] call AS_fnc_radiocheck) then {_textX = format ["%1\nRadio Comms ON",_textX]} else {_textX = format ["%1\nRadio Comms OFF",_textX]}};
		if (_siteX in destroyedCities) then {_textX = format ["%1\nDESTROYED",_textX]};
		};
		/*
		if ((_siteX in colinas) and (_siteX in mrkAAF)) then
			{
			_textX = "AAF Small Outpost";
			};
		*/
		if (_siteX in airportsX) then	{
			if (_siteX in mrkAAF) then {
				_textX = "AAF Airport";
				_busy = if (dateToNumber date > server getVariable _siteX) then {false} else {true};
				//if ([_siteX] call AS_fnc_radiocheck) then {_textX = format ["%1\n\nRadio Comms ON",_textX]} else {_textX = format ["%1\n\nRadio Comms OFF",_textX]};
				if (!_busy) then {_textX = format ["%1\nStatus: Idle",_textX]} else {_textX = format ["%1\nStatus: Busy",_textX]};
			} else {
				_textX = format ["FIA Airport%1",[_siteX] call AS_fnc_getGarrisonInfo];
			};
		};

		if (_siteX in power) then {
			if (_siteX in mrkAAF) then {
				_textX = "AAF Powerplant";
				//if ([_siteX] call AS_fnc_radiocheck) then {_textX = format ["%1\n\nRadio Comms ON",_textX]} else {_textX = format ["%1\n\nRadio Comms OFF",_textX]};
			} else {
				_textX = format ["FIA Powerplant%1",[_siteX] call AS_fnc_getGarrisonInfo];
			};
			if (_siteX in destroyedCities) then {_textX = format ["%1\nDESTROYED",_textX]};
		};

		if (_siteX in resourcesX) then {
			if (_siteX in mrkAAF) then {
				_textX = "AAF Resources";
			} else {
				_textX = format ["FIA Resources%1",[_siteX] call AS_fnc_getGarrisonInfo];
			};
			_power = [_siteX] call AS_fnc_powercheck;
			if (!_power) then {_textX = format ["%1\n\nNo Powered",_textX]} else {_textX = format ["%1\n\nPowered",_textX]};
			//if (_siteX in mrkAAF) then {if ([_siteX] call AS_fnc_radiocheck) then {_textX = format ["%1\nRadio Comms ON",_textX]} else {_textX = format ["%1\nRadio Comms OFF",_textX]}};
			if (_siteX in destroyedCities) then {_textX = format ["%1\nDESTROYED",_textX]};
			};
		if (_siteX in factories) then {
			if (_siteX in mrkAAF) then {
				_textX = "AAF Factory";
			} else {
				_textX = format ["FIA Factory%1",[_siteX] call AS_fnc_getGarrisonInfo];
			};

			_power = [_siteX] call AS_fnc_powercheck;
			if (!_power) then {_textX = format ["%1\n\nNo Powered",_textX]} else {_textX = format ["%1\n\nPowered",_textX]};
			//if (_siteX in mrkAAF) then {if ([_siteX] call AS_fnc_radiocheck) then {_textX = format ["%1\nRadio Comms ON",_textX]} else {_textX = format ["%1\nRadio Comms OFF",_textX]}};
			if (_siteX in destroyedCities) then {_textX = format ["%1\nDESTROYED",_textX]};
		};
		if (_siteX in outposts) then {
			if (_siteX in mrkAAF) then {
				_textX = "AAF Grand Outpost";
				//if ([_siteX] call AS_fnc_radiocheck) then {_textX = format ["%1\n\nRadio Comms ON",_textX]} else {_textX = format ["%1\n\nRadio Comms OFF",_textX]};
			}
			else {
				_textX = format ["FIA Grand Outpost%1",[_siteX] call AS_fnc_getGarrisonInfo];
			};
		};
		/*
		if ((_siteX in controlsX) and (_siteX in mrkAAF)) then
			{
			_textX = "AAF Roadblock";
			};
		*/
		if (_siteX in seaports) then {
			if (_siteX in mrkAAF) then {
				_textX = "AAF Seaport";
				//if ([_siteX] call AS_fnc_radiocheck) then {_textX = format ["%1\n\nRadio Comms ON",_textX]} else {_textX = format ["%1\n\nRadio Comms OFF",_textX]};
			} else {
				_textX = format ["FIA Seaport%1",[_siteX] call AS_fnc_getGarrisonInfo];
			};
		};
		if (_siteX in bases) then {
			if (_siteX in mrkAAF) then {
				_textX = "AAF Base";
				_busy = if (dateToNumber date > server getVariable _siteX) then {false} else {true};
				if ([_siteX] call AS_fnc_radiocheck) then {_textX = format ["%1\n\nRadio Comms ON",_textX]} else {_textX = format ["%1\n\nRadio Comms OFF",_textX]};
				if (!_busy) then {_textX = format ["%1\nStatus: Idle",_textX]} else {_textX = format ["%1\nStatus: Busy",_textX]};
			} else {
				_textX = format ["FIA Base%1",[_siteX] call AS_fnc_getGarrisonInfo];
			};
		};
		hint format ["%1",_textX];
	};
	positionTel = [];
};
onMapSingleClick "";

//Remove the frontline. Sparker
call WS_fnc_unplotGrid;
///////////////////////////////
