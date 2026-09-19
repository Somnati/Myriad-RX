/// @description moods_tick(dt) - every sprite's drives drift back to its rest by dt seconds of PLAYTIME (syst_production, every frame; the arc is watched, never skipped) (q261)
/// valence eases home in an hour and a half, arousal in forty minutes;
/// the battery refills in two hours AT HOME (a sprite out keeps its
/// tiredness); grief halves every three hours x bond / 60 and holds the
/// drive down while it stands, gone under .08; a reason is kept three hours
function moods_tick(_dt) {
	if (!variable_global_exists("sprites") || !is_array(g.sprites) || _dt <= 0) return;
	var _now = g[$ "time_played_active"] ?? 0;
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _sp = g.sprites[_i], _m = _sp[$ "mood"];
		if (!is_struct(_m)) continue;   // (at rest until something happens - nothing to move)
		var _b = mood_base(_sp);
		_m.v += (_b.v - _m.v) * min(1, _dt / MOOD_TAU_V);
		_m.a += (_b.a - _m.a) * min(1, _dt / MOOD_TAU_A);
		if (!(_sp[$ "trip"] ?? false)) _m.e += (1 - _m.e) * min(1, _dt / MOOD_TAU_E);
		if (is_struct(_m.lost)) {
			_m.lost.g *= exp(-_dt * 0.693 / (MOOD_TAU_G * max(.3, _m.lost.bond / 60)));
			if (_m.lost.g < .08) _m.lost = undefined;
			else _m.v = min(_m.v, _b.v - .6 * _m.lost.g);
		}
		if (_m.why != "" && _now - _m.why_t > 10800) _m.why = "";
	}
}
