/// @description cheat_init([force]) - THE CHEAT SHOP's state (Disgaea's,
/// his ask 2026-09-13): one percentage per row of cheat_config, all 100
/// to begin with. Nothing else is stored - the cap derives (cheat_cap),
/// the rates derive (cheat_rate). A new game resets it; a rebirth keeps
/// it (an allocation is a preference, not progress).
function cheat_init(_force = false) {
	if (variable_global_exists("cheat") && !_force) return;
	g.cheat = { v : array_create(array_length(cheat_config().rows), 100) };
}
