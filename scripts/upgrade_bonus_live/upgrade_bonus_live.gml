/// @description upgrade_bonus_live();
/// WHAT THE GAME ACTUALLY APPLIES, as opposed to what the upgrade
/// screen shows you.
///
/// ⚖️ THE SYSTEM IS WIRED BUT NOT LIVE (his call, while the screen is
/// still being polished). Every consumer seat - update_click,
/// update_dial, dial_cost, credit_tick, obj_clicker, rebirth_calc -
/// calls THIS, and this returns a zeroed struct while UPG_LIVE is off.
/// So the seats stay written and reviewed, the economy is untouched,
/// and switching it on is one macro rather than six edits made from
/// memory months later.
///
/// upgrade_bonus() itself stays truthful throughout - the screen and
/// the statistics page read that one, so you can see exactly what the
/// slots WOULD be doing while they are doing nothing.
function upgrade_bonus_live() {
	if (UPG_LIVE) return upgrade_bonus();
	return {
		dial_one      : array_create(variable_global_exists("dial_total") ? g.dial_total : 13, 0),
		tap_profit    : 0,
		tap_rate      : 0,
		crit_rate     : 0,
		crit_multi    : 0,
		dial_profit   : 0,
		dial_speed    : 0,
		dial_cost     : 0,
		credit_rate   : 0,
		credit_luck   : 0,
		rebirth_units : 0,
		luck          : 0,
	};
}
