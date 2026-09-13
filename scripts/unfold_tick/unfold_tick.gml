/// @description unfold_tick() - once a second (syst_production's
/// heartbeat calls it every frame; it paces itself): every unfold row
/// not yet seen is asked; the first whose need is met unfolds - seen
/// for good, its on() run, its banner shown, its key marked fresh for
/// the burger's ring. Also keeps `opened`: a panel counts as opened
/// once it has been up and gone.
function unfold_tick() {
	if (!variable_global_exists("game_started") || !g.game_started) return;
	unfold_init();
	var _u = g.unf;
	// a panel up now; the one that just went is opened
	var _ov = ui_overlay();
	if (_ov == noone && _u.last_ov != noone) {
		var _k = _u[$ "last_key"] ?? "";
		if (_k != "") _u.opened[$ _k] = true;
	}
	_u.last_ov = _ov;
	if (_ov != noone) _u.last_key = unfold_overlay_key();
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
		_u.seen[$ _r.key] = true;
		if (variable_struct_exists(_r, "on") && !is_undefined(_r.on)) _r.on();
		if (_r.banner != "") assign_banner(_r.banner, c_gold, c_black);
		if (!array_contains(_u.fresh, _r.key)) array_push(_u.fresh, _r.key);
		save_mark_dirty();
		break;   // one arrival a second - they should not pile up
	}
}
