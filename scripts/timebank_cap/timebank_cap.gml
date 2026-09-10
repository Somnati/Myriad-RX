/// @description timebank_cap();
/// The bank's capacity in SECONDS, derived fresh from the knobs and
/// cap_lv - never stored:
///     minutes = tb_cap + tb_cap_step x cap_lv   (+30m a level, his call)
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
	return max(60, (g.tb_cap + g.tb_cap_step * g.timebank.cap_lv) * 60);
}
