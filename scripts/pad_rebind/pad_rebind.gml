/// @description pad_rebind(action, [bind_slot]) - arm rebind capture:
/// the NEXT button press / axis shove on any connected pad becomes
/// bind[slot] of the action (pad_tick does the capturing and saves).
/// arming the same action again cancels. sticks ("s") can't rebind.
/// returns true if now armed.
function pad_rebind(_act, _i = 0) {
	if (!variable_global_exists("pad")) return false;
	var _p = g.pad;
	if (_p.rebind == _act) { _p.rebind = ""; return false; } // toggle off
	var _a = _p.acts[$ _act];
	if (_a == undefined || _a.kind == "s") return false;
	_p.rebind = _act;
	_p.rebind_i = _i;
	// swallow a few frames so whatever tap ARMED this (face button on
	// a future pad-driven ui) can't capture itself
	_p.rebind_guard = 3;
	return true;
}
