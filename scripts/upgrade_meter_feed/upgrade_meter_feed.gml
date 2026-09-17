/// @description upgrade_meter_feed(xp) - gameplay feeds the offer meter
/// (see upgrade_meter_tick). DE's feeders, ported: a tap press +1, a
/// held tap +.05, an upgrade bought a share of its price, one sold a
/// share of its refund.
function upgrade_meter_feed(_xp) {
	if (!variable_global_exists("upg")) return;
	if (_xp <= 0) return;
	g.upg.meter.uxp += _xp;
}
