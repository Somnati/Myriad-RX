/// @description unfold_tick() - once a second (syst_production's
/// heartbeat calls it every frame; it paces itself): every time-gated
/// row not yet seen is asked; the first whose need is met unfolds -
/// seen for good (unfold_grant: banner, "new" on its menu line), its
/// on() run. One arrival a second - they should not pile up.
function unfold_tick() {
	if (!variable_global_exists("game_started") || !g.game_started) return;
	unfold_init();
	var _u = g.unf;
	// the veil first: nothing unfolds under it
	if (!unfold_has("tap")) return;
	_u.tic -= delta;
	if (_u.tic > 0) return;
	_u.tic = 60;
	var _c = unfold_config();
	for (var _i = 0; _i < array_length(_c); _i++) {
		var _r = _c[_i];
		if (_u.seen[$ _r.key] ?? false) continue;
		if (!_r.need()) continue;
		unfold_grant(_r.key, _r.banner);
		if (variable_struct_exists(_r, "on") && !is_undefined(_r.on)) _r.on();
		break;
	}
}
