if (!isServer) exitWith {};

private ["_countXFail","_textX"];

fpsTotal = 0;
fpscountX = 0;
_countXFail = 0;


while {true} do
	{
	sleep 5;
	if (fpscountX > 12) then
		{
		fpsTotal = diag_fps;
		fpscountX = 1;
		}
	else
		{
		fpsTotal = fpsTotal + diag_fps;
		fpscountX = fpscountX + 1;
		};

	//if (debug) then {Slowhand globalChat format ["FPS Av:%1.FPS Lim:%2",fpsTotal / fpscountX, minimoFPS]};
	if (diag_fps < minimoFPS) then
		{
		{if ((alive _x) and (side _x == civilian) and (diag_fps < minimoFPS) and (typeOf _x in CIV_units) && !(typeOf _x in CIV_specialUnits)) then {deleteVehicle _x; sleep 1}} forEach allUnits;
		//if (debug) then {Slowhand sideChat "Eliminados algunos civiles para incrementar FPS"};
		_countXFail = _countXFail + 1;
		if (_countXFail > 11) then
			{
			if (distanceSPWN > 1000) then
				{
				distanceSPWN = distanceSPWN - 100;
				publicVariable "distanceSPWN";
				};
			if (civPerc > 0.05) then
				{
				civPerc = civPerc - 0.01;
				publicVariable "civPerc";
				};
			if (minimoFPS > 25) then
				{
				minimoFPS = 25;
				};
			publicVariable "minimoFPS";
			_countXFail = 0;
			{if (!alive _x) then {deleteVehicle _x}} forEach vehicles;
			{deleteVehicle _x} forEach allDead;
			_textX = format ["Server has a low FPS average:\n%1\n\nGame settings changed to:\nSpawn Distance: %2 mts\nCiv. Percentage: %3 percent\nFPS Limit established at %4\n\nAll wrecked vehicles and corpses have been deleted",round (fpsTotal/fpscountX), distanceSPWN,civPerc * 100, minimoFPS];
			[[petros,"hint",_textX],"commsMP"] call BIS_fnc_MP;
			allowPlayerRecruit = false; publicVariable "allowPlayerRecruit";
			};
		}
	else
		{
		_countXFail = 0;
		if (!allowPlayerRecruit) then {allowPlayerRecruit = true; publicVariable "allowPlayerRecruit"};
		};
	};
