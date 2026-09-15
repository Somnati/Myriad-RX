/// @description foe_xp(pawn) -> the xp a kill pays (his law, v2 2026-09-15)
/// The pawn's stat total in units of a LEVEL-1 PAR FOE'S (sprite_par_pts(1)
/// x SPRITE_FOE_BUDGET = 36 points) x SPRITE_XP_PER_PT, to a tenth: a
/// level-1 goblin pays 1.0, a level-10 one 1.7, a boss x1.4 of that. So
/// SPRITE_LV_KILLS of them at par is exactly a level (sprite_xp_need).
function foe_xp(_p) {
	var _unit = sprite_par_pts(1) * SPRITE_FOE_BUDGET;
	return round(((_p[$ "pts_total"] ?? _unit) / _unit) * SPRITE_XP_PER_PT * 10) / 10;
}
