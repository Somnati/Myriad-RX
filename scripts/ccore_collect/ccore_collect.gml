/// @description ccore_collect(x, y) -> credits paid, 0 if nothing to take
/// Empties the well into the purse (credit_drop pays and flies the
/// motes to the credit panel from x, y) and starts the cooldown: DE's
/// shape - the cooldown bar starts between half and full depending on
/// how full the well was, and drains in CCORE_COOL seconds.
/// @param x   where the motes leave from
/// @param y
function ccore_collect(_x, _y) {
	ccore_init();
	var _c = g.ccore;
	if (_c.st != 1 && _c.st != 2) return 0;
	var _n = floor(_c.xp);
	if (_n < 1) return 0;
	var _v = ccore_values();
	credit_drop(_x, _y, _n, clamp(_n, 4, 14));
	_c.cool_from = lerp(50, 100, clamp(_c.xp / max(1, _v.cap), 0, 1));
	_c.xp = _c.cool_from;
	_c.st = 3;
	save_mark_dirty();
	return _n;
}
