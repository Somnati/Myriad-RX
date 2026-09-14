/// @description cheat_cap() -> the total the rows may add up to. Base
/// 100 a row; the meta-track on top: CHEAT_CAP_MS per rebirth milestone
/// (the ruler under the tap room finally pays something - his note,
/// 2026-09-13) and CHEAT_CAP_RB per rebirth, to CHEAT_CAP_RB_N of them.
function cheat_cap() {
	var _n = array_length(cheat_config().rows);
	var _cap = _n * 100;
	if (variable_global_exists("rebirth")) {
		rebirth_init();
		_cap += CHEAT_CAP_MS * max(0, g.rebirth[$ "hi_ms"] ?? 0);
		_cap += CHEAT_CAP_RB * min(g.rebirth.total, CHEAT_CAP_RB_N);
	}
	return _cap;
}
