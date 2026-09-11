/// @description fleet_total() - the dial fleet's per-second output as
/// it is actually PAID: the summed dial curves (g.all_gps_raw) times the
/// tile table's dial profit boost (tile_dial_boost, the multiply
/// prod_dials applies to every payout). The one place that product is
/// written, so the drawer's total, the tap's syphon, the statistics
/// history and the away report all read the same number.
///
/// ...TIMES THE RUN RATE (his RAM design, 2026-09-11): the dials'
/// cycling is an automation with a speed and a throttle, so the fleet
/// PAYS at that fraction of the curves and this says so - the drawer's
/// total, the tap syphon and the history all follow. With the cycling
/// switched off every dial is manual and the fleet's standing rate is
/// zero (a banked cycle is the player's tap, not a rate). Result-side,
/// the adapter contract: the curves and the costs never see it.
function fleet_total() {
	if (!variable_global_exists("all_gps_raw")) return 0;
	var _raw = g.all_gps_raw;
	if (!(_raw >= arb(1))) return _raw;
	var _tb = tile_dial_boost();
	var _v = (_tb > arb(1)) ? do_multi(_raw, _tb) : _raw;
	var _run = autom_rate("run");
	if (_run <= 0) return 0;
	return (_run < 1) ? do_scale(_v, _run) : _v;
}
