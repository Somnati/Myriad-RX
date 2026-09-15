/// @description exped_world_lv(dest) -> the world's level (its foes' average)
/// Until the region graph carries a recommended level (his pitch): the
/// board's tier maps to a level, three a tier, so tier 1 is level 1,
/// tier 4 is level 10. A foe rolls this or one above.
function exped_world_lv(_d) {
	return 1 + 3 * (max(1, _d.tier) - 1);
}
