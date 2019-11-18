_markerX = _this select 0;
_pos = getMarkerPos _markerX;
_markerX setMarkerPos [0,0,0];
sleep 10;
_markerX setMarkerPos _pos;