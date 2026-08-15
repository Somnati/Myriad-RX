/// @description pad_x(action) - a stick action's processed x, -1..1
/// (radial deadzone + saturation remap applied in pad_tick). 0 for
/// non-stick actions.
function pad_x(_act) {
	if (!variable_global_exists("pad")) return 0;
	var _s = g.pad.state[$ _act];
	return (_s == undefined) ? 0 : _s.x;
}
