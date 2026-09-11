/// @description battery_cap() - seconds of charge the battery holds:
/// BAT_CAP0 x (1 + BAT_CAP_STEP x cap_lv).
function battery_cap() {
	battery_init();
	return BAT_CAP0 * (1 + BAT_CAP_STEP * g.battery.cap_lv);
}
