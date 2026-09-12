/// @description upgrades_close() - arm the upgrade panel's close; its
/// Step eases it out and destroys it at zero (the overlay contract)
function upgrades_close() {
	if (!instance_exists(syst_upgrades)) return;
	syst_upgrades.closing = true;
}
