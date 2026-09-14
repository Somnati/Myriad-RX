/// @description ccore_perc(lv) -> the percent a split-level lands
/// DE's cc_perc, verbatim: 100 + 50 x lv / (1 + .05 (lv - 1)) + 10 per
/// level past ten. Steep early (a level is nearly +50%), then the
/// division flattens it to a floor of +10 a level - the curve he liked.
/// @param lv
function ccore_perc(_lv) {
	// ⚖️ DE'S cc_perc, VERBATIM (his pass, 2026-09-14: "make sure the stat
	// growth per level is the same as DE"; the 2026-09-13 reshape - +40 a
	// level then +20 plus a square - is gone). Term for term:
	//   100 + lerp(0, 1, lv/1000) + (50 / (1 + .05 (lv - 1))) x lv + 10 x max(lv - 10, 0)
	return floor((100 + lerp(0, 1, clamp(_lv / 1000, 0, 1)))
		+ ((50 / (1 + (.05 * (_lv - 1)))) * _lv)
		+ max(_lv - 10, 0) * 10);
}
