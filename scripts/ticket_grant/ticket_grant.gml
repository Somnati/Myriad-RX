/// @description ticket_grant([src]) -> a ticket lands on the desk.
/// THE ONE SITE tickets come from. src names the giver ("gift" /
/// "objective" / "milestone" / "away" / "ticket") and picks the rarity
/// table. Rolls off the ambient stream (the moment is the roll; the
/// ticket's SEED is its identity - ticket_roll replays the grid from it
/// deterministically, so a ticket in the pile is already what it is).
/// The first ticket ever unfolds "tickets" (the pile appears); every
/// later one gets a banner. Returns the rarity index.
/// quiet: no banner (the debug refill - settings > data > unlimited tickets)
function ticket_grant(_src = "gift", _quiet = false, _release = false) {
	ticket_init();
	// LOCKED UNTIL THE TUTORIAL IS OVER (his call, 2026-09-17): while the
	// objective chain still runs, a ticket earned is OWED - it lands on
	// the desk the moment the chain completes (ticket_release, which
	// calls back in with _release). The debug "unlimited" toggle bypasses
	// the lock, or its refill loop would never end
	var _dbg = variable_global_exists("tickets_free") && g.tickets_free;
	if (!_release && !_dbg && objective_cur() != undefined) {
		if (!is_array(g.tickets[$ "owed"])) g.tickets.owed = [];
		array_push(g.tickets.owed, _src);
		save_mark_dirty();
		return -1;
	}
	var _c = ticket_config();
	var _w = (_src == "milestone") ? _c.w_milestone : _c.w_common;
	var _tot = 0;
	for (var _i = 0; _i < array_length(_w); _i++) _tot += _w[_i];
	var _r = random(_tot), _rar = 0;
	for (var _i = 0; _i < array_length(_w); _i++) {
		if (_r < _w[_i]) { _rar = _i; break; }
		_r -= _w[_i];
	}
	g.tickets.seq += 1;
	var _seed = ((g.tickets.seq * 7919 + irandom(65535) * 131) ^ (current_time & $ffff)) & $7fffffff;
	array_push(g.tickets.pile, { seed : _seed, rar : _rar, src : _src, cells : undefined, cleared : 0 });
	var _first = !unfold_has("tickets");
	// THE FIRST TIME it is a book of three (two commons under the one
	// rolled) - one ticket teaches nothing; three teach the scratch
	if (_first) repeat (2) {
		g.tickets.seq += 1;
		array_push(g.tickets.pile, { seed : ((g.tickets.seq * 7919 + irandom(65535) * 131) ^ (current_time & $ffff)) & $7fffffff,
			rar : 0, src : _src, cells : undefined, cleared : 0 });
	}
	unfold_grant("tickets", _first ? "a book of scratch tickets is on the desk" : "");
	if (!_first && !_quiet) {
		var _rc = _c.rars[_rar];
		var _what = (_src == "away") ? "a ticket was waiting" : "+1 scratch ticket";
		assign_banner(_what + ((_rar > 0) ? " (" + _rc.name + ")" : ""), _rc.col, c_black);
	}
	save_mark_dirty();
	return _rar;
}
