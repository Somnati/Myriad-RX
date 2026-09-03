/// @description rebirth_boost() - the multiplier the bank buys, as a
/// packed arb (Myriad DE's update_rebirth_boost):
///     boost = 1 + units x boost_per_unit,   boost_per_unit = 1
/// so every unit is +100% dial output. DE applies it to the DIALS'
/// per-cycle pay (update_auto's give) and NOT to the tap - the tap
/// absorbs the units directly instead (update_click adds them flat).
/// Consumers: update_dial (the one dial lane). Derived at read time,
/// never stored, so a loaded bank is live on the first resync.
function rebirth_boost() {
	rebirth_init();
	if (!(g.rebirth.units >= arb(1))) return arb(1);
	return do_add(g.rebirth.units, arb(1));
}
