/// @description upgrade_rarity_odds();
/// THE UPGRADE TABLE'S RARITY DISTRIBUTION - an array of probabilities
/// summing to 1. upgrade_roll walks it, the statistics bar draws it and
/// the autosell filter's quick-set reads it, so the odds have exactly
/// one owner.
///
/// The ladder itself is rarity_odds, shared with the tile fabricator -
/// read that for why it is Techdemo II's band ladder rather than DE's
/// and rather than the cube law this replaced. What lives here is only
/// the upgrade table's own knobs and its luck rate.
///
/// g.upgrade_rarity slides the window: every full UPG_RARITY_CUT of it
/// retires the bottom rung, so commons stop being offered rather than
/// merely becoming unlikely. That is the case upgrade_keep_rarity's
/// percentage exists to survive.
function upgrade_rarity_odds() {
	var _rate = variable_global_exists("upgrade_rarity") ? g.upgrade_rarity : 0;
	_rate = luck_rate(_rate);   // DE's roll_upgrade: rate x luck + (luck - 1) x 100
	return rarity_odds(_rate, UPG_RARITY_SCALE, UPG_RARITY_GROW,
		UPG_RARITY_CUT, UPG_RARITY_N);
}
