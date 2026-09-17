/// @description rarity_remap8(old) -> the fourteen-rung index of a rarity
/// saved on DE's eight (common 0, uncommon 1, rare 2, epic 3, legendary 4,
/// elite 5, divine 6, ultimate 7). The loader calls this while
/// g.rarity_old is up - a save from before 2026-09-17 (rarity_v < 14).
function rarity_remap8(_r) {
	var _m = [1, 2, 3, 4, 9, 5, 12, 13];
	return _m[clamp(floor(_r), 0, 7)];
}
