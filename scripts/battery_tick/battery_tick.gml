/// @description battery_tick() - the charge, every step, in every room:
/// battery_rate per REAL second (the time bank's speed does not charge
/// it - it is your attention, not the sim's), clamped at the cap.
/// Called from syst_production's Step beside the other heartbeats.
function battery_tick() {
	battery_init();
	var _b = g.battery;
	var _cap = battery_cap();
	if (_b.charge >= _cap) { _b.charge = _cap; return; }
	_b.charge = min(_cap, _b.charge + battery_rate() * (delta / 60));
}
