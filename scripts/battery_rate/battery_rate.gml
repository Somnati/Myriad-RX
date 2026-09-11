/// @description battery_rate() - charge gained per real second online:
/// the level-0 fill (BAT_CAP0 / BAT_FILL0) x (1 + BAT_RATE_STEP x
/// rate_lv). Does NOT scale with the capacity held (his law) - a bigger
/// battery on the same charger takes longer to fill.
function battery_rate() {
	battery_init();
	return (BAT_CAP0 / BAT_FILL0) * (1 + BAT_RATE_STEP * g.battery.rate_lv);
}
