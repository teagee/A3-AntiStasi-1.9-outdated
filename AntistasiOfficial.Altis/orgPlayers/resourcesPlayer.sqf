params ["_money"];

_money = (_money + (player getVariable ["moneyX",0])) max 0;
player setVariable ["moneyX",_money,true];
true
