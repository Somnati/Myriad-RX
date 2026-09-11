/// @description ram_cap() - the sticks the player holds: the base,
/// plus RAM_STEP per capacity level bought (ram_upg), plus RAM_REB per
/// rebirth banked - the long-run player stops thinking about the
/// budget, which is the intent.
function ram_cap() {
	autom_init();
	var _reb = variable_global_exists("rebirth") ? g.rebirth.total : 0;
	return RAM_BASE + g.autom.ram_lv * RAM_STEP + _reb * RAM_REB;
}
