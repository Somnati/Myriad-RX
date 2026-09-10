/// @description fleet_total() - the dial fleet's per-second output as
/// it is actually PAID: the summed dial curves (g.all_gps_raw) times the
/// tile table's dial profit boost (tile_dial_boost, the multiply
/// prod_dials applies to every payout). The one place that product is
/// written, so the drawer's total, the tap's syphon, the statistics
/// history and the away report all read the same number.
function fleet_total() {
	if (!variable_global_exists("all_gps_raw")) return 0;
	var _raw = g.all_gps_raw;
	if (!(_raw >= arb(1))) return _raw;
	var _tb = tile_dial_boost();
	return (_tb > arb(1)) ? do_multi(_raw, _tb) : _raw;
}
