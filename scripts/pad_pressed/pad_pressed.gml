/// @description pad_pressed(action) - did the action go down THIS
/// step (edge, computed in begin step - any step/draw sees one
/// consistent answer).
function pad_pressed(_act) {
	if (!variable_global_exists("pad")) return false;
	var _s = g.pad.state[$ _act];
	return (_s == undefined) ? false : (_s.down && !_s.prev);
}
