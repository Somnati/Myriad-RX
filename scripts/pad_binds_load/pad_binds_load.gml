/// @description pad_binds_load() - overwrite pad_config() defaults
/// with saved rebinds/deadzones (settings.ini "pad"). missing keys
/// keep their defaults, so a fresh install IS pad_config(). called
/// by pad_init; also the "reset binds" path calls pad_config() fresh
/// then pad_binds_save() - never edit defaults at runtime.
function pad_binds_load() {
	if (!variable_global_exists("pad")) exit;
	var _p = g.pad;
	ini_open("settings.ini");
	for (var _i = 0; _i < array_length(_p.act_names); _i++) {
		var _nm = _p.act_names[_i];
		var _a = _p.acts[$ _nm];
		if (_a.kind == "s") continue;
		var _s = ini_read_string("pad", _nm, "");
		if (_s == "") continue;
		var _parts = string_split(_s, ";");
		var _nb = [];
		for (var _b = 0; _b < array_length(_parts); _b++) {
			var _f = string_split(_parts[_b], ":");
			if (array_length(_f) < 2) continue;
			var _bd = { k : _f[0], v : real(_f[1]) };
			if (_f[0] == "a")
				_bd = { k : "a", v : real(_f[1]),
					s : (array_length(_f) > 2) ? real(_f[2]) : 1 };
			array_push(_nb, _bd);
		}
		if (array_length(_nb) > 0) _a.binds = _nb;
	}
	_p.dz = ini_read_real("pad", "__dz", _p.dz);
	_p.digi_thr = ini_read_real("pad", "__digi_thr", _p.digi_thr);
	ini_close();
}
