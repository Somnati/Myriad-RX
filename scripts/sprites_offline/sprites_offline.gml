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
		var _n = floor(_work * sprite_rate(_s));
		_s.away = _n;
		if (_n >= 1) {
			tap_fire(_n, 0, 0, false, true, false);
			_s.taps += _n;
		}
		if (_secs > SPRITE_NAP) _s.asleep = true;
	}
}
