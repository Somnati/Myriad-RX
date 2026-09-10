/// @description cursor_kick([amt]) - squash the pointer: the tap's
/// feedback (his ask, 2026-09-10). tap_fire calls it beside the tap
/// sound and nowhere else, so the arrow squishes exactly when a tap
/// PERFORMS - every single tap, held taps only in the money room, never
/// under an overlay. The spring in obj_cursor takes it from there.
/// @param [amt]  velocity added to the squash spring (.3 = one tap)
function cursor_kick(_amt = .3) {
	if (!instance_exists(obj_cursor)) return;
	obj_cursor.sqv += _amt;
}
