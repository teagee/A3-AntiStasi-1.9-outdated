private ["_display","_childControl","_textX"];
createDialog "HQ_menu";

sleep 1;
disableSerialization;

_display = findDisplay 100;

if (activeBE) then {[] remoteExec ["fnc_BE_calcPrice", 2]};

if (str (_display) != "no display") then
{
	_childControl = _display displayCtrl 109;
	if (activeBE) then {
		_textX = format ["Current Stage: %2 \nNext Stage Training Cost: %1 €", BE_currentPrice, BE_currentStage];
	} else {
		_textX = format ["Current level: %2. Next Level Training Cost: %1 €",1000 + (1.5*((server getvariable "skillFIA") *750)),server getvariable "skillFIA"];
	};
	_childControl  ctrlSetTooltip _textX;
};