private ["_morty","_truckX","_mortarX","_pos"];

_morty = _this select 0;
_truckX = _this select 1;
_mortarX = _this select 2;

_truckXero = driver _truckX;
_groupX = group _morty;

while {(alive _morty) and (alive _mortarX) and (canMove _truckX)} do
	{
	waitUntil {sleep 1; (!unitReady _truckXero) or (not((alive _morty) and (alive _mortarX)))};

	moveOut _morty;
	_morty assignAsCargo _truckX;
	_mortarX attachTo [_truckX,[0,-1.5,0.2]];
	_mortarX setDir (getDir _truckX + 180);

	_truckXero disableAI "MOVE";
	waitUntil {sleep 1; ((_truckX getCargoIndex _morty) != -1) or (not((alive _morty) and (alive _mortarX)))};
	_truckXero enableAI "MOVE";


	//waitUntil {sleep 1; ((unitReady _truckXero) or (!canMove _truckX) or (!alive _truckXero) and (speed _truckX == 0)) or (not((alive _morty) and (alive _mortarX)))};

	waitUntil {sleep 1; (speed _truckX == 0) or (!canMove _truckX) or (!alive _truckXero) or (not((alive _morty) and (alive _mortarX)))};

	moveOut _morty;
	detach _mortarX;
	_pos = position _truckX findEmptyPosition [1,30,"B_MBT_01_TUSK_F"];
	_mortarX setPos _pos;
	_morty assignAsGunner _mortarX;
};