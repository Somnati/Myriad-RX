/// @description ccore_values() -> { cap_lv, gain_lv, cap, gain, mins }
/// THE ONE READ POINT: the split hands the levels out (capacity gets
/// floor(lv x split), rate the rest), each side's percent comes off
/// ccore_perc, and the well's size and fill rate follow - cap in
/// credits, gain in credits per SECOND, mins the minutes a full fill
/// takes from empty.
function ccore_values() {
	ccore_init();
	var _c   = g.ccore;
	var _cl  = floor(_c.lv * (_c.split / 100));
	var _gl  = _c.lv - _cl;
	// (x the cheat shop's two core rows, 2026-09-13 - result-side, so the
	// split's own trade is untouched)
	var _cap = ceil(CCORE_CAP0 * (ccore_perc(_cl) / 100) * cheat_rate("ccap"));
	var _gpm = (CCORE_CAP0 / CCORE_MIN0) * (ccore_perc(_gl) / 100) * cheat_rate("crate");   // credits a minute
	return { cap_lv : _cl, gain_lv : _gl, cap : _cap, gain : _gpm / 60,
	         mins : _cap / max(.0001, _gpm) };
}
