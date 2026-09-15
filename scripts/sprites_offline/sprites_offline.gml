/// @description sprites_offline(secs) - what the sprites did while you
/// were away. UNSUPERVISED, their attention drifts: work at time t into
/// the absence is worth 1 / (1 + t / SPRITE_ATTN) of live work, which
/// integrates to T ln(1 + A / T) seconds of work over an absence A -
/// diminishing, never zero, no cliff (T = 2h: 8h away is 3.2h of work,
/// a week 9h). They are OFF the battery - free helpers - so this is
/// their own law. Paid through tap_fire in one batch (DE's one-roll
/// crit law), into the offline pool like everything else the replay
/// pays. Past SPRITE_NAP they are found asleep, and stay so until poked.
/// @param secs
function sprites_offline(_secs) {
	sprites_init();
	if (_secs < 1) return;
	var _work = SPRITE_ATTN * ln(1 + _secs / SPRITE_ATTN);
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _s = g.sprites[_i];
		// the climb, over the absence (the offline nap below is its own rule: untouched)
		if ((_s[$ "hpf"] ?? 1) < 1 || (_s[$ "mpf"] ?? 1) < 1) {
			var _hr = _secs / (_s.asleep ? SPRITE_HEAL_NAP : SPRITE_HEAL_AWAKE);
			_s.hpf = min(1, (_s[$ "hpf"] ?? 1) + _hr); _s.mpf = min(1, (_s[$ "mpf"] ?? 1) + _hr * 1.5);
		}
		if ((_s[$ "resting"] ?? false) && (_s[$ "hpf"] ?? 1) >= 1 && (_s[$ "mpf"] ?? 1) >= 1) _s.resting = false;
		// away, asleep or on a machine: no room taps from it (the machine's
		// rate carries its share through autom_rate)
		if ((_s[$ "trip"] ?? false) || _s.asleep || (_s[$ "job"] ?? "tap") != "tap") { _s.away = 0; continue; }
		var _n = floor(_work * sprite_rate(_s));
		_s.away = _n;
		if (_n >= 1) {
			tap_fire(_n, 0, 0, false, true, false);
			_s.taps += _n;
		}
		if (_secs > SPRITE_NAP) _s.asleep = true;
	}
}
