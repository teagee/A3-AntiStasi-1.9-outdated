private ["_truckX","_objectsX","_todo","_proceed","_boxX","_weaponsX","_ammunition","_items","_backpcks","_containers","_countX","_exists"];
/*
spanish to english dictionary:
truckX = truck
boxX = box
countX = count
playerX = player
*/
_playerX = _this select 0;
_truckX = vehicle _playerX;
_id = _this select 2;

if (_playerX getVariable ["loadingCrate", false]) exitWith {[petros,"hint", "Already loading a crate..."] remoteExec ["commsMP",_playerX]};

_objectsX = [];
_todo = [];
_proceed = false;
_active = false;
_counter = 0;

_objectsX = nearestObjects [_truckX, ["ReammoBox_F","Land_PlasticCase_01_medium_F"], 20];

if (count _objectsX == 0) exitWith {[petros,"hint", "No crates nearby."] remoteExec ["commsMP",_playerX]};
_boxX = _objectsX select 0;

if ((_boxX == boxX) and (player!=Slowhand)) exitWith {[petros,"hint", "Only the Commander can transfer this ammobox content to any truck"] remoteExec ["commsMP",_playerX]};


_weaponsX = weaponCargo _boxX;
_ammunition = magazineCargo _boxX;
_items = itemCargo _boxX;
_backpcks = [];

_todo = _weaponsX + _ammunition + _items + _backpcks;
_countX = count _todo;
_breakText = "";

if (_countX < 1) then
	{
	[petros,"hint", "Closest Ammobox is empty"] remoteExec ["commsMP",_playerX];
	_proceed = true;
	};

if (_countX > 0) then
	{
	if (_boxX == boxX) then
		{
		if ("DEF_HQ" in missionsX) then {_countX = round (_countX / 10)} else {_countX = round (_countX / 100)};
		}
	else
		{
		_countX = round (_countX / 5);
		};
	if (_countX < 1) then {_countX = 1};
	_countX = _countX * 10;
	_playerX setVariable ["loadingCrate", true];
	while {(_truckX == vehicle player) and (speed _truckX == 0) and (_countX > _counter)} do
		{
		if !(_active) then {
			[round ((_countX - _counter) / 10),false] remoteExec ["pBarMP",player];
			_active = true;
		};

			_counter = _counter + 1;
  			sleep 0.1;
		if !(_countX > _counter) then
			{
			[_boxX,_truckX] remoteExec ["AS_fnc_transferGear",2];
			_proceed = true;
			};
		if ((_truckX != vehicle player) or (speed _truckX != 0)) then
				{
				_proceed = true;
				};
		};

		if ((_truckX != vehicle _playerX) or (speed _truckX > 2)) then {
			_proceed = true;
			_breakText = "Transfer cancelled due to movement of Truck or Player";
		};
	};
	[0,true] remoteExec ["pBarMP",player];
	_playerX setVariable ["loadingCrate", false];

if !(_breakText == "") then {[petros,"hint", _breakText] remoteExec ["commsMP",_playerX]};