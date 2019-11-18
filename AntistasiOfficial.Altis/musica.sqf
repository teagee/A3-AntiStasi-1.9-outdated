_normalDay = ["LeadTrack01_F", "LeadTrack01a_F", "LeadTrack01b_F", "LeadTrack02_F", "AmbientTrack03_F", "BackgroundTrack01_F", "BackgroundTrack01a_F", "Track02_SolarPower"];
_normalNight = ["Track08_Night_ambient", "Track09_Night_percussions","Track11_StageB_stealth"];
_combat = ["LeadTrack03_F", "LeadTrack04_F", "LeadTrack04a_F", "LeadTrack05_F", "BackgroundTrack03_F", "Track01_Proteus", "Track07_ActionDark","Track10_StageB_action"];
_stealth = ["LeadTrack06_F", "AmbientTrack01_F", "AmbientTrack01a_F", "AmbientTrack01b_F", "AmbientTrack04a_F", "AmbientTrack04_F", "Track04_Underwater1","Track05_Underwater2"];


_stance = behaviour player;
_newstance = _stance;
exchangeMUS = true;
_song = "LeadTrack01_F";

while {musicON} do

	{
	sleep 3;
	_newstance = behaviour player;
	//hint format [localize "STR_HINTS_MUSICA", _newstance]; sleep 3;
	if ((_newstance != _stance) or (exchangeMUS)) then
		{
		removeAllMusicEventHandlers "MusicStop";
		_stance = _newstance;
		if (_newstance == "COMBAT") then
			{
			_song = _combat call BIS_Fnc_selectRandom;
			};
		if (_newstance == "STEALTH") then
			{
			_song = _stealth call BIS_Fnc_selectRandom;
			};
		if ((_newstance == "AWARE") or (_newstance == "SAFE")) then
			{
			if ((daytime > 18) or (daytime < 6)) then
				{
				_song = _normalNight call BIS_Fnc_selectRandom;
				};
			if ((daytime > 5) or (daytime < 19)) then
				{
				_song = _normalDay call BIS_Fnc_selectRandom;
				};
			};
		exchangeMUS = true;
		5 fadeMusic 0;
		};

	if (exchangeMUS) then
		{
		_EH = addMusicEventHandler ["MusicStop", {exchangeMUS = true}];
		exchangeMUS = false;
		sleep 5;
		1 fadeMusic 0.5;
		playmusic _song;
		};
	};
1 fadeMusic 0.5;
playMusic "";
