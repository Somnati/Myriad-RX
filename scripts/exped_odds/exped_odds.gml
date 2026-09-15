/// @description exped_odds(dest, quest, crew) -> { p, fights, ratio } the chance the trip comes home unrouted
/// AN ESTIMATE for the departure window (his ask: "average chance of
/// success"), from the same numbers the fights use: the crew's stat
/// total (sprite_stats: class, level, gear) against a pack its own size
/// at the region's level x SPRITE_FOE_BUDGET. The ratio goes through a
/// logistic fitted to the twin (at par a trio wins ~77% of a 3v3, a
/// weaker crew ~35%, a much stronger one ~98%), a small edge for
/// numbers, then raised to the fights the quest is likely to take
/// (slay: two plus half the count; clear: the rooms' half; rout: two;
/// scout: one; explore: three) plus one for the road.
/// crew = an array of sprite structs (empty = no estimate: p = -1).
function exped_odds(_d, _q, _crew) {
	var _n = array_length(_crew);
	if (_n == 0) return { p : -1, fights : 0, ratio : 0 };
	var _lv = exped_world_lv(_d);
	var _mine = 0;
	for (var _i = 0; _i < _n; _i++) _mine += sprite_stats(_crew[_i]).total;
	var _theirs = _n * sprite_par_pts(_lv) * SPRITE_FOE_BUDGET;
	var _r = _mine / max(1, _theirs);
	var _pf = 1 / (1 + exp(-5.9 * (_r - .905)));
	_pf = clamp(_pf + .05 * (_n - 1), .03, .99);
	var _fights = 3;
	if (is_struct(_q)) {
		switch (_q.kind) {
			case "slay":  _fights = 2 + ceil(_q.n / max(1, _n) * .5); break;
			case "clear": _fights = max(1, ceil(_q.n * .5)); break;
			case "rout":  _fights = 2; break;
			case "scout": _fights = 1; break;
		}
		_fights += (_q[$ "hours"] ?? 0) * EXPED_ENC / 100;
	}
	return { p : power(_pf, _fights), fights : _fights, ratio : _r };
}
