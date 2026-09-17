/// @description sprite_stats(sprite) -> { pts : {hp..hit}, base : {..}, gear : {..}, abil : {..}, ab, total, cls, worn }
/// THE DERIVATION, read fresh every time (nothing stored): the class
/// shape scaled to the level's budget (40 + SPRITE_LV_PTS a level, the
/// tech demo's 40-point rule kept), plus every worn item's stat lines,
/// plus THE ABILITIES' SHARE (2026-09-17, his report: "it increases
/// defence but the defence stat doesnt change" - the pawn multiplied
/// them in on its own and the sheet never saw it): each stat lane is a
/// percent of base + gear, folded in HERE so every reader - the sheet,
/// the pawn, the odds, the strength number - sees the one number.
/// `ab` = the summed lanes (sprite_ab) for the pawn's other reads.
/// total = the sum of the eight - the sprite's own "xp worth", and the
/// number gear_score and the sheet compare.
function sprite_stats(_sp) {
	var _sh = sprite_sheet(_sp);
	var _c  = sprite_classes()[_sh.cls];
	var _keys = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit"];
	var _budget = sprite_par_pts(_sh.lv);
	var _base = {}, _gear = {}, _abil = {}, _pts = {};
	var _ab = sprite_ab(_sp);
	var _worn = [];
	if (!is_undefined(_sh.w1)) array_push(_worn, _sh.w1);
	if (!is_undefined(_sh.w2)) array_push(_worn, _sh.w2);
	for (var _i = 0; _i < array_length(_sh.armor); _i++) array_push(_worn, _sh.armor[_i]);
	for (var _i = 0; _i < array_length(_sh.talis); _i++) array_push(_worn, _sh.talis[_i]);
	var _total = 0;
	for (var _k = 0; _k < 8; _k++) {
		var _key = _keys[_k];
		var _b = _c.shape[$ _key] * _budget / 40;
		var _g = 0;
		for (var _w = 0; _w < array_length(_worn); _w++) _g += _worn[_w].pts[$ _key] ?? 0;
		if (is_struct(_sh[$ "elix"])) _g += _sh.elix[$ _key] ?? 0;   // THE ELIXIRS (2026-09-16): +1 a line each, for good - shown with the gear's green
		var _a = (_b + _g) * (_ab[$ _key] ?? 0) / 100;   // (every lane, mp's too - deep well, 2026-09-17)
		_base[$ _key] = _b;
		_gear[$ _key] = _g;
		_abil[$ _key] = _a;
		_pts[$ _key]  = _b + _g + _a;
		_total += _b + _g + _a;
	}
	return { pts : _pts, base : _base, gear : _gear, abil : _abil, ab : _ab, total : _total, cls : _c, worn : _worn };
}
