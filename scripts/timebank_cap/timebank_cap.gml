/// @description timebank_cap();
/// The bank's capacity in SECONDS, derived fresh from the knobs and
/// cap_lv - never stored:
///     minutes = tb_cap x (tb_cap_mult/100) ^ cap_lv
/// The cap is also the banking WINDOW: away time converts on return and
/// anything past the cap is simply lost. That is deliberate - it is
/// what stops a month away from arriving as a month of x10, and it is
/// the reason the capacity upgrade is worth buying.
///
/// GEOMETRIC, NOT LINEAR, and that follows from the prices being paid
/// in banked time. A price can never exceed the cap - you cannot save
/// past your own ceiling - so the prices had to become a fraction of
/// the cap, and the only thing left to carry the curve is the cap
/// itself. See timebank_upg.
function timebank_cap() {
	timebank_init();
	var _m = max(1.01, g.tb_cap_mult / 100);
	return max(60, g.tb_cap * power(_m, g.timebank.cap_lv) * 60);
}
