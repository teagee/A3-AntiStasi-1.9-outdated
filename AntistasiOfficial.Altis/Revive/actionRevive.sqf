_healed = _this select 0;
_medicX = _this select 1;

if (not("FirstAidKit" in (items _medicX))) exitWith {hint "You need a First Aid Kit to be able to revive"};

_medicX action ["HealSoldier",_healed];