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
	// THE HAZARD (2026-09-15): a bare member's cut lane comes off its total
	// (accuracy weighs more than its points: the hit curve is steep)
	var _hz = undefined;
	if (is_struct(_q)) {
		// the first hazard on any of the quest's stops (the two-stop kinds, 2026-09-15)
		var _rg = region_get(_d, _ri), _pls = exped_quest_places(_q);
		for (var _pi = 0; _pi < array_length(_pls) && is_undefined(_hz); _pi++) _hz = cbt_hazard_at(_rg.nodes[clamp(_pls[_pi], 0, array_length(_rg.nodes) - 1)].kind);
	}
	var _mine = 0;
	for (var _i = 0; _i < _n; _i++) {
		var _st = sprite_stats(_crew[_i]), _t = _st.total;
		if (is_struct(_hz) && !cbt_hazard_hold(_crew[_i], _hz).ok) _t -= _st.pts[$ _hz.lane] * (1 - _hz.f) * ((_hz.lane == "hit") ? 2.5 : 1.5);
		_mine += max(1, _t);
	}
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
			// the mission-type pass (2026-09-15)
			case "escort": _fights = 1; break;                     // (the road's bandits come with the hours below, doubled)
			case "fetch":  _fights = 1.4; break;                   // (something sits on it 40% of the time)
			case "rescue": _fights = 2; break;                     // (rooms, a third of them a fight)
			case "bounty": _fights = 1.6; break;                   // (one fight, a big one)
			case "defend": _fights = _q.n; break;
			case "survey": _fights = 1; break;
			case "gather": _fights = .5; break;
		}
		if (_q.kind == "escort") _fights += (_q[$ "hours"] ?? 0) * EXPED_ENC / 100;
		_fights += (_q[$ "hours"] ?? 0) * EXPED_ENC / 100;
	}
	return { p : power(_pf, _fights), fights : _fights, ratio : _r };
}
