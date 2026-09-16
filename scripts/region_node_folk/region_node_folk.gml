/// @description region_node_folk(dest, region, ni) -> the settled place's CITIZENS now: { keeper, trader, other }, each { name, days, prev, went } - or undefined off a settled place
/// THE FOLK TURN OVER TOO (2026-09-16), slower than the leaders: a term
/// of 400-1000 real days each, its own phase, hashed off the node's seed
/// (region_node_leader's arithmetic; sprite_name_gen's hash mode - no
/// roll, safe inside a seeded deal, nothing saved). keeper = the shop's,
/// trader = the escort's merchant, other = the one who gets lost. A
/// citizen new to it (the first month) says so, and who had it before.
/// Cached on the node while the three terms hold.
function region_node_folk(_d, _rg, _ni) {
	static _went = ["retired to the coast", "died at the counter", "handed it to the eldest", "went bankrupt, cheerfully", "married out", "vanished with the stock", "moved to the city", "took up bees"];
	static _one = function(_seed, _base, _wts) {
		var _term = lerp(400, 1000, (hash_mix(_seed, _base + 1) mod 10000) / 10000) * 86400;
		var _phase = ((hash_mix(_seed, _base + 2) mod 10000) / 10000) * _term;
		var _now = universal_now() + _phase, _k = floor(_now / _term);
		var _hb = hash_mix(_seed, _base + 3);
		return { name : str_cap(sprite_name_gen(hash_mix(_hb, _k))), days : (_now - _k * _term) / 86400, k : _k, prev : str_cap(sprite_name_gen(hash_mix(_hb, max(0, _k - 1)))), went : _wts[hash_mix(_hb, _k + 7) mod array_length(_wts)] };
	};
	var _nd = _rg.nodes[_ni];
	var _kd = region_kinds()[$ _nd.kind];
	if (!(is_struct(_kd) && _kd.civ)) return undefined;
	var _seed = _rg.seed, _base = _ni * 131 + 70;
	var _kp = _one(_seed, _base, _went), _td = _one(_seed, _base + 5, _went), _ot = _one(_seed, _base + 10, _went);
	var _key = string(_kp.k) + ":" + string(_td.k) + ":" + string(_ot.k);
	if (is_struct(_nd[$ "folk_c"]) && _nd.folk_c.key == _key) { _nd.folk_c.keeper.days = _kp.days; return _nd.folk_c; }
	_nd.folk_c = { key : _key, keeper : _kp, trader : _td, other : _ot };
	return _nd.folk_c;
}
