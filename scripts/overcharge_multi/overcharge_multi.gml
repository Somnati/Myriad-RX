/// @description overcharge_multi() -> what the charger multiplies a tap
/// by, a plain real: the level itself (x1 at rest, x2, x3 ... - DE's
/// tier-0 formula, 1 + (lv - 1)). update_click folds it into click_gps
/// result-side through do_scale; the readout beside the per-tap figure
/// shows the same number.
function overcharge_multi() {
	if (!variable_global_exists("overcharge_lv")) return 1;
	if (!overcharge_live()) return 1;
	return max(1, g.overcharge_lv);
}
