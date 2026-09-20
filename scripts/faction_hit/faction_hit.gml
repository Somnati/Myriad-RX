/// @description faction_hit(dest, ri, kind, n, [region]) -> { before, after, base, hp } or undefined - n heads off the kind's pool in this region (q283), never under FAC_FLOOR of the base (stragglers: a faction never dies, the seat brings it back); before / after = the strength either side, for the diary's line
function faction_hit(_d, _ri, _kind, _n, _rg = undefined) {
	exped_init();
	if (!is_string(_kind) || _kind == "" || _n <= 0) return undefined;
	if (!is_struct(g.exped[$ "fac"])) g.exped.fac = {};
	if (is_undefined(_rg)) _rg = region_get(_d, _ri);
	var _f = faction_get(_d, _ri, _kind, _rg), _floor = ceil(_f.base * FAC_FLOOR);
	var _hp = max(_floor, _f.hp - _n);
	g.exped.fac[$ lane_key(_d, _ri) + ":" + _kind] = { hp : _hp };
	save_mark_dirty();
	return { before : _f.str, after : clamp(_hp / max(1, _f.base), 0, 1), base : _f.base, hp : _hp };
}
