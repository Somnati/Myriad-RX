/// @description battery_upg(kind, [commit]) - the two credit ladders:
/// "cap" (+50% of the base capacity a level) and "rate" (+50% of the
/// base charge speed a level), each priced off ITS OWN level:
/// BAT_COST0 x BAT_COST_MULT^lv credits. commit = false is a dry quote
/// { ok, cost, lv }. Credits are the dropper's currency (the upgrade
/// table rolls with them), so the battery competes with rolls - his
/// call.
/// @param kind     "cap" / "rate"
/// @param [commit]
function battery_upg(_kind, _commit = false) {
	battery_init();
	credits_init();
	var _b  = g.battery;
	var _lv = (_kind == "cap") ? _b.cap_lv : _b.rate_lv;
	var _cost = ceil(BAT_COST0 * power(BAT_COST_MULT, _lv));
	var _ok = (g.credits >= arb(_cost));
	if (!_commit) return { ok : _ok, cost : _cost, lv : _lv };
	if (!_ok) return { ok : false, cost : _cost, lv : _lv };
	g.credits = do_subtract(g.credits, arb(_cost));
	if (_kind == "cap") _b.cap_lv  += 1;
	else                _b.rate_lv += 1;
	save_mark_dirty();
	return { ok : true, cost : _cost, lv : _lv + 1 };
}
