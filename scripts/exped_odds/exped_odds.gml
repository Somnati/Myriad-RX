/// @description exped_odds(dest, quest, crew) -> { p, fights, ratio } the chance the trip comes home unrouted
/// AN ESTIMATE for the departure window (his ask: "average chance of
/// success"), from the same numbers the fights use: the crew's stat
/// total (sprite_stats: class, level, gear) against the average pack
/// (two) at the region's level x SPRITE_FOE_BUDGET. The ratio goes
/// through a logistic fitted to the twin's packs of one to three (at
/// par a trio wins ~93%, a pair ~68%, a solo ~30%), then raised to the
/// fights the quest is likely to take (slay: one plus the count over
/// the pack; clear: the rooms' half; rout: two; scout: one; explore:
/// three) plus the road's encounters by the hours.
/// crew = an array of sprite structs (empty = no estimate: p = -1).
function exped_odds(_d, _q, _crew, _ri = 0) {
	var _n = array_length(_crew);
	if (_n == 0) return { p : -1, fights : 0, ratio : 0 };
	var _lv = region_get(_d, _ri).lv;
	if (is_struct(_q) && !is_undefined(_q[$ "lv"])) _lv = _q.lv;
	var _mine = 0;
	for (var _i = 0; _i < _n; _i++) _mine += sprite_stats(_crew[_i]).total;
	var _theirs = 2 * sprite_par_pts(_lv) * SPRITE_FOE_BUDGET;   // the average pack is two (one to three, not the party's size)
	var _r = _mine / max(1, _theirs);
	// refit 2026-09-15 to the twin's packs of one to three: at par a solo
	// ~.3, a pair ~.68, a trio ~.93 (r .56 / 1.11 / 1.67)
	var _pf = clamp(1 / (1 + exp(-3.3 * (_r - .88))), .03, .99);
	var _fights = 3;
	if (is_struct(_q)) {
		switch (_q.kind) {
			case "slay":  _fights = 1 + ceil(_q.n / 1.9); break;   // (a hunt's packs average 1.9 of the kind)
			case "clear": _fights = max(1, ceil(_q.n * .5)); break;
			case "rout":  _fights = 2; break;
			case "scout": _fights = 1; break;
		}
		_fights += (_q[$ "hours"] ?? 0) * EXPED_ENC / 100;
	}
	return { p : power(_pf, _fights), fights : _fights, ratio : _r };
}
