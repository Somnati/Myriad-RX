/// @description sprite_sheet_pack(sprite) -> "cls/lv/xp/sks/worn/inv/notes/learned/elixirs/title/egg/young" (the save's tail)
/// worn = "w1=item;w2=item;a=item;t=item" and inv = "item;item", an item
/// being gear_pack's "slot,lv,rar,seed". No "/" or "|" anywhere (the
/// sprite record's separators).
function sprite_sheet_pack(_sp) {
	var _sh = sprite_sheet(_sp);
	var _w = "";
	if (!is_undefined(_sh.w1)) _w += "w1=" + gear_pack(_sh.w1);
	if (!is_undefined(_sh.w2)) _w += ((_w != "") ? ";" : "") + "w2=" + gear_pack(_sh.w2);
	for (var _i = 0; _i < array_length(_sh.armor); _i++) _w += ((_w != "") ? ";" : "") + "a=" + gear_pack(_sh.armor[_i]);
	for (var _i = 0; _i < array_length(_sh.talis); _i++) _w += ((_w != "") ? ";" : "") + "t=" + gear_pack(_sh.talis[_i]);
	var _v = "";
	for (var _i = 0; _i < array_length(_sh.inv); _i++) _v += ((_i > 0) ? ";" : "") + gear_pack(_sh.inv[_i]);
	// the notepad: "tag~txt^tag~txt" (sprite_note scrubbed the separators)
	var _n = "";
	for (var _i = 0; _i < array_length(_sh.notes); _i++) _n += ((_i > 0) ? "^" : "") + _sh.notes[_i].tag + "~" + _sh.notes[_i].txt;
	// the learned skills: "tmpl:seed;tmpl:seed" (an eighth field, 2026-09-15)
	var _l = "";
	for (var _i = 0; _i < array_length(_sh.learned); _i++) _l += ((_i > 0) ? ";" : "") + string(_sh.learned[_i].tmpl) + ":" + string(_sh.learned[_i].seed);
	// the elixirs: "line:n;line:n" (a ninth field, 2026-09-16)
	var _x = "";
	if (is_struct(_sh[$ "elix"])) { var _xk = variable_struct_get_names(_sh.elix); for (var _i = 0; _i < array_length(_xk); _i++) _x += ((_i > 0) ? ";" : "") + _xk[_i] + ":" + string(_sh.elix[$ _xk[_i]]); }
	// the title (a tenth field, 2026-09-16): rank:text
	var _t = string(_sh[$ "trank"] ?? 0) + ":" + (_sh[$ "title"] ?? "");
	// the egg it keeps (an eleventh field, 2026-09-16): col~seed~hatch~word~from; and its youth (a twelfth): parent~born
	var _eg = "", _yg = "";
	if (is_struct(_sp[$ "egg"])) { var _e2 = _sp.egg; _eg = string(_e2.col) + "~" + string(_e2.seed) + "~" + string(_e2.hatch) + "~" + string_replace_all(string_replace_all(string_replace_all(_e2.word, "/", " "), "~", " "), "|", " ") + "~" + string_replace_all(string_replace_all(string_replace_all(_e2.from, "/", " "), "~", " "), "|", " "); }
	if (is_struct(_sp[$ "young"])) _yg = string(_sp.young.parent) + "~" + string(_sp.young.born);
	// its own ledger (a thirteenth field, 2026-09-17): "key:n;key:n" - sprite_led
	var _ld = "";
	if (is_struct(_sp[$ "led"])) {
		var _lk = variable_struct_get_names(_sp.led);
		for (var _i = 0; _i < array_length(_lk); _i++) _ld += ((_i > 0) ? ";" : "") + _lk[_i] + ":" + string_format(_sp.led[$ _lk[_i]], 1, 3);
	}
	// the equipped abilities (a fourteenth field, 2026-09-17): four rung indices, -1 empty
	var _ab = "";
	if (is_array(_sh[$ "abil"])) for (var _i = 0; _i < array_length(_sh.abil); _i++) _ab += ((_i > 0) ? "," : "") + string(_sh.abil[_i]);
	// "new" (a fifteenth field, 2026-09-17): an ability unlocked and not yet looked at
	return string(_sh.cls) + "/" + string(_sh.lv) + "/" + string(_sh.xp) + "/" + string(_sh.sks) + "/" + _w + "/" + _v + "/" + _n + "/" + _l + "/" + _x + "/" + _t + "/" + _eg + "/" + _yg + "/" + _ld + "/" + _ab + "/" + ((_sh[$ "abnew"] ?? false) ? "1" : "0");
}
