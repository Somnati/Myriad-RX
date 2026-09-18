/// @description ex_system_press() -> true when the press is taken (the old exit): THE STAR SYSTEM's dock - a row picks a world or a station or a belt, [enter] dives, [galaxy] goes to the map, the drawer's tab (syst_exped_panel's Step, after its press gate, q217; self = the panel)
function ex_system_press() {
	if (!(view == "system" && is_struct(sy_sys) && sy_warp_pl < 0)) return false;
	var _npl = array_length(sy_sys.planets);
	// [galaxy] bottom left: the map (its [back] returns here)
	var _sgl = __galaxy_r();
	if (point_in_rectangle(mouse_x, mouse_y, _sgl.x, _sgl.y, _sgl.x + _sgl.w, _sgl.y + _sgl.h)) { gx_from = "system"; __page_go("galaxy"); play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); return true; }
	// the drawer's tab: open / close
	var _stb = __sy_tab_r();
	if (point_in_rectangle(mouse_x, mouse_y, _stb.x, _stb.y, _stb.x + _stb.w, _stb.y + _stb.h)) { sy_dw = !sy_dw; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true; }
	// [enter] bottom right while the drawer is shut: a station picked dives to its page (2026-09-17)
	if (sy_dwa <= .3 && sy_ssel >= 0) { var _ser3 = __sy_enter_r(); if (point_in_rectangle(mouse_x, mouse_y, _ser3.x, _ser3.y, _ser3.x + _ser3.w, _ser3.y + _ser3.h)) { sy_warp_st = sy_ssel; sy_warp_t = 0; sy_warp_s = 1; play_sound_ext(snd_matclick2, 1.2, 1.4, .6, 1); return true; } }
	if (sy_dwa <= .3 && sy_sel >= 0 && sy_sel < _npl && galaxy_world_biome(sy_sys.planets[sy_sel]) >= 0) { var _ser2 = __sy_enter_r(); if (point_in_rectangle(mouse_x, mouse_y, _ser2.x, _ser2.y, _ser2.x + _ser2.w, _ser2.y + _ser2.h)) { sy_warp_pl = sy_sel; sy_warp_t = 0; sy_warp_s = 1; play_sound_ext(snd_matclick2, 1.2, 1.4, .6, 1); return true; } }
	if (sy_dwa >= .5) {   // (the drawer open: its rows and [enter])
	for (var _j = 0; _j < array_length(sy_stns); _j++) { var _rr2 = __sy_row_r(_npl + _j); if (_rr2.y + _rr2.h > room_height - 8 - 20) break; if (point_in_rectangle(mouse_x, mouse_y, _rr2.x, _rr2.y, _rr2.x + _rr2.w, _rr2.y + _rr2.h)) { sy_ssel = _j; sy_sel = -1; sy_bsel = -1; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); return true; } }   // (a station's row - 2026-09-17)
	for (var _b = 0; _b < array_length(sy_belts); _b++) { var _rr3 = __sy_row_r(_npl + array_length(sy_stns) + _b); if (_rr3.y + _rr3.h > room_height - 8 - 20) break; if (point_in_rectangle(mouse_x, mouse_y, _rr3.x, _rr3.y, _rr3.x + _rr3.w, _rr3.y + _rr3.h)) { sy_bsel = _b; sy_sel = -1; sy_ssel = -1; play_sound_ext(snd_softclick, 1, 1.1, .35, 1); return true; } }   // (a belt's row: named, lit - the polish)
	for (var _i = 0; _i < _npl; _i++) { var _rr = __sy_row_r(_i); if (_rr.y + _rr.h > room_height - 8 - 20) break; if (point_in_rectangle(mouse_x, mouse_y, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) { sy_ssel = -1; sy_bsel = -1; sy_sel = _i; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); return true; } }
	var _sor = __sy_open_r();
	if (point_in_rectangle(mouse_x, mouse_y, _sor.x, _sor.y, _sor.x + _sor.w, _sor.y + _sor.h)) {
		if (sy_ssel >= 0) { sy_warp_st = sy_ssel; sy_warp_t = 0; sy_warp_s = 1; play_sound_ext(snd_matclick2, 1.2, 1.4, .6, 1); return true; }   // (a station - 2026-09-17)
		if (sy_sel < 0 || sy_sel >= _npl || galaxy_world_biome(sy_sys.planets[sy_sel]) < 0) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); return true; }
		sy_warp_pl = sy_sel; sy_warp_t = 0; sy_warp_s = 1;
		play_sound_ext(snd_matclick2, 1.2, 1.4, .6, 1);
		return true;
	}
	}
	return false;
}
