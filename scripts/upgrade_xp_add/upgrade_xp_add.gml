/// @description upgrade_xp_add(xp) - the upgrade level's xp (DE's
/// upgrade_xp), earned by BUYING TIERS: buy_upgrade's
///     xp = (1 + rarity) x the tier just bought
/// - a rare's fifth tier pays 15, a common's first pays 1. Level-ups
/// happen here, DE's obj_upgrade_level Step: while the xp clears the
/// need, take a level and carry the rest - with DE's own quirk kept
/// (`lvtic`: the second level-up in one go is worth two levels, the
/// third three - a dump of xp climbs fast), ten rounds a call.
function upgrade_xp_add(_xp) {
	upgrade_init();
	if (_xp <= 0) return;
	g.upg.xp += _xp;
	var _lvtic = 0, _got = 0;
	repeat (10) {
		var _need = upgrade_level_need();
		if (g.upg.xp <= _need) break;
		g.upg.level += 1 + _lvtic;
		g.upg.xp    -= _need;
		_got += 1 + _lvtic;
		_lvtic += 1;
	}
	if (_got > 0) {
		assign_banner("upgrade level " + string(g.upg.level), c_gold, c_black);
		play_sound_ext(snd_ability_uncommon, .8, 1.2, .5, 1);
		save_mark_dirty();
	}
}
