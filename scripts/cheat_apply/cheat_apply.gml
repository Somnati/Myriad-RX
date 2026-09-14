/// @description cheat_apply() - the rates changed: re-derive what is
/// cached. Dials cache gpc / cycle (update_dials, which refreshes the
/// tap after it); the table's p/s re-sums on its dirty flag; the core
/// and rebirth_calc read live.
function cheat_apply() {
	if (variable_global_exists("dial")) update_dials();
	if (variable_global_exists("tiles")) g.tiles.dirty = true;
}
