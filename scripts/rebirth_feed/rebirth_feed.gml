/// @description rebirth_feed(amount) - a gain landed in the pile: the
/// fed profit takes it times the unit growth row (give_profit's one
/// call, at the pile branch only - the offline pool feeds when it is
/// collected, at that moment's growth).
function rebirth_feed(_amt) {
	if (!(_amt >= arb(1))) return;
	rebirth_init();
	var _g = do_scale(_amt, cheat_rate("units"));
	if (!(_g >= arb(1))) return;
	g.rebirth.fed = (g.rebirth.fed >= arb(1)) ? do_add(g.rebirth.fed, _g) : _g;
}
