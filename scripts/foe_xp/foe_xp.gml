/// @description foe_xp(pawn) -> the xp a kill pays: its stat total x SPRITE_XP_PER_PT (his law)
function foe_xp(_p) {
	return round((_p[$ "pts_total"] ?? 40) * SPRITE_XP_PER_PT);
}
