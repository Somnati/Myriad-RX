/// @description autom_unpack(str) - apply a preset (autom_pack's
/// string). Every field is optional and clamped, so a preset from an
/// older roster or a hand-edited one applies what it can and leaves
/// the rest as it was. The RAM level is never touched. Returns false
/// on an empty string.
/// @param str
function autom_unpack(_s) {
	if (!is_string(_s) || _s == "") return false;
	autom_init();
	var _a = g.autom;
	var _f = string_split(_s, "/");
	for (var _i = 0; _i < array_length(_f); _i++) {
		var _kv = string_split(_f[_i], "=", false, 1);
		if (array_length(_kv) != 2) continue;
		var _k = _kv[0], _v = _kv[1];
		switch (_k) {
		case "d": {
			// the filter. a mode packed before the master row carried
			// on:pct:t per dial - the flag is still the first field, the
			// rest is read as nothing
			var _l = string_split(_v, ",");
			for (var _j = 0; _j < min(array_length(_l), array_length(_a.dial)); _j++) {
				var _q = string_split(_l[_j], ":");
				var _p = _a.dial[_j];
				_p.on  = (array_length(_q) > 0) && (_q[0] == "1");
				if (!_p.on) _p.st = 0;
			}
			break;
		}
		case "r": {
			var _l = string_split(_v, ",");
			var _r = _a.reb;
			if (array_length(_l) > 0) _r.on = (_l[0] == "1");
			if (array_length(_l) > 1) { var _q = string_split(_l[1], ":"); _r.t_on = (_q[0] == "1"); if (array_length(_q) > 1) _r.t_min = max(1, real(_q[1])); }
			if (array_length(_l) > 2) { var _q = string_split(_l[2], ":"); _r.u_on = (_q[0] == "1"); if (array_length(_q) > 1) _r.u_min = max(1, real(_q[1])); }
			if (array_length(_l) > 3) { var _q = string_split(_l[3], ":"); _r.g_on = (_q[0] == "1"); if (array_length(_q) > 1) _r.g_pct = max(1, real(_q[1])); }
			if (array_length(_l) > 4) { var _q = string_split(_l[4], ":"); _r.p_on = (_q[0] == "1"); if (array_length(_q) > 1) _r.p_oom = max(1, real(_q[1])); }
			if (array_length(_l) > 5) _r.c_on = (_l[5] == "1");
			break;
		}
		case "u": {
			var _l = string_split(_v, ",");
			var _u = _a.upg;
			if (array_length(_l) > 0) _u.roll = (_l[0] == "1");
			if (array_length(_l) > 1) _u.buy  = (_l[1] == "1");
			if (array_length(_l) > 2) _u.sell = (_l[2] == "1");
			if (array_length(_l) > 3 && _l[3] != "") _u.pct  = clamp(real(_l[3]), 1, 100);
			if (array_length(_l) > 4 && _l[4] != "") _u.keep = clamp(real(_l[4]), 1, 100);
			if (array_length(_l) > 5 && _l[5] != "") _u.t    = ram_snap("timer", real(_l[5]));
			break;
		}
		case "rar": {
			var _l = string_split(_v, ",");
			for (var _j = 0; _j < UPG_RARITY_N; _j++)
				_a.upg.rar[_j] = (_j < array_length(_l)) ? (_l[_j] == "1") : true;
			break;
		}
		case "sk": {
			_a.upg.kind = {};
			if (_v != "") {
				var _l = string_split(_v, "|");
				for (var _j = 0; _j < array_length(_l); _j++)
					if (_l[_j] != "") _a.upg.kind[$ _l[_j]] = false;
			}
			break;
		}
		case "tl": {
			if (_v == "") break;
			var _l = string_split(_v, "|");
			for (var _j = 0; _j < array_length(_l); _j++) {
				var _e = string_split(_l[_j], "=");
				if (array_length(_e) != 2) continue;
				var _tp = _a.tiles[$ _e[0]];
				if (_tp == undefined) continue;
				var _q = string_split(_e[1], ":");
				_tp.on  = (array_length(_q) > 0) && (_q[0] == "1");
				if (array_length(_q) > 1 && _q[1] != "") _tp.pct = clamp(real(_q[1]), 1, 100);
				if (array_length(_q) > 2 && _q[2] != "") _tp.t   = ram_snap("timer", real(_q[2]));
				if (!_tp.on) _tp.st = 0;
			}
			break;
		}
		case "am": {
			var _q = string_split(_v, ":");
			if (variable_global_exists("tiles") && array_length(_q) > 0) g.tiles.automerge = (_q[0] == "1");
			if (array_length(_q) > 1 && _q[1] != "") _a.am_speed = ram_snap("speed", real(_q[1]));
			break;
		}
		case "tap": {
			var _q = string_split(_v, ":");
			if (array_length(_q) > 0) _a.tap.on = (_q[0] == "1");
			if (array_length(_q) > 1 && _q[1] != "") _a.tap.rate = ram_snap("tap", real(_q[1]));
			break;
		}
		case "run": {
			var _q = string_split(_v, ":");
			if (array_length(_q) > 0) _a.run.on = (_q[0] == "1");
			if (array_length(_q) > 1 && _q[1] != "") _a.run.spd = ram_snap("speed", real(_q[1]));
			break;
		}
		case "fab": {
			var _q = string_split(_v, ":");
			if (array_length(_q) > 0) _a.fab.on = (_q[0] == "1");
			if (array_length(_q) > 1 && _q[1] != "") _a.fab.spd = ram_snap("speed", real(_q[1]));
			break;
		}
		case "oc": _a.oc = (_v == "1"); break;
		case "st": {
			var _q = string_split(_v, ":");
			if (array_length(_q) > 0) { var _sv = real(_q[0]); _a.strat = (_sv < 1) ? 3 : clamp(_sv, 1, 4); }   // (0, "a row per dial", retired: reads as robin)
			if (array_length(_q) > 1) _a.dial_all.on  = (_q[1] == "1");
			if (array_length(_q) > 2 && _q[2] != "") _a.dial_all.pct = clamp(real(_q[2]), 1, 100);
			if (array_length(_q) > 3 && _q[3] != "") _a.dial_all.t   = ram_snap("timer", real(_q[3]));
			break;
		}
		case "rl": break;   // (the rails, retired 2026-09-14 - an old mode's field, ignored)
		}
	}
	// a preset packed before the overclock existed, or with it off,
	// closes the notches - nothing may sit on a notch that is not open
	if (!_a.oc) ram_oc_clamp();
	save_mark_dirty();
	return true;
}
