/// @description exped_check(trip, dc, mods, [what]) -> { roll, total, dc, ok, crit, margin, txt } - THE CHECK (q258; his ask: "mishaps could be successful on dice rolls like dnd")
/// A d20 against a difficulty, the party's modifiers added ({ name, v }
/// each - exped_fork_mods: the class that knows the country, the footing,
/// the light carried, warm gear, the luck); a natural twenty always makes
/// it (crit 1), a natural one never does (crit -1). The diary gets the
/// line as rolled: "the mountains in the rain: d20 14 +3 ranger = 17 vs
/// 15 - made it". Rolled, not hashed: a trip's rolls are live everywhere
/// (the replay rolls too - the same lawyer both ways, that is the law)
function exped_check(_tr, _dc, _mods, _what = "") {
	var _roll = irandom_range(1, 20), _sum = 0, _parts = "";
	for (var _i = 0; _i < array_length(_mods); _i++) {
		var _m = _mods[_i];
		if (_m.v == 0) continue;
		_sum += _m.v;
		_parts += " " + ((_m.v > 0) ? "+" : "") + string(_m.v) + " " + _m.name;
	}
	var _tot = _roll + _sum;
	var _crit = (_roll == 20) ? 1 : ((_roll == 1) ? -1 : 0);
	var _ok = (_crit == 1) || (_crit == 0 && _tot >= _dc);
	var _txt = ((_what != "") ? (_what + ": ") : "") + "d20 " + string(_roll) + _parts + ((_sum != 0) ? " = " + string(_tot) : "") + " vs " + string(_dc)
	           + " - " + (_ok ? ((_crit == 1) ? "a twenty" : "made it") : ((_crit == -1) ? "a one" : "failed"));
	exped_stat("checks");
	if (_ok) exped_stat("checks_made");
	return { roll : _roll, total : _tot, dc : _dc, ok : _ok, crit : _crit, margin : _tot - _dc, txt : _txt };
}
