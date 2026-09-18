/// @description cbt_fight_turn(fight) - ONE ACTION = cbt_fight_next -> cbt_ai -> cbt_fight_act (q227: the turn split in two so the arena can hold the actor between them; this wrapper is what the trips call - the same rolls, the same log): the ATB runs until
/// the next pawn crosses the threshold (solved, not stepped: the time
/// to the nearest crossing, everyone advanced by it; ties break at
/// random - the demo's shuffle), that pawn acts by the ai (a basic
/// through cbt_hit or a skill spending its mp), pays the threshold
/// back, and the fight checks for an end: every foe down = won, every
/// member down = routed. Headless and clockless - the caller decides
/// how much wall time an action takes (EXPED_FIGHT_T).
function cbt_fight_turn(_f) {
	var _actor = cbt_fight_next(_f);
	if (is_undefined(_actor)) return;
	cbt_fight_act(_f, _actor, cbt_ai(_f, _actor));
}
