/// @description pad_binds_save() - persist rebinds + deadzones to
/// settings.ini section "pad". one string per action: bindings
/// joined by ";", each "k:v" or "k:v:s" (k b/a/t, v the gp_*
/// constant's number - stable across sessions, GM constants don't
/// move). sticks aren't saved (not rebindable).
function pad_binds_save() {
	if (!variable_global_exists("pad")) exit;
	var _p = g.pad;
	ini_open("settings.ini");
	for (var _i = 0; _i < array_length(_p.act_names); _i++) {
		var _nm = _p.act_names[_i];
		var _a = _p.acts[$ _nm];
		if (_a.kind == "s") continue;
		var _s = "";
		for (var _b = 0; _b < array_length(_a.binds); _b++) {
			var _bd = _a.binds[_b];
			if (_b > 0) _s += ";";
			_s += _bd.k + ":" + string(_bd.v);
			if (_bd.k == "a") _s += ":" + string(_bd.s);
		}
		ini_write_string("pad", _nm, _s);
	}
	ini_write_real("pad", "__dz", _p.dz);
	ini_write_real("pad", "__digi_thr", _p.digi_thr);
	ini_close();
}
