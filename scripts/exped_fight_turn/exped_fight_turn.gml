/// @description exped_fight_turn(fight) - one ACTION of the fight (cbt_fight_turn)
/// The engine's turn: the ATB runs to the next pawn, it acts by the ai,
/// the fight checks for an end. Kept as the expedition's name for it -
/// the panel's [step] and the trip's clock call this.
function exped_fight_turn(_f) {
	cbt_fight_turn(_f);
}
