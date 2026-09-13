/// @description unfold_has(key) -> has this feature unfolded? "tap" is
/// the veil's own flag (g.unfold). Before the state exists, everything
/// is visible (the title screen, the boot).
function unfold_has(_key) {
	if (!variable_global_exists("unf")) return true;
	if (_key == "tap") return (!variable_global_exists("unfold")) || g.unfold >= 1;
	return g.unf.seen[$ _key] ?? false;
}
