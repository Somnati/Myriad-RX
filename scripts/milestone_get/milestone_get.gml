/// @description milestone_get(i, level) - a dial's MILESTONE STATE,
/// derived from its level on every call. Nothing is stored and
/// nothing is saved: the ladder in setgame (g.milestones) is the one
/// source, and a dial's level says which rungs it has passed.
/// Returns:
///   speed      the product of every earned speed rung (1 = none)
///   profit     the product of every earned profit rung
///   next       the next rung's level, or -1 past the top
///   next_kind  "speed" / "profit" of that rung
///   next_mult  its multiplier
///   earned     one bool per rung, in ladder order (the statistics
///              list reads this)
/// `i` is unused today - every dial climbs the same ladder - and is
/// here so a per-dial ladder later is one edit in this file, not a
/// hunt through its callers (update_dial, dial_buy, buy_resolve,
/// dial_cost, the drawer, the statistics screen).
/// Myriad DE: get_milestone / update_milestone walked a hand-written
/// call list into ~10 per-dial global arrays on every level change.
/// The rebuild is one pure function over one data array.
function milestone_get(_i, _level) {
	var _out = { speed : 1, profit : 1, next : -1, next_kind : "",
		next_mult : 1, earned : [] };
	if (!variable_global_exists("milestones")) return _out;

	var _ms = g.milestones;
	for (var _k = 0; _k < array_length(_ms); _k++) {
		var _m   = _ms[_k];
		var _got = (_level >= _m.level);
		_out.earned[_k] = _got;
		if (_got) {
			if (_m.kind == "speed")  _out.speed  *= _m.mult;
			if (_m.kind == "profit") _out.profit *= _m.mult;
		}
		else if (_out.next < 0 || _m.level < _out.next) {
			_out.next      = _m.level;
			_out.next_kind = _m.kind;
			_out.next_mult = _m.mult;
		}
	}
	return _out;
}
