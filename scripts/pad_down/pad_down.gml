/// @description pad_down(action) - is the action held this step.
/// safe before pad_init (returns false) so consumers can read
/// unconditionally.
function pad_down(_act) {
	if (!variable_global_exists("pad")) return false;
	var _s = g.pad.state[$ _act];
	return (_s == undefined) ? false : _s.down;
}
