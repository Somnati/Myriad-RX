/// @description ability_lane_pts(lane) -> true for a lane whose number is
/// POINTS or a FLAG (whole, no percent sign): luck, the resistances,
/// evasion, the ailment turns, loot luck, the crit points, and every
/// yes/no lane (once more, death throes, the road's flags). ability_gen
/// rounds them, ability_line prints them without a % (2026-09-17)
function ability_lane_pts(_ln) {
	static _pts = ["luck", "eva", "ail_dur", "loot", "low_crit", "cnt_crit", "once_more", "throes", "inn", "haggle", "night", "weather", "hazard"];
	if (string_pos("res_", _ln) == 1 || string_pos("immune_", _ln) == 1) return true;
	return array_contains(_pts, _ln);
}
