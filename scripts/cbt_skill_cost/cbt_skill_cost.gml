/// @description cbt_skill_cost(pawn, skill) -> the mp the skill costs THIS pawn
/// (frugal takes its share off, never under 1) - cbt_ai's affordability
/// and cbt_fight_turn's payment read the one number (2026-09-17)
function cbt_skill_cost(_u, _s) {
	var _c = _s.cost;
	var _ab = _u[$ "ab"];
	if (is_struct(_ab) && _ab.frugal != 0) _c = max(1, ceil(_c * (1 - _ab.frugal / 100)));   // (wasteful goes the other way)
	return _c;
}
