/// @description overcharge_need(lv) -> the xp a level needs to fill:
/// DE's 40 + 30 x (lv - 1). One tap is OC_XP_TAP xp, so x2 is forty
/// taps away and each level after is thirty more.
function overcharge_need(_lv) {
	return OC_XP_BASE + OC_XP_STEP * (max(1, _lv) - 1);
}
