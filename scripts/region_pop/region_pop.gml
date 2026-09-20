/// @description region_pop(dest, region, ni) -> { base, pop, dev, wob, trend, tau } THE POPULATION of a settled place (q284): the card's hashed baseline x a smooth wobble on the wall clock (never past POP_WOBBLE, never stored) x (1 + the event deviation, g.exped.pop); trend -1 / 0 / 1 against a day ago. Undefined for a place nobody lives in
function region_pop(_d, _rg, _ni) {
	if (_ni < 0 || _ni >= array_length(_rg.nodes)) return undefined;
	var _nd = _rg.nodes[_ni], _seed = _rg.seed, _bs = _ni * 131, _base = 0, _tau = 7;
	// THE BASELINE - region_node_info's own law, so the card's "about N" and this agree
	switch (_nd.kind) {
		case "settlement": _base = 18 + (hash_mix(_seed, _bs + 1) mod 73); _tau = 10; break;
		case "village":    _base = (12 + (hash_mix(_seed, _bs + 1) mod 49)) * 10; _tau = 7; break;
		case "town":       _base = (7 + (hash_mix(_seed, _bs + 1) mod 29)) * 100; _tau = 5; break;
		case "city":       _base = (5 + (hash_mix(_seed, _bs + 1) mod 36)) * 1000; _tau = 3; break;
		default: return undefined;
	}
	// THE WOBBLE: a value noise over the days, the place's own phase - smooth, bounded, free
	var _wobf = function(_s, _b, _t) {
		var _i = floor(_t), _f = _t - _i; _f = _f * _f * (3 - 2 * _f);
		var _n0 = (hash_mix(_s, _b + 9000 + _i) mod 1000) / 1000, _n1 = (hash_mix(_s, _b + 9001 + _i) mod 1000) / 1000;
		return 1 + POP_WOBBLE * (lerp(_n0, _n1, _f) - .5) * 2;
	};
	var _t = universal_now() / 86400 + (hash_mix(_seed, _bs + 5) mod 1000) / 1000;
	var _wob = _wobf(_seed, _bs, _t), _wob1 = _wobf(_seed, _bs, _t - 1);
	// THE DEVIATION: the record, if the place was pushed
	var _dev = 0;
	if (variable_global_exists("exped") && is_struct(g.exped[$ "pop"])) { var _r = g.exped.pop[$ lane_key(_d, _rg[$ "ri"] ?? 0) + ":" + string(_ni)]; if (is_struct(_r)) _dev = clamp(_r.d, -POP_DEV_MAX, POP_DEV_MAX); }
	var _dev1 = clamp(_dev * exp(1 / _tau), -POP_DEV_MAX, POP_DEV_MAX);   // (a day ago the deviation was larger - it decays)
	var _pop = max(1, round(_base * _wob * (1 + _dev))), _pop1 = max(1, round(_base * _wob1 * (1 + _dev1)));
	var _trend = (_pop > _pop1 * 1.005) ? 1 : ((_pop < _pop1 * .995) ? -1 : 0);
	return { base : _base, pop : _pop, dev : _dev, wob : _wob, trend : _trend, tau : _tau };
}
