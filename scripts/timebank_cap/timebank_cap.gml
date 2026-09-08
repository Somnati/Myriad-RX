/// @description timebank_cap();
/// The bank's capacity in SECONDS, derived fresh from the knobs and
/// cap_lv - never stored:
///     minutes = tb_cap + cap_lv x tb_cap_step
/// The cap is also the banking WINDOW: away time converts on return and
/// anything past the cap is simply lost. That is deliberate - it is
/// what stops a month away from arriving as a month of x10, and it is
/// the reason the capacity upgrade is worth buying.
function timebank_cap() {
	timebank_init();
	return max(60, (g.tb_cap + g.timebank.cap_lv * g.tb_cap_step) * 60);
}
