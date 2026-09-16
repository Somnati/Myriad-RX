/// @description exped_quest_finish(q, region, ri, easy) - a quest's tail filled in: done/at/who/p0, the hours by the roads, home, level, mult, reward, difficulty, place, text
/// (exped_quest_gen's tail, moved out 2026-09-16 so the personal cards - exped_quest_personal - finish the same way)
function exped_quest_finish(_q, _rg, _ri, _easy = false) {
	static _hrs = function(_rg2, _a, _b) { var _p = region_path(_rg2, _a, _b), _h = 0, _c = _a; for (var _k = 0; _k < array_length(_p); _k++) { _h += region_hours(_rg2, _c, _p[_k]); _c = _p[_k]; } return _h; };
	_q.done = 0;
	if (is_undefined(_q[$ "from"])) _q.from = -1;
	_q.at = 0;
	if (is_undefined(_q[$ "who"])) _q.who = "";
	_q.p0 = (_q.from >= 0) ? _q.from : (is_array(_q[$ "nodes"]) ? _q.nodes[0] : _q.node);
	// the length: hours by the roads from the landing zone nearest the first stop, through every stop
	var _stops = exped_quest_places(_q);
	var _home = region_nearest_landing(_rg, _stops[0]);
	var _h = 0, _c2 = _home;
	for (var _s = 0; _s < array_length(_stops); _s++) { _h += _hrs(_rg, _c2, _stops[_s]); _c2 = _stops[_s]; }
	_q.hours = _h;
	_q.home = _home;
	_q.ri = _ri;
	_q.lv = _rg.lv;
	_q.mult = clamp(_q.mult + floor(_h / 4), SPRITE_QUEST_XP_LO, SPRITE_QUEST_XP_HI);
	_q.reward = (2 + _rg.lv) * _q.mult;
	// the difficulty, in a word (the departure window): by the kind, the count, the hours
	var _df = 1;
	switch (_q.kind) {
		case "slay":  _df = (_q.n >= 6) ? 2 : ((_q.n <= 3) ? 0 : 1); break;   // (a small slay is easy - 2026-09-15)
		case "clear": case "rout": case "rescue": case "bounty": case "defend": _df = 2; break;
		case "scout": case "count": case "shop": case "nothing": _df = 0; break;
		case "well": _df = 2; break;
		default:      _df = 1; break;   // escort, fetch, survey, gather, parcel, goat, cellars
	}
	if (_h >= 6) _df += 1;
	if (_easy) _df = 0;
	_q.diff = _df;
	_q.place = _rg.nodes[_q.p0].name;   // (the card colours it by the place's kind)
	_q.diff_txt = ["easy", "fair", "hard", "grim"][clamp(_df, 0, 3)];
	_q.txt = exped_quest_txt(_q, _rg);
}
