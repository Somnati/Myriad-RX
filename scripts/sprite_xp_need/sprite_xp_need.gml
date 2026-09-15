/// @description sprite_xp_need(lv) -> xp from level lv to lv + 1
/// HIS LAW: SPRITE_LV_KILLS kills of a par enemy. A par enemy at level lv
/// pays par_pts(lv) / par_pts(1) x SPRITE_XP_PER_PT (foe_xp: the level-1
/// one pays 1), so level 2 is SPRITE_LV_KILLS xp away (30 - his ask,
/// 2026-09-15: "minimal starting xp requirements") and the need grows
/// only as the foes' stats do: 32 at 2, 39 at 5, 50 at 10, 73 at 20, 140
/// at 50. Self-similar: a level is always that many par kills.
function sprite_xp_need(_lv) {
	return max(1, round(SPRITE_LV_KILLS * (sprite_par_pts(_lv) / sprite_par_pts(1)) * SPRITE_XP_PER_PT));
}
