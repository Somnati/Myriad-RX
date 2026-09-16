/// @description sprite_sheet_pack(sprite) -> "cls/lv/xp/sks/worn/inv/notes/learned" (the save's tail)
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
	return string(_sh.cls) + "/" + string(_sh.lv) + "/" + string(_sh.xp) + "/" + string(_sh.sks) + "/" + _w + "/" + _v + "/" + _n + "/" + _l + "/" + _x;
}
