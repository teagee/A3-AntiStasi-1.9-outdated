//Clear previously spawned roadblocks

controlsXCounter = 0;

if(isServer)  then
{
	{
		if (toLower _x find "control" == 0) then
		{
	    	spawner setVariable [_x,Nil,true];
	    };
	} forEach markers;
	mrkAAF = mrkAAF - (mrkAAF select {toLower _x find "control" >= 0});
	markers = markers - controlsX;
	controlsX = [];
	publicVariable "markers";
	publicVariable "controlsX";
	publicVariable "mrkAAF";
};



_allMarkers = allMapMarkers;
{
	if (toLower _x find "control" == 0) then
	{
		deleteMarker _x;
	};
	if (toLower _x find "ws_roadblock" == 0) then
	{
		deleteMarker _x;
	};
} forEach _allMarkers;