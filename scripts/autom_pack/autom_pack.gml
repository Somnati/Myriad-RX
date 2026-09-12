/// @description autom_pack() - the whole automation setup as one
/// string, for the presets: every switch, cap, timer and speed, the
/// rebirth rails, the filter flags, the table's automerge switch. NOT
/// the RAM level (a purchase, not a preference) and not the reserve's
/// watermark. Fields are "/"-joined, lists ","-joined, keyed entries
/// "id=on:pct:t|..." - none of the ini's own characters.
function autom_pack() {
	autom_init();
	var _a = g.autom;
	var _o = "";
	// the dials: on:pct:t per dial
	var _d = "";
	for (var _i = 0; _i < array_length(_a.dial); _i++) {
		var _p = _a.dial[_i];
		_d += ((_i > 0) ? "," : "") + (_p.on ? "1" : "0") + ":" + string(_p.pct) + ":" + string(_p.t);
	}
	_o += "d=" + _d;
	var _r = _a.reb;
	_o += "/r=" + (_r.on ? "1" : "0")
	     + "," + (_r.t_on ? "1" : "0") + ":" + string(_r.t_min)
	     + "," + (_r.u_on ? "1" : "0") + ":" + string(_r.u_min)
	     + "," + (_r.g_on ? "1" : "0") + ":" + string(_r.g_pct)
	     + "," + (_r.p_on ? "1" : "0") + ":" + string(_r.p_oom)
	     + "," + (_r.c_on ? "1" : "0");
	var _u = _a.upg;
	_o += "/u=" + (_u.roll ? "1" : "0") + "," + (_u.buy ? "1" : "0") + "," + (_u.sell ? "1" : "0")
	     + "," + string(_u.pct) + "," + string(_u.keep) + "," + string(_u.t);
	var _fr = "";
	for (var _k = 0; _k < UPG_RARITY_N; _k++) _fr += ((_k > 0) ? "," : "") + (_u.rar[_k] ? "1" : "0");
	_o += "/rar=" + _fr;
	var _fk = "";
	var _kn = variable_struct_get_names(_u.kind);
	for (var _k = 0; _k < array_length(_kn); _k++)
		if (!_u.kind[$ _kn[_k]]) _fk += ((_fk == "") ? "" : "|") + _kn[_k];
	_o += "/sk=" + _fk;
	var _tl = "";
	var _tn = variable_struct_get_names(_a.tiles);
	for (var _k = 0; _k < array_length(_tn); _k++) {
		var _tp = _a.tiles[$ _tn[_k]];
		_tl += ((_tl == "") ? "" : "|") + _tn[_k] + "=" + (_tp.on ? "1" : "0")
		     + ":" + string(_tp.pct) + ":" + string(_tp.t);
	}
	_o += "/tl=" + _tl;
	_o += "/am=" + ((variable_global_exists("tiles") && g.tiles.automerge) ? "1" : "0")
	     + ":" + string(_a.am_speed);
	_o += "/tap=" + (_a.tap.on ? "1" : "0") + ":" + string(_a.tap.rate);
	_o += "/run=" + (_a.run.on ? "1" : "0") + ":" + string(_a.run.spd);
	_o += "/fab=" + (_a.fab.on ? "1" : "0") + ":" + string(_a.fab.spd);
	_o += "/oc=" + (_a.oc ? "1" : "0");
	return _o;
}
