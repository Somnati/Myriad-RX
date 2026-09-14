/// @description rebirth_feed(amount) - a gain landed in the pile: the
/// fed profit takes it times the unit growth row (give_profit's one
/// call, at the pile branch only - the offline pool feeds when it is
/// collected, at that moment's growth).
function rebirth_feed(_amt) {
	if (!(_amt >= arb(1))) return;
	rebirth_init();
	var _rate = cheat_rate("units");
	var _g;
	if (_rate == 1) _g = _amt;
	else if (_amt < arb(1000000)) {
		// ⚖️ SMALL GAINS IN PLAIN REALS WITH A REMAINDER (2026-09-14 bug hunt):
		// do_scale clamps anything under one to arb(1), so a 5-profit tap at
		// 10% growth fed 1 - a fifth, not a tenth - and a 1-profit tap fed
		// the whole thing. The fraction carries between gains instead
		var _v = unarb(_amt) * _rate + (g.rebirth[$ "fed_frac"] ?? 0);
		var _w = floor(_v + .000001);
		g.rebirth.fed_frac = _v - _w;
		if (_w < 1) return;
		_g = arb(_w);
	} else _g = do_scale(_amt, _rate);
	if (!(_g >= arb(1))) return;
	g.rebirth.fed = (g.rebirth.fed >= arb(1)) ? do_add(g.rebirth.fed, _g) : _g;
}
