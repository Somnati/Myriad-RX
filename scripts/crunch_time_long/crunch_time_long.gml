function crunch_time_long(argument0) {

	_t = floor(argument0/60);
	_years = 0;
	_days = 0;
	_hours = 0;
	_minutes = 0;
	_seconds = 0;

	_years = floor(_t/31536000);
	_t -= _years*31536000;

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

	        _val = "";
			if _years > 0 _val = string_insert(_val,string(_years) + "y ",0);
	        if _days > 0 _val = string_insert(_val,string(_days) + "d ",0);
	        if _hours > 0 _val = string_insert(_val,string(_hours) + "h ",0);
	        if _minutes > 0 _val = string_insert(_val,string(_minutes) + "m ",0);
	        if _seconds > 0 _val = string_insert(_val,string(_seconds) + "s",0);

	return _val;




/* end crunch_time_long */
}
