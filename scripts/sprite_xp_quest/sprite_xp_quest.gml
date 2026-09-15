/// @description sprite_xp_quest(lv, [done], [hi]) -> a quest's xp at that level
/// His law: a par enemy's xp at the quest's level (foe_xp's unit: the
/// level-1 one pays 1) x SPRITE_QUEST_XP_LO..hi by how much of the quest
/// was done (0..1) - a full clear pays the top. hi defaults to
/// SPRITE_QUEST_XP_HI; a quest passes its own mult (exped_quest_gen's
/// difficulty x length). To a tenth.
function sprite_xp_quest(_lv, _done = 1, _hi = SPRITE_QUEST_XP_HI) {
	var _par = (sprite_par_pts(_lv) / sprite_par_pts(1)) * SPRITE_XP_PER_PT;
	return round(_par * lerp(SPRITE_QUEST_XP_LO, _hi, clamp(_done, 0, 1)) * 10) / 10;
}
