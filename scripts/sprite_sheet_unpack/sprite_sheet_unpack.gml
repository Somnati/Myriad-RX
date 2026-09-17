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
	// the learned skills (an eighth field). A save from the old law (skills
	// at levels 1 / 10 / 20 off the seed) keeps what it had: those rolls,
	// as learned ones
	// the elixirs (a ninth field, 2026-09-16)
	_sh.elix = {};
	if (array_length(_f) > _at + 8 && _f[_at + 8] != "") {
		var _xs = string_split(_f[_at + 8], ";");
		for (var _i = 0; _i < array_length(_xs); _i++) { var _xv = string_split(_xs[_i], ":"); if (array_length(_xv) == 2 && _xv[0] != "") _sh.elix[$ _xv[0]] = max(0, real(_xv[1])); }
	}
	// the egg it keeps (an eleventh field) and its youth (a twelfth), 2026-09-16
	_sp.egg = undefined; _sp.young = undefined;
	if (array_length(_f) > _at + 10 && _f[_at + 10] != "") { var _eq = string_split(_f[_at + 10], "~"); if (array_length(_eq) >= 5) _sp.egg = { col : real(_eq[0]), seed : real(_eq[1]), hatch : real(_eq[2]), word : _eq[3], from : _eq[4] }; }
	if (array_length(_f) > _at + 11 && _f[_at + 11] != "") { var _yq = string_split(_f[_at + 11], "~"); if (array_length(_yq) >= 2) _sp.young = { parent : real(_yq[0]), born : real(_yq[1]) }; }
	// its own ledger (a thirteenth field, 2026-09-17)
	_sp.led = {};
	if (array_length(_f) > _at + 12 && _f[_at + 12] != "") {
		var _lds = string_split(_f[_at + 12], ";");
		for (var _i = 0; _i < array_length(_lds); _i++) { var _lv2 = string_split(_lds[_i], ":"); if (array_length(_lv2) == 2 && _lv2[0] != "") _sp.led[$ _lv2[0]] = max(0, real(_lv2[1])); }
	}
	// the title (a tenth field, 2026-09-16): rank:text
	_sh.title = ""; _sh.trank = 0;
	if (array_length(_f) > _at + 9 && _f[_at + 9] != "") { var _tp = string_pos(":", _f[_at + 9]); if (_tp > 1) { _sh.trank = max(0, real(string_copy(_f[_at + 9], 1, _tp - 1))); _sh.title = string_delete(_f[_at + 9], 1, _tp); } }
	_sh.learned = [];
	if (array_length(_f) > _at + 7) {
		if (_f[_at + 7] != "") {
			var _ls = string_split(_f[_at + 7], ";");
			for (var _i = 0; _i < array_length(_ls); _i++) { var _tv = string_split(_ls[_i], ":"); if (array_length(_tv) == 2) array_push(_sh.learned, { tmpl : clamp(real(_tv[0]), 0, 4), seed : real(_tv[1]) }); }
		}
	} else {
		var _cl2 = sprite_classes()[_sh.cls];
		var _nold = clamp(1 + floor(_sh.lv / 10), 1, SPRITE_SKILLS - 1);
		for (var _i = 0; _i < _nold; _i++) array_push(_sh.learned, { tmpl : _cl2.tmpls[_i mod array_length(_cl2.tmpls)], seed : (_sh.sks + _i * 7919) & $7fffffff });
	}
}
