/// @description sprite_res(sprite) -> { fire, water, nature } - the
/// sprite's LIVE resistance table: its birth pair (cbt_res_gen off its
/// id), the worn gear's quirks (armor and talismans: "fireproof" etc.,
/// res_el / res_v) and its WARD notes (a note on an elemental kind with
/// the "ward" facet - "stood in the fire and lived" - is +res_quirk in
/// that element, once per element). Derived every read, never stored.
function sprite_res(_sp) {
	var _b = cbt_balance();
	var _r = cbt_res_gen(_sp.id);
	var _st = sprite_stats(_sp);
	for (var _w = 0; _w < array_length(_st.worn); _w++) {
		var _wi = _st.worn[_w];
		var _el = _wi[$ "res_el"] ?? "";
		if (_el != "" && variable_struct_exists(_r, _el)) _r[$ _el] += _wi[$ "res_v"] ?? 0;
	}
	var _nk = sprite_notes_kinds(_sp), _got = {};
	for (var _i = 0; _i < array_length(_nk); _i++) {
		var _p = string_split(_nk[_i], ":");
		if (array_length(_p) < 2 || _p[1] != "ward") continue;
		var _el2 = foe_kind_elem(_p[0]);
		if (_el2 == "" || variable_struct_exists(_got, _el2)) continue;
		_got[$ _el2] = true;
		_r[$ _el2] += _b.res_quirk;
	}
	_r.fire   = clamp(_r.fire,   _b.res_min, _b.res_max);
	_r.water  = clamp(_r.water,  _b.res_min, _b.res_max);
	_r.nature = clamp(_r.nature, _b.res_min, _b.res_max);
	return _r;
}
