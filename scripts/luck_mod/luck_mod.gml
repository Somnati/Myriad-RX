/// @description luck_mod() -> the multiplier every chance takes, DE's g.luck_mod
/// DE's law verbatim (indiv_ps, the normal-mode branch):
///     1 + sub_sec_dim(luck, .01, .03) + .2 + .0005 x luck
/// where sub_sec_dim(lv, base, perc) = base x lv / (1 + perc (lv - 1))
///                                   + base x lv / (200 (1 + lv / 10000))
/// - a point is worth a percent at first and less each point after
/// (the 3% dimming), with a slow linear tail so it never quite stops.
/// The .2 is DE's baseline: everyone is a little lucky. 0 luck = x1.2,
/// 10 = x1.29, 100 = x1.51, 1000 = x2.07.
/// WHO ASKS: the crit chance, the credit drop chance, the dropper's
/// lucky cooldown, the upgrade table's rarity window, the tile and
/// sprite rarity rates, the wealth tier rolls - every roll_perc and
/// calculate_rarity that decides something the player wants.
function luck_mod() {
	var _l = luck_points();
	var _d = (.01 / (1 + .03 * (_l - 1))) * _l + (.01 / (200 * (1 + _l / 10000))) * _l;
	return 1 + _d + .2 + .0005 * _l;
}
