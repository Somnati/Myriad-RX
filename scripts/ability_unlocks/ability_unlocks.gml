/// @description ability_unlocks() -> the level ladder of ability unlocks
/// and the tier each rung draws from. A sprite (or a foe) at level L has
/// every rung with lv <= L UNLOCKED - and because each rung's ability is
/// generated off the pawn's seed and the rung (ability_gen), the whole
/// list is derived, never stored: only the four EQUIPPED picks are saved
/// (his design, 2026-09-17: "if the ability unlocks were seeded... then
/// i could control what abilities the sprite equips").
function ability_unlocks() {
	static _l = [
		{ lv : 1,   tier : 1 }, { lv : 4,   tier : 1 }, { lv : 8,  tier : 1 },
		{ lv : 14,  tier : 2 }, { lv : 20,  tier : 2 },
		{ lv : 30,  tier : 3 }, { lv : 45,  tier : 3 }, { lv : 60, tier : 3 },
		{ lv : 80,  tier : 4 }, { lv : 100, tier : 4 },
	];
	return _l;
}
