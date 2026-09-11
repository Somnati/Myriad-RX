/// @description sprites_tick() - the sprites' work outside the money
/// room (syst_sprites, every step). A sprite with a live view in the
/// money room taps THROUGH the view (you see it hop); anywhere else
/// its average rate accrues here and pays through tap_fire silently -
/// same rate, same payout law, no ceremony. Its taps are not counted
/// as yours (_stat false). An asleep sprite does nothing until poked.
function sprites_tick() {
	sprites_init();
	var _dt = delta / 60;
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _s = g.sprites[_i];
		if (_s.asleep) continue;
		if (variable_struct_exists(_s, "view") && instance_exists(_s.view)) continue;
		_s.acc += sprite_rate(_s) * _dt;
		var _n = floor(_s.acc);
		if (_n < 1) continue;
		_s.acc -= _n;
		tap_fire(_n, 0, 0, false, true, false);
		_s.taps += _n;
	}
}
