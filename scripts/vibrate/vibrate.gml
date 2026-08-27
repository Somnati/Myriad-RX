/// @description  vibrate(mill,int);
/// @param mill
/// @param int
function vibrate() {
	_mil = 40; 
	if os_type = os_android
	    if g.haptics = true{
	if argument_count = 2 {_mil = argument[0]; _int = argument[1];} 
	if argument_count = 1 _int = argument[0];
	system.has_vibration = true;
	system.has_vibration_mill = _mil;
	system.has_vibration_int = max(system.has_vibration_int,_int);

	}



}
