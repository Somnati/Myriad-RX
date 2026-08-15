/// @description  crunch_time(time"m/s");
/// @param time
function crunch_time(argument0) {
	var _t, _days, _hours, _minutes, _seconds, _val;

	_t = floor(argument0/60);
	_days = 0;
	_hours = 0;
	_minutes = 0;
	_seconds = 0;

	//days
	_days = floor(_t/86400);
	_t -= _days*86400;

	//hours
	_hours = floor(_t/3600);
	_t -= _hours*3600;

	//min
	_minutes = floor(_t/60);
	_t -= _minutes*60;

	//seconds
	_seconds = _t;

	//seconds
	_val = string(_seconds) + "s";
	//minutes
	if _minutes >= 1 _val = string(_minutes+1) + "m";
	//hours
	if _hours >= 1 _val = string(_hours+1) + "h";
	//days
	if _days >= 1 _val = string(_days+1) + "d";

	return _val;




}
