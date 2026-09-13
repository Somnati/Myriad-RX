/// @description upgrade_any_owned() -> has any upgrade on the table ever
/// been bought into (tier above 0)? The first-roll nudge's job
function upgrade_any_owned() {
	if (!variable_global_exists("upg")) return false;
	for (var _k = 0; _k < array_length(g.upg.slot); _k++) {
		var _s = g.upg.slot[_k];
		if (is_struct(_s) && (_s[$ "tier"] ?? 0) > 0) return true;
	}
	return false;
}
