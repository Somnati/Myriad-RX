/// @description debug_scenario(sm, pick, pi) - THE DEBUG HOME (DEBUG_HOME; his ask 2026-09-18: "all planet types near me so I don't have to go hunt"), applied ONCE, here, on the kept objects - the generators know nothing of it
/// The home system (starsystem_get's kept struct, re-typed in place; the
/// rolls stand, only kind / clim / size move): a DESERT (the "dust" family,
/// a rock at clim .27) on the next planet inward from home, else outward;
/// a LAVA world (clim .10) on the innermost still free; a GAS GIANT on the
/// outermost still free - each only where the system lacks the kind; the
/// home world and the desert marked plateau (the galaxy's word, carried by
/// exped_planet_hint into planet_plateaus: a plateau on its biggest river,
/// the canyon). THE NEIGHBOURHOOD: of the eight nearest stars the kinds
/// missing (red giant, white dwarf, pulsar, black hole) go to the second
/// nearest onward (the nearest stays a plain sun), with the sizes, colours
/// and classes the kinds pass would have hashed; their kept systems, if
/// any, are forgotten so they regenerate as the great ones they are now.
/// Props live for the session (the chart is rebuilt each boot), so this
/// runs on every galaxy_home of a fresh chart. Deletable whole. q212
function debug_scenario(_sm, _pick, _pi) {
	var _st = _sm.stars[_pick], _sys = starsystem_get(_st.seed, _st.props), _pl = _sys.planets, _npl = array_length(_pl);
	if (_npl >= 4) {
		var _hp = clamp(_pi, 0, _npl - 1);
		var _used = array_create(_npl, false); _used[_hp] = true;
		var _hd = false, _hl = false, _hg = false, _di = -1;
		for (var _i = 0; _i < _npl; _i++) { if (_i == _hp) continue; var _p2 = _pl[_i];
			if (_p2.kind == "gas") { if (!_hg) { _hg = true; _used[_i] = true; } }
			else if (_p2.clim < .2) { if (!_hl) { _hl = true; _used[_i] = true; } }
			else if (_p2.clim < .35) { if (!_hd) { _hd = true; _used[_i] = true; _di = _i; } } }
		if (!_hd) { for (var _i = _hp - 1; _i >= 0 && _di < 0; _i--) if (!_used[_i]) _di = _i; for (var _i = _hp + 1; _i < _npl && _di < 0; _i++) if (!_used[_i]) _di = _i;
			if (_di >= 0) { _pl[_di].kind = "rock"; _pl[_di].clim = .27; _pl[_di].size = clamp(_pl[_di].size, 2.5, 4.6); _used[_di] = true; } }
		if (!_hl) { var _li = -1; for (var _i = 0; _i < _npl && _li < 0; _i++) if (!_used[_i]) _li = _i;
			if (_li >= 0) { _pl[_li].kind = "rock"; _pl[_li].clim = .10; _pl[_li].size = clamp(_pl[_li].size, 2.5, 4.6); _used[_li] = true; } }
		if (!_hg) { var _gi = -1; for (var _i = _npl - 1; _i >= 0 && _gi < 0; _i--) if (!_used[_i]) _gi = _i;
			if (_gi >= 0) { _pl[_gi].kind = "gas"; _pl[_gi].size = max(_pl[_gi].size, 5 + 3 * ((hash_mix(_pl[_gi].seed, 9) mod 1000) / 1000)); _pl[_gi].moon_n = max(_pl[_gi].moon_n, 2); _used[_gi] = true; } }
		_pl[_hp].plateau = true;
		if (_di >= 0) _pl[_di].plateau = true;
	}
	// the neighbourhood
	var _hx = _st.x, _hy = _st.y, _near = [];
	for (var _i = 0; _i < _sm.count; _i++) { if (_i == _pick) continue; var _st2 = _sm.stars[_i]; var _dd = point_distance(_hx, _hy, _st2.x, _st2.y); if (_dd < 400) array_push(_near, { i : _i, d : _dd }); }
	array_sort(_near, function(_a, _b) { return _a.d - _b.d; });
	var _have = { giant : false, dwarf : false, pulsar : false, hole : false };
	for (var _k = 0; _k < min(8, array_length(_near)); _k++) { var _sk = _sm.stars[_near[_k].i].props[$ "skind"] ?? "main"; if (_sk != "main") _have[$ _sk] = true; }
	var _want = ["giant", "dwarf", "pulsar", "hole"], _w = 0, _k = 1;
	while (_w < array_length(_want) && _k < array_length(_near)) {
		var _kind = _want[_w];
		if (_have[$ _kind]) { _w++; continue; }
		var _pp = _sm.stars[_near[_k].i].props, _ss = _sm.stars[_near[_k].i].seed;
		_k++;
		if ((_pp[$ "skind"] ?? "main") != "main") continue;
		var _h1 = (hash_mix(_ss, 4061) mod 1000) / 1000, _h2 = (hash_mix(_ss, 4062) mod 1000) / 1000;
		if (_kind == "giant")       { _pp.skind = "giant";  _pp.size = 3.0 + 1.6 * _h1; _pp.color = merge_colour(_pp.color, rgb(255, 128, 66), .72); _pp.stellar_class = "M III"; }
		else if (_kind == "dwarf")  { _pp.skind = "dwarf";  _pp.size = .35 + .2 * _h1;  _pp.color = merge_colour(_pp.color, rgb(205, 218, 255), .8); _pp.stellar_class = "DA"; }
		else if (_kind == "pulsar") { _pp.skind = "pulsar"; _pp.size = .30 + .12 * _h1; _pp.color = merge_colour(_pp.color, rgb(235, 240, 255), .85); _pp.stellar_class = "PSR"; _pp.spin = .7 + 1.7 * _h2; _pp.tilt = 20 + 50 * _h1; }
		else                        { _pp.skind = "hole"; _pp.hole = true; _pp.size = 1.5 + 1.1 * _h1; _pp.color = merge_colour(_pp.color, (_h2 < .5) ? rgb(175, 205, 255) : rgb(255, 195, 130), .65); _pp.stellar_class = "BH"; }
		starsystem_forget(_ss);
		_have[$ _kind] = true; _w++;
	}
}
