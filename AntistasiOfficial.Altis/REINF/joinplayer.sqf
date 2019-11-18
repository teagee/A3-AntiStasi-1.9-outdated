_objectiveX = cursortarget;

if (!(_objectiveX isKindOf "Man")) exitWith {hint "No unit selected"};
if (count units group player > 1) exitWith {hint "Your group must be empty in order to join another one"};
if (!isPlayer _objectiveX) exitWith {hint "You must be targeting a player in order to join him"};
if ({!isPlayer _x} count units group _objectiveX > 0) exitWith {hint "Target player has AI in it's group. Only pure player groups can be joined"};
if (count units group _objectiveX > 9) exitWith {hint "Target group is full"};
if (_objectiveX == Slowhand) exitWith {hint "You cannot join Slowhand group"};

removeAllActions player;
_oldUnitGroup = group player;
[player] join group _objectiveX;
deleteGroup _oldUnitGroup;
player addAction ["Leave this Group", {[] execVM "REINF\leaveplayer.sqf";},nil,0,false,true];
