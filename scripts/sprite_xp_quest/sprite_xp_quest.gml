/// @description sprite_xp_quest(lv, [done]) -> a quest's xp at that level
/// His law: a par enemy's xp at the quest's level x SPRITE_QUEST_XP_LO..HI
/// by how much of the quest was done (0..1) - a full clear pays the top.
function sprite_xp_quest(_lv, _done = 1) {
	return round(sprite_par_pts(_lv) * SPRITE_FOE_BUDGET * SPRITE_XP_PER_PT * lerp(SPRITE_QUEST_XP_LO, SPRITE_QUEST_XP_HI, clamp(_done, 0, 1)));
}
