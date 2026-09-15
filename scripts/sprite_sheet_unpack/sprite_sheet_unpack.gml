/// @description sprite_sheet_unpack(sprite, fields, at) - the sheet from the
/// sprite record's fields from index `at` (six of them; see
/// sprite_sheet_pack). A short record = a fresh sheet (sprite_sheet).
function sprite_sheet_unpack(_sp, _f, _at) {
	var _sh = sprite_sheet(_sp);
	if (array_length(_f) < _at + 6) return;
	var _ncls = array_length(sprite_classes());
	_sh.cls = clamp(real(_f[_at]), 0, _ncls - 1);
	_sh.lv  = clamp(real(_f[_at + 1]), 1, SPRITE_LV_MAX);
	_sh.xp  = max(0, real(_f[_at + 2]));
	_sh.sks = real(_f[_at + 3]);
	_sh.w1 = undefined; _sh.w2 = undefined; _sh.armor = []; _sh.talis = []; _sh.inv = [];
	if (_f[_at + 4] != "") {
		var _ws = string_split(_f[_at + 4], ";");
		for (var _i = 0; _i < array_length(_ws); _i++) {
			var _kv = string_split(_ws[_i], "=");
			if (array_length(_kv) < 2) continue;
			var _it = gear_unpack(_kv[1]);
			if (is_undefined(_it)) continue;
			switch (_kv[0]) {
				case "w1": _sh.w1 = _it; break;
				case "w2": _sh.w2 = _it; break;
				case "a":  array_push(_sh.armor, _it); break;
				case "t":  array_push(_sh.talis, _it); break;
			}
		}
	}
	if (_f[_at + 5] != "") {
		var _vs = string_split(_f[_at + 5], ";");
		for (var _i = 0; _i < array_length(_vs); _i++) { var _it = gear_unpack(_vs[_i]); if (!is_undefined(_it)) array_push(_sh.inv, _it); }
	}
	// the notepad (a seventh field; a save without one keeps an empty pad)
	_sh.notes = [];
	if (array_length(_f) > _at + 6 && _f[_at + 6] != "") {
		var _ns = string_split(_f[_at + 6], "^");
		for (var _i = 0; _i < array_length(_ns); _i++) {
			var _tt = string_split(_ns[_i], "~");
			if (array_length(_tt) < 2) continue;
			array_push(_sh.notes, { tag : _tt[0], txt : _tt[1] });
		}
	}
}
