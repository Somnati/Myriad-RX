/// @description sprite_xp_need(lv) -> xp from level lv to lv + 1
/// HIS LAW: SPRITE_LV_KILLS kills of a par enemy (its xp = its stat
/// total x SPRITE_XP_PER_PT). Self-similar: a level is always that many
/// par kills, so pace is fights an hour, and fighting up or down pays
/// more or less on its own.
function sprite_xp_need(_lv) {
	// (a par FOE's total - foes stand at SPRITE_FOE_BUDGET of a sprite's
	// budget, so the count is exactly SPRITE_LV_KILLS of the foes you meet)
	return round(SPRITE_LV_KILLS * sprite_par_pts(_lv) * SPRITE_FOE_BUDGET * SPRITE_XP_PER_PT);
}
