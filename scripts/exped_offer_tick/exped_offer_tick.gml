/// @description exped_offer_tick(dt) - every offered quest's clock runs down by dt seconds; a slot at zero re-deals (taken or not)
/// Called by exped_tick with the clock's seconds (x the debug speed;
/// the offline replay hands it the absence, so a night away turns the
/// boards over like a night at home). An offer whose world is not on
/// the board any more (and no trip out to it) is let go.
function exped_offer_tick(_dt) {
	var _e = g.exped;
	if (!is_struct(_e[$ "offers"])) return;
	var _ks = variable_struct_get_names(_e.offers);
	for (var _k = 0; _k < array_length(_ks); _k++) {
		var _of = _e.offers[$ _ks[_k]];
		if (!is_struct(_of[$ "d"])) {
			// (a loaded offer: its world off the board, or a trip's)
			for (var _b = 0; _b < array_length(_e.board); _b++) if (_e.board[_b].seed == _of.seed) _of.d = _e.board[_b];
			if (!is_struct(_of[$ "d"])) for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _of.seed) _of.d = _e.trips[_t].dest;
			if (!is_struct(_of[$ "d"])) { variable_struct_remove(_e.offers, _ks[_k]); continue; }
		}
		exped_offer_fill(_of);
		for (var _i = 0; _i < array_length(_of.slots); _i++) {
			var _sl = _of.slots[_i];
			_sl.left -= _dt;
			// A RIVAL CREW takes an open card now and then (2026-09-16): taken = -(i + 1); never the easy one (the one-easy law)
			if (_sl.taken == 0 && !_sl.easy && random(1) < min(.35, _dt / 9000)) { _sl.taken = -(1 + irandom(2)); save_mark_dirty(); }   // (capped: an absence handed the whole board to the rivals in one tick - bug hunt 2026-09-16)
			if (_sl.left <= 0) { exped_offer_deal(_of, _i); save_mark_dirty(); }
		}
		// the personal card's clock: at zero it is gone, taken or not (2026-09-16)
		if (is_array(_of[$ "pq"])) for (var _i = array_length(_of.pq) - 1; _i >= 0; _i--) { _of.pq[_i].left -= _dt; if (_of.pq[_i].left <= 0) { array_delete(_of.pq, _i, 1); save_mark_dirty(); } }
	}
}
