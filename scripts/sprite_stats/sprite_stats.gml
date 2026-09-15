/// @description sprite_stats(sprite) -> { pts : {hp..hit}, base : {..}, gear : {..}, total, cls }
/// THE DERIVATION, read fresh every time (nothing stored): the class
/// shape scaled to the level's budget (40 + SPRITE_LV_PTS a level, the
/// tech demo's 40-point rule kept), plus every worn item's stat lines.
/// total = the sum of the eight - the sprite's own "xp worth", and the
/// number gear_score and the sheet compare.
function sprite_stats(_sp) {
	var _sh = sprite_sheet(_sp);
	var _c  = sprite_classes()[_sh.cls];
	var _keys = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit"];
	var _budget = sprite_par_pts(_sh.lv);
	var _base = {}, _gear = {}, _pts = {};
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
		_base[$ _key] = _b;
		_gear[$ _key] = _g;
		_pts[$ _key]  = _b + _g;
		_total += _b + _g;
	}
	return { pts : _pts, base : _base, gear : _gear, total : _total, cls : _c, worn : _worn };
}
