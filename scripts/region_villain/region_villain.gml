/// @description region_villain(dest, region) -> { name, full, fac, foe, hide, camp, col } the region's antagonist, or undefined (no dungeon or camp to hold one)
/// THE REGION'S VILLAIN (his pick, 2026-09-16): behind the faction the
/// papers name ("held by the Red Rats") stands one named thing - a name
/// rolled under the region's seed, an epithet and a rank by hash - with
/// a HIDEOUT (a dungeon / crypt / sewer, else a camp) and a LIEUTENANT'S
/// place (a camp, else another dungeon). exped_villain_card deals the
/// three-card thread (the lieutenant, the hideout, the boss);
/// g.exped.vil["seed:ri"] = the stage done (saved ex_vil). Cached on the
/// region. Never call it inside a seeded section (the name roll leaves
/// through rng_release).
function region_villain(_d, _rg) {
	// THE SEAT (q260): while it is empty there is no villain - no cards, no lord abroad, the roads quiet; after, the
	// SUCCESSOR: the n-th holder rolls its own name, epithet and rank off the seed and the count (the cache follows n)
	var _seat = seat_get(_d, _rg[$ "ri"] ?? 0), _sn = is_struct(_seat) ? _seat.n : 0;
	if (is_struct(_seat) && _seat.left > 0) { _rg.villain_c = false; _rg.villain = undefined; return undefined; }
	if ((_rg[$ "villain_c"] ?? false) && (_rg[$ "villain_n"] ?? 0) == _sn) return _rg[$ "villain"];
	_rg.villain_n = _sn;
	static _ep = ["the Hollow", "the Quiet", "Two-Knives", "the Unwashed", "of the Long Coat", "the Second", "Halfhand", "the Kind, once", "the Tall", "who Bites", "the Patient", "of the Nine Hats", "the Smiling", "the Late"];
	static _rank = ["chief", "king", "queen", "mother", "uncle", "captain", "master", "first", "eldest"];
	var _hide = [], _camps = [];
	for (var _i = 1; _i < array_length(_rg.nodes); _i++) {
		var _k = _rg.nodes[_i].kind;
		if (_k == "dungeon" || _k == "crypt" || _k == "sewer") array_push(_hide, _i);
		else if (_k == "camp") array_push(_camps, _i);
	}
	_rg.villain_c = true;
	if (array_length(_hide) == 0 && array_length(_camps) == 0) { _rg.villain = undefined; return undefined; }
	var _h = (array_length(_hide) > 0) ? _hide[hash_mix(_rg.seed, 5001) mod array_length(_hide)] : _camps[hash_mix(_rg.seed, 5001) mod array_length(_camps)];
	var _c = _h;
	if (array_length(_camps) > 0) _c = _camps[hash_mix(_rg.seed, 5002) mod array_length(_camps)];
	else if (array_length(_hide) > 1) { var _hi = 0; for (var _t = 0; _t < array_length(_hide); _t++) if (_hide[_t] == _h) _hi = _t; _c = _hide[(_hi + 1 + (hash_mix(_rg.seed, 5002) mod (array_length(_hide) - 1))) mod array_length(_hide)]; }   // (another hideout, never the same one)
	var _pp = region_node_info(_d, _rg, _h);
	var _fac = ((_pp[$ "fac"] ?? "") != "") ? _pp.fac : "the bandits", _foe = ((_pp[$ "foe"] ?? "") != "") ? _pp.foe : "bandit";
	var _rs = random_get_seed();
	random_set_seed(hash_mix(_rg.seed, 9001 + 17 * _sn));
	var _nm = str_cap(sprite_name_gen());
	rng_release(_rs);
	var _e = _ep[hash_mix(_rg.seed, 9002 + _sn) mod array_length(_ep)], _rk = _rank[hash_mix(_rg.seed, 9003 + _sn) mod array_length(_rank)];
	_rg.villain = { name : _nm + " " + _e, full : _nm + " " + _e + ", " + _rk + " of " + _fac + ((_sn > 0) ? " (the " + ((_sn == 1) ? "second" : ((_sn == 2) ? "third" : string(_sn + 1) + "th")) + " to hold it)" : ""), fac : _fac, foe : _foe, hide : _h, camp : _c, col : c_hred, n : _sn, rank : _rk };
	return _rg.villain;
}
