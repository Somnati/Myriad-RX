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
		// a hurt sprite (routed on an expedition) naps its EXPED_NAP out, then wakes on its own
		var _h = _s[$ "hurt"] ?? 0;
		if (_h > 0) { _s.hurt = _h - _dt; if (_s.hurt <= 0) { _s.hurt = 0; _s.asleep = false; } }
		// THE CLIMB (his ask, 2026-09-15): hp and mp come back slowly - asleep
		// in SPRITE_HEAL_NAP seconds, on its feet in SPRITE_HEAL_AWAKE; a
		// sprite RESTING (asleep because it came home short) wakes when whole
		var _hpf = _s[$ "hpf"] ?? 1, _mpf = _s[$ "mpf"] ?? 1;
		if (_hpf < 1 || _mpf < 1) {
			var _rate = _dt / (_s.asleep ? SPRITE_HEAL_NAP : SPRITE_HEAL_AWAKE) * (1 + sprite_ab(_s).rest / 100);   // (second wind, 2026-09-17)
			_s.hpf = min(1, _hpf + _rate);
			_s.mpf = min(1, _mpf + _rate * 1.5);
			if ((_s[$ "resting"] ?? false) && _s.hpf >= 1 && _s.mpf >= 1) { _s.resting = false; if (_h <= 0) _s.asleep = false; }
		} else if (_s[$ "resting"] ?? false) { _s.resting = false; if (_h <= 0) _s.asleep = false; }
		if (_s[$ "trip"] ?? false) continue;   // away on an expedition: not here to tap
		var _job = _s[$ "job"] ?? "tap";
		// the dials' and the autotapper's staff are a rate (sprite_staff) -
		// nothing to tap here; the room's tapper and the tile crew tap
		if (_job != "tap" && _job != "fab" && _job != "merge") continue;
		if (_s.asleep) continue;
		// a body that is SHOWING taps through itself (you see it hop); a
		// body hidden with its room - the tile crew with the panel closed -
		// is as good as none, and works here
		if (variable_struct_exists(_s, "view") && instance_exists(_s.view) && _s.view.visible) continue;
		_s.acc += sprite_rate(_s) * _dt;
		var _n = floor(_s.acc);
		if (_n < 1) continue;
		_s.acc -= _n;
		if (_job == "tap") tap_fire(_n, 0, 0, false, true, false);
		else if (_job == "fab") tiles_fab_charge(_n * sprite_fab_frac(_s));
		else tiles_merge_charge(_n * sprite_fab_frac(_s));
		_s.taps += _n;
	}
}
