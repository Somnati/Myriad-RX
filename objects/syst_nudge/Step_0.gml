if (!variable_global_exists("game_started") || !g.game_started) { a = 0; line_a = 0; exit; }
unfold_init();
var _u = g.unf;
// the menu's ring is answered by the menu opening: fresh clears
if (instance_exists(syst_menu2) && array_length(_u.fresh) > 0) _u.fresh = [];

// ---- pick: the first row that is live and not done ----
var _rows = nudge_config();
var _pick = "";
var _ptxt = "", _prect = undefined;
if (unfold_has("tap") && !instance_exists(syst_menu2) && !instance_exists(syst_unfold)) {
	for (var _i = 0; _i < array_length(_rows); _i++) {
		var _n = _rows[_i];
		if (_u.done[$ _n.key] ?? false) continue;
		if (_n.done()) { _u.done[$ _n.key] = true; save_mark_dirty(); continue; }
		if (!_n.need()) continue;
		_pick = _n.key;
		_ptxt = _n.txt;
		_prect = _n.rect();
		if (_n.key == "menu_fresh") {
			// what arrived: the newest name, in the menu
			var _c = unfold_config();
			var _nm = _u.fresh[array_length(_u.fresh) - 1];
			for (var _k = 0; _k < array_length(_c); _k++) if (_c[_k].key == _nm) _nm = _c[_k].name;
			var _more = array_length(_u.fresh) - 1;
			_ptxt = "new: " + _nm + ((_more > 0) ? (" +" + string(_more)) : "") + "  -  in the menu";
		}
		break;
	}
}
if (_pick != cur) { cur = _pick; t = 0; }
if (cur != "") { txt = _ptxt; r = _prect; t += delta / 60; }
a = move_to(a, (cur != "") ? 1 : 0, 6);

// ---- a panel's first line: while it is up and not yet closed once ----
var _k2 = unfold_overlay_key();
var _want = "";
if (_k2 != "" && !(_u.opened[$ _k2] ?? false) && !instance_exists(syst_menu2)) _want = unfold_first_line(_k2);
if (_want != "") line_txt = _want;
line_a = move_to(line_a, (_want != "") ? 1 : 0, 6);
