/// @description timebank_rate();
/// Banked seconds per away second - the conversion factor. Derived
/// fresh, never stored:
///     minutes per hour = tb_rate + rate_lv x tb_rate_step,
///     clamped by tb_rate_cap and by a hard 55
///
/// THE INVARIANT, and it is worth stating out loud because it is the
/// only thing keeping this mechanic honest: BANKED MINUTES PER REAL
/// HOUR STAY UNDER 60. The factor is always below 1, so an hour away
/// can never bank an hour of play and time can never multiply itself.
/// Rate upgrades raise availability; they do not break causality. The
/// hard 55 holds even if the knobs are tuned wild.
function timebank_rate() {
	timebank_init();
	var _mph = g.tb_rate + g.timebank.rate_lv * g.tb_rate_step;
	_mph = min(_mph, g.tb_rate_cap, 55);
	return max(0, _mph) / 60;
}
