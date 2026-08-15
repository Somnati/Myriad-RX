/// @description pad_glyph(action, [bind_i]) - display label for an
/// action's binding, in the ACTIVE device's family dialect (xbox
/// "a" / ps "cross" / switch "b"...). sticks label as their stick.
/// "-" when unbound. UI draws THIS, never gp_* names.
function pad_glyph(_act, _bi = 0) {
	if (!variable_global_exists("pad")) return "-";
	var _p = g.pad;
	var _a = _p.acts[$ _act];
	if (_a == undefined) return "-";
	if (_a.kind == "s") return (_a.src == "l") ? "l-stick" : "r-stick";
	if (_bi >= array_length(_a.binds)) return "-";
	var _b = _a.binds[_bi];
	var _kind = "xbox";
	if (_p.active >= 0) _kind = _p.devs[_p.active].kind;
	if (_b.k == "a") {
		for (var _i = 0; _i < array_length(_p.axes); _i++)
			if (_p.axes[_i] == _b.v)
				return _p.axis_names[_i] + ((_b.s > 0) ? "+" : "-");
		return "axis?";
	}
	// buttons + triggers share the btns table
	for (var _i = 0; _i < array_length(_p.btns); _i++) {
		if (_p.btns[_i] != _b.v) continue;
		if (_kind == "ps")     return _p.glyph_ps[_i];
		if (_kind == "switch") return _p.glyph_sw[_i];
		return _p.glyph_xbox[_i]; // xbox dialect = the generic fallback
	}
	return "btn?";
}
