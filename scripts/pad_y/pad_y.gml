/// @description pad_y(action) - a stick action's processed y, -1..1.
/// screen convention: +y = stick pulled DOWN (matches gamepad_axis_value).
function pad_y(_act) {
	if (!variable_global_exists("pad")) return 0;
	var _s = g.pad.state[$ _act];
	return (_s == undefined) ? 0 : _s.y;
}
