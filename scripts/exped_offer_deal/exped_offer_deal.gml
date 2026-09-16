/// @description exped_offer_deal(offer, i, [easy]) - slot i re-dealt: a fresh salt, a fresh clock, nobody on it
/// Plain unless asked easy; and if no OTHER open slot is easy after the
/// deal, this one is dealt again easy (the one-easy law).
function exped_offer_deal(_of, _i, _easy = false) {
	var _sl = _of.slots[_i];
	_sl.left = exped_quest_life();
	_sl.taken = 0;
	_sl.easy = _easy;
	// VARIETY (his ask, 2026-09-15: "maybe not repeat the same locations"):
	// a place another slot already sends you to is passed over, up to
	// eight salts; the last try stands when the region is too small
	var _try = 0, _dup = false;
	do {
		_sl.salt = _of.next; _of.next += 1;
		_sl.q = is_struct(_of[$ "d"]) ? exped_quest_gen(_of.d, _sl.salt, _of.ri, _easy) : undefined;
		_try += 1;
		_dup = false;
		if (is_struct(_sl.q)) for (var _j = 0; _j < array_length(_of.slots); _j++) {
			if (_j == _i) continue;
			var _o = _of.slots[_j];
			if (is_struct(_o.q) && (_o.q[$ "p0"] ?? _o.q.node) == (_sl.q[$ "p0"] ?? _sl.q.node)) _dup = true;   // (the card's place - the first stop, 2026-09-15)
		}
	} until (!_dup || _try >= 8);
	if (!_easy && is_struct(_sl.q)) {
		var _any = false;
		for (var _j = 0; _j < array_length(_of.slots); _j++) {
			var _o = _of.slots[_j];
			if (_o.taken == 0 && is_struct(_o.q) && _o.q.diff == 0) _any = true;
		}
		if (!_any) exped_offer_deal(_of, _i, true);
	}
}
