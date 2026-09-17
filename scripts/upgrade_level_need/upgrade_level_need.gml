/// @description upgrade_level_need([lv]) - the xp the upgrade level needs
/// to climb past `lv` (the current one by default). Myriad DE's
/// get_upgradelevel_maxxp, verbatim:
///     adder = .15 + .2 (lv / 30)
///     need  = floor(50 (1 + adder (lv - 1)))  x (1 + .02 (lv - 1))
///             x lerp(1, .1, lv / 500)
/// - 50 at level 1, ~60 at 2, ~230 at 10, ~1560 at 30, eased late.
function upgrade_level_need(_lv = -1) {
	upgrade_init();
	if (_lv < 0) _lv = g.upg.level;
	var _adder = .15 + .2 * (_lv / 30);
	var _need  = floor(50 * (1 + _adder * (_lv - 1)));
	_need = floor(_need * (1 + .02 * (_lv - 1)));
	_need *= lerp(1, .1, clamp(_lv / 500, 0, 1));
	return max(1, floor(_need));
}
