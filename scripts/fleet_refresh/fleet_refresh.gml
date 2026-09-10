/// @description fleet_refresh() - re-derive the fleet total and the tap
/// once a second (syst_production's clock). update_dials does both when
/// a dial CHANGES; this covers the thing that changes without a dial
/// changing - the tile table, whose output climbs on its own every
/// second and whose boost is in the total (fleet_total). Without this
/// the drawer's p/s and the tap's syphon froze at whatever the board
/// was worth the last time a level was bought.
function fleet_refresh() {
	if (!variable_global_exists("all_gps_raw")) return;
	if (!variable_global_exists("fleet_acc")) g.fleet_acc = 1;
	g.fleet_acc -= delta / 60;
	if (g.fleet_acc > 0) return;
	g.fleet_acc = 1;
	g.all_gps = fleet_total();
	update_click();
}
