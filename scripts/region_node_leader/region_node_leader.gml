/// @description region_node_leader(dest, region, ni) -> who leads a settled place or a camp NOW, and who did - or undefined (the wild has no leader)
/// LEADERS THAT CHANGE (his ask, 2026-09-16: "one day I might log in and a
/// different leader will be head of a city... track the past 2 leaders...
/// a best leader... dynamically, nothing in a save"): a place's TERM
/// (real days, by its size - settlements 60-150, villages 90-200, towns
/// 120-300, cities 180-365; a camp's chief 30-60, bounty hunters being
/// what they are) and its PHASE are hashed off its seed; the term index
/// k = floor((wall clock + phase) / term) - the universal clock, so it
/// turns while you are away and every place turns at its own moment. Term
/// k's leader is hashed off (seed, node, k): a name (sprite_name_gen's
/// hash mode - no roll, so safe anywhere), a title by size, a TRAIT, a
/// quality, and how the one before went. k-1 and k-2 are the same
/// arithmetic, so the PAST TWO cost nothing; the BEST is the highest
/// quality of the last six. Cached on the node while the term holds.
///   { name, title, trait, q, k, days (into the term), term_d, camp,
///     prev : [ { name, title, trait, q, went }, ... ], best : { name, title, q, back } }
/// THE TRAIT MATTERS (his call), at act time only - never in a deal:
///   fair       a bed cheaper, a haggle          greedy      the shelf a credit dearer, the beds too
///   martial    a bounty always on the board, +2  pious       a blessing at the gate (+10% hp), the tavern quieter
///   drunk      the tavern and the dice likelier  beloved     gratitude lasts two weeks
///   terrifying half the bar fights               asleep / forgettable   nothing
///   a chief: cruel (a bandit more), cowardly (one fewer), careless (a fatter chest); cunning / loud / quiet nothing
function region_node_leader(_d, _rg, _ni) {
	static _titles = { settlement : ["elder", "headman", "eldest"], village : ["elder", "reeve", "miller-in-chief"], town : ["reeve", "mayor", "alderman", "warden"], city : ["mayor", "burgomaster", "chair", "duke"], camp : ["chief", "captain", "boss", "knife"] };
	static _tr_civ = ["fair", "greedy", "martial", "pious", "drunk", "beloved", "terrifying", "asleep", "forgettable", "fair", "beloved", "drunk"];
	static _tr_camp = ["cruel", "cowardly", "careless", "cunning", "loud", "quiet"];
	static _went_civ = ["stepped down", "died in the frost", "ran off with the treasury", "was voted out", "is still around, disapproving", "went to the coast and did not write", "was hanged, by mistake they say", "married out", "fell off the bridge, sober", "retired to keep bees"];
	static _went_camp = ["was taken by a bounty hunter", "was hanged at the nearest town", "ran, and is still running", "was killed by their own", "went straight, they say", "is in a hole somewhere", "was sold to the mines", "was taken by a bounty hunter"];
	static _one = function(_hk, _tl, _trs, _wts) {
		return { name : str_cap(sprite_name_gen(_hk)), title : _tl[hash_mix(_hk, 3) mod array_length(_tl)], trait : _trs[hash_mix(_hk, 4) mod array_length(_trs)], q : hash_mix(_hk, 5) mod 100, went : _wts[hash_mix(_hk, 6) mod array_length(_wts)] };
	};
	var _nd = _rg.nodes[_ni];
	var _kd = region_kinds()[$ _nd.kind];
	var _camp = (_nd.kind == "camp");
	if (!_camp && !(is_struct(_kd) && _kd.civ)) return undefined;
	var _seed = _rg.seed, _base = _ni * 131 + 50;   // (the papers pick under base..base+11; 50 on is clear of them)
	var _lo, _hi;
	switch (_nd.kind) { case "settlement": _lo = 60; _hi = 150; break; case "village": _lo = 90; _hi = 200; break; case "town": _lo = 120; _hi = 300; break; case "city": _lo = 180; _hi = 365; break; default: _lo = 30; _hi = 60; break; }
	var _term = lerp(_lo, _hi, (hash_mix(_seed, _base + 1) mod 10000) / 10000) * 86400;
	var _phase = ((hash_mix(_seed, _base + 2) mod 10000) / 10000) * _term;
	var _now = universal_now() + _phase;
	var _k = floor(_now / _term);
	var _days = (_now - _k * _term) / 86400;
	if (is_struct(_nd[$ "lead_c"]) && _nd.lead_c.k == _k) { _nd.lead_c.days = _days; return _nd.lead_c; }
	var _tl = _titles[$ _nd.kind], _trs = _camp ? _tr_camp : _tr_civ, _wts = _camp ? _went_camp : _went_civ;
	var _hb = hash_mix(_seed, _base + 3);
	var _cur = _one(hash_mix(_hb, _k), _tl, _trs, _wts);
	var _prev = [ _one(hash_mix(_hb, max(0, _k - 1)), _tl, _trs, _wts), _one(hash_mix(_hb, max(0, _k - 2)), _tl, _trs, _wts) ];
	var _best = { name : _cur.name, title : _cur.title, q : _cur.q, back : 0 };
	for (var _b = 1; _b < 6; _b++) { var _o = _one(hash_mix(_hb, max(0, _k - _b)), _tl, _trs, _wts); if (_o.q > _best.q) _best = { name : _o.name, title : _o.title, q : _o.q, back : _b }; }
	_nd.lead_c = { name : _cur.name, title : _cur.title, trait : _cur.trait, q : _cur.q, k : _k, days : _days, term_d : _term / 86400, camp : _camp, prev : _prev, best : _best };
	return _nd.lead_c;
}
