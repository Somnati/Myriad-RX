/// @description gift_reward(slot) -> what a board slot pays at the
/// CURRENT gift level: { kind, amount, label, col, rar }. The ONE
/// derivation site - the panel's previews and gift_claim's payout both
/// read it, so what you see is what you get by construction.
///   kind 0  profit: base_secs x rarity x level SECONDS of the current
///           rate (all_gps), packed here; a run with no rate yet pays
///           floor_profit x rarity x level instead. An arb.
///   kind 1  credits: base_credits x rarity x level, whole units. A
///           plain real - credit_drop takes reals.
function gift_reward(_slot) {
	gift_init();
	var _c = g.gift_cfg;
	var _rar = _c.rars[_slot.rar];
	var _m = _rar.mult * gift_level().mult;
	if (_slot.kind == 0) {
		var _amt = 0;
		var _rate = variable_global_exists("all_gps") ? g.all_gps : 0;
		if (_rate >= arb(1)) _amt = do_scale(_rate, _c.base_secs * _m);
		if (!(_amt >= arb(_c.floor_profit * _m))) _amt = arb(max(1, round(_c.floor_profit * _m)));
		return { kind : 0, amount : _amt, label : "+" + crunch_arb(_amt) + " profit",
			col : g.profit_color, rar : _rar };
	}
	var _n = max(1, round(_c.base_credits * _m));
	return { kind : 1, amount : _n, label : "+" + string(_n) + " credits",
		col : c_lavender, rar : _rar };
}
