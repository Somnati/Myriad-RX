/// @description pad_value(action) - analog magnitude 0..1: trigger
/// pull for "v" actions, stick length for "s", button value for "d".
function pad_value(_act) {
	if (!variable_global_exists("pad")) return 0;
	var _s = g.pad.state[$ _act];
	return (_s == undefined) ? 0 : _s.val;
}
