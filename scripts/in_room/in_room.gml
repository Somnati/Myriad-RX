/// @description  in_room(name);
/// @param name
function in_room(argument0) {

	var _cur = syst_roomtrans.cur_room_id;
	if (_cur == argument0) return true;

	// ORIENTATION-AWARE (2026-09-06): a room that exists in both shapes
	// answers to EITHER id, so every in_room(rm_clicker) call in the
	// codebase is also true in rm_clicker_landscape and nothing had to
	// be rewritten. Compared as a PAIR rather than through
	// room_variant, so the answer does not depend on what the setting
	// happens to say right now - a room you are standing in is that
	// room even if the preference changed underneath you.
	var _t = room_pairs();
	for (var _i = 0; _i < array_length(_t); _i++) {
		var _e = _t[_i];
		if ((argument0 == _e.p || argument0 == _e.l)
		&&  (_cur      == _e.p || _cur      == _e.l)) return true;
	}
	return false;

}
