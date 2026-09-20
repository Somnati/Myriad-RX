/// @description faction_get(dest, ri, kind, [region]) -> { hp, base, str } THE FACTION'S STRENGTH (q283): its heads now over its baseline - a record only once it was hit (g.exped.fac["seed:ri:kind"]), the baseline otherwise
function faction_get(_d, _ri, _kind, _rg = undefined) {
	exped_init();
	if (!is_struct(g.exped[$ "fac"])) g.exped.fac = {};
	if (is_undefined(_rg)) _rg = region_get(_d, _ri);
	var _base = faction_base(_rg, _kind), _r = g.exped.fac[$ lane_key(_d, _ri) + ":" + _kind];
	var _hp = is_struct(_r) ? clamp(_r.hp, 0, _base) : _base;
	return { hp : _hp, base : _base, str : clamp(_hp / max(1, _base), 0, 1) };
}
