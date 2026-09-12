/// @description tiles_close() - arm the table's close; its Step eases
/// it out and destroys it (the proxies die with their owner)
function tiles_close() {
	if (!instance_exists(syst_tiles)) return;
	syst_tiles.closing = true;
}
