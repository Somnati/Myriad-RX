/// @description sprite_staff(kind) -> the bonus the sprites on a machine give, 0..
/// SPRITES AS STAFF (his list, 2026-09-12): a sprite's job may be the
/// room's tapper ("tap" - the default) or one of the machines -
/// "run" (the dials' cycling), "fab", "merge", "tapper" (the
/// automation's autotapper). A sprite on a machine adds SPRITE_STAFF x
/// (1 + its rarity rung) to that machine's rate, costs no RAM, and
/// works offline (autom_rate reads this on both roads). Asleep or away
/// on an expedition it gives nothing; on a machine it does not tap the
/// room itself (sprites_tick / obj_blob check the job).
/// @param kind   "run" / "fab" / "merge" / "tapper"
function sprite_staff(_kind) {
	if (!variable_global_exists("sprites")) return 0;
	var _b = 0;
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _s = g.sprites[_i];
		if ((_s[$ "job"] ?? "tap") != _kind) continue;
		if (_s.asleep || (_s[$ "trip"] ?? false)) continue;
		_b += SPRITE_STAFF * (1 + (_s[$ "rar"] ?? 0));
	}
	return _b;
}
