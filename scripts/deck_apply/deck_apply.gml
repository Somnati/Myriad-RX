/// @description deck_apply() - the deck changed (a toggle, a discovery, a
/// load): re-derive what is CACHED off it. Dials cache gpc / cycle
/// (update_dials, which refreshes the tap's click_gps and crit figures
/// after it); the table re-sums on its dirty flag. Everything else reads
/// abi_on live at its seat.
function deck_apply() {
	if (variable_global_exists("dial")) update_dials();
	if (variable_global_exists("tiles")) g.tiles.dirty = true;
}
