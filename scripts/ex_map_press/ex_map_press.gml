/// @description ex_map_press() -> true when the press is taken: THE REGION MAP's presses - a node's card, the legend, a road (syst_exped_panel's Step, q220; self = the panel)
function ex_map_press() {
	if (land) { var _ibx = __map_box_r(); if (point_in_rectangle(mouse_x, mouse_y, _ibx.x, _ibx.y, _ibx.x + _ibx.w, _ibx.y + _ibx.h)) { rg_box_open = !rg_box_open; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true; } }   // (the info box's fold, 2026-09-16)
	var _lgr = __legend_r();
	if (point_in_rectangle(mouse_x, mouse_y, _lgr.x, _lgr.y, _lgr.x + _lgr.w, _lgr.y + _lgr.h)) { map_legend = !map_legend; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true; }
	if (map_legend) { map_legend = false; return true; }   // (any other press folds it)
	// a place: its card (his ask, 2026-09-16); the same place again, or a press elsewhere, folds it
	if (is_struct(map_dest)) {
		var _rg0 = region_get(map_dest, map_rgi), _mr0 = __map_r();
		var _hit = -1, _hd = 9;
		for (var _i = 0; _i < array_length(_rg0.nodes); _i++) {
			var _hp = __map_xy(_rg0.nodes[_i], _rg0, _mr0);
			var _dd = point_distance(mouse_x, mouse_y, _hp.x, _hp.y);
			if (_dd < _hd) { _hd = _dd; _hit = _i; }
		}
		if (_hit >= 0) { map_pop = (map_pop == _hit) ? -1 : _hit; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); return true; }
		if (map_pop >= 0) { map_pop = -1; return true; }
	}
	return true;
}
