/// @description upgrade_autosell_wants(slot);
/// @param slot
/// Would the autosell get rid of what is in this slot? THE ONE RULE -
/// autom_upgrades acts on it and the automation room previews it, so
/// what the screen shows and what the runner does cannot drift.
///
/// TWO FILTERS, AND EITHER ONE IS ENOUGH. A slot goes if its RARITY is
/// switched off or if its KIND is. They are not redundant: rarity is
/// "how good is this roll", kind is "do I want this stat at all", and a
/// player who has finished with credit luck wants every credit-luck
/// roll gone however lucky it was.
///
/// IT NEVER TOUCHES A SLOT WITH TIERS IN IT. That is an investment made
/// on purpose, and a filter that liquidates it has stolen something -
/// the flags describe which OFFERS are worth a slot, not which
/// purchases were a mistake.
function upgrade_autosell_wants(_slot) {
	autom_init();
	if (!variable_global_exists("upg")) return false;
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return false;
	if (_s.tier > 0)    return false;   // bought into: not ours to sell

	var _u = g.autom.upg;
	var _r = clamp(floor(_s.rar), 0, UPG_RARITY_N - 1);
	if (_r < array_length(_u.rar))
		if (!_u.rar[_r]) return true;

	// an id the filter has never seen defaults to KEEP - a roster entry
	// added after the player configured this must not start disappearing
	// on its own
	// the toggle key is the entry's GROUP where it has one (the per-dial
	// rows share "dial_one" - see the automation panel)
	var _e  = upgrade_entry(_s.id);
	var _gk = (_e == -1) ? _s.id : (_e[$ "group"] ?? _s.id);
	return !(_u.kind[$ _gk] ?? true);
}
