/// @description pad_rumble(strength, frames) - vibrate the ACTIVE pad
/// (g.pad.active, the last device that produced input) at `strength`
/// 0..1 for `frames` steps; pad_tick's countdown switches it off. No
/// active pad = nothing. (The gamepad bench's rumble test called this
/// from the day it was written and the script was never made - found
/// in the 2026-09-14 bug hunt.)
function pad_rumble(_s, _frames) {
	pad_init();
	var _p = g.pad;
	if (_p.active < 0) return false;
	_s = clamp(_s, 0, 1);
	gamepad_set_vibration(_p.active, _s, _s);
	_p.rumble_t = max(1, floor(_frames));
	return true;
}
