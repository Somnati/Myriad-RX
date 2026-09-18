/// @description ex_galaxy_step() -> true when the event is done (the old exit): THE GALAXY VIEW's step - a press, a drag, the wheel's zoom, a tap on a star, [enter] (syst_exped_panel's Step, q218; self = the panel)
function ex_galaxy_step() {
	if (view != "galaxy") return false;
	var _gcf = starmap_config();
	var _gr = __gx_r();
	var _gin = point_in_rectangle(mouse_x, mouse_y, _gr.x, _gr.y, _gr.x + _gr.w, _gr.y + _gr.h);
	if (_gin) {
		var _z0 = gx_zoom;
		if (mouse_wheel_up())   gx_zoom = min(gx_zoom * _gcf.zoom_step, _gcf.zoom_max);
		if (mouse_wheel_down()) gx_zoom = max(gx_zoom / _gcf.zoom_step, _gcf.zoom_min);
		if (gx_zoom != _z0) { var _vcx = gx_x + _gr.w * .5 / _z0, _vcy = gx_y + _gr.h * .5 / _z0; gx_x = _vcx - _gr.w * .5 / gx_zoom; gx_y = _vcy - _gr.h * .5 / gx_zoom; }
	}
	var _gbk = __back_r();
	var _onbk = point_in_rectangle(mouse_x, mouse_y, _gbk.x, _gbk.y, _gbk.x + _gbk.w, _gbk.y + _gbk.h);
	var _mmr = __gx_mm_r();
	var _onmm = point_in_rectangle(mouse_x, mouse_y, _mmr.x, _mmr.y, _mmr.x + _mmr.w, _mmr.y + _mmr.h);
	if (_onmm && mouse_check_button_pressed(mb_left)) {
		// the minimap: a tap jumps the camera there
		var _smm = starmap_get();
		var _jx = (mouse_x - _mmr.x) / _mmr.w * _smm.width, _jy = (mouse_y - _mmr.y) / _mmr.h * _smm.height;
		gx_x = _jx - _gr.w * .5 / gx_zoom; gx_y = _jy - _gr.h * .5 / gx_zoom;
		play_sound_ext(snd_softclick, .95, 1.05, .3, 1);
	}
	// [ENTER] (2026-09-16): into the tapped star's system
	var _ger = __gx_enter_r();
	var _onstrip = (gx_sel >= 0 && is_struct(gx_sys) && point_in_rectangle(mouse_x, mouse_y, _ger.x, _ger.y, _ger.x + _ger.w, _ger.y + _ger.h));
	if (_onstrip && mouse_check_button_pressed(mb_left)) {
		__sy_enter(gx_sel); sy_from = "galaxy";
		__page_go("system");
		play_sound_ext(snd_apply, 1, 1.2, .5, 1);
		return true;
	}
	if (!gx_press && mouse_check_button_pressed(mb_left) && _gin && !_onbk && !_onmm && !_onstrip) { gx_press = true; gx_px = mouse_x; gx_py = mouse_y; gx_cx0 = gx_x; gx_cy0 = gx_y; gx_travel = 0; }
	if (gx_press && mouse_check_button(mb_left)) {
		gx_travel = max(gx_travel, point_distance(gx_px, gx_py, mouse_x, mouse_y));
		gx_x = gx_cx0 - (mouse_x - gx_px) / gx_zoom;
		gx_y = gx_cy0 - (mouse_y - gx_py) / gx_zoom;
	} else if (gx_press) {
		gx_press = false;
		if (gx_travel <= _gcf.tap_max_dist) {
			// the nearest star to the tap, on its parallax-shifted draw position
			var _sm = starmap_get();
			var _vis = star_visible(gx_x, gx_y, gx_zoom, _gr.w, _gr.h);
			var _vcx2 = gx_x + _gr.w * .5 / gx_zoom, _vcy2 = gx_y + _gr.h * .5 / gx_zoom;
			var _bi = -1, _bd = _gcf.tap_radius;
			for (var _i = 0; _i < array_length(_vis); _i++) {
				var _st = _sm.stars[_vis[_i]];
				var _sx = _gr.x + ((_vcx2 + (_st.x - _vcx2) * _st.d) - gx_x) * gx_zoom;
				var _sy = _gr.y + ((_vcy2 + (_st.y - _vcy2) * _st.d) - gx_y) * gx_zoom;
				var _dd = point_distance(_sx, _sy, mouse_x, mouse_y);
				if (_dd < _bd) { _bd = _dd; _bi = _vis[_i]; }
			}
			if (_bi >= 0 && _bi != gx_sel) { gx_sel = _bi; gx_sys = starsystem_get(_sm.stars[_bi].seed, _sm.stars[_bi].props); play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); }
			else if (_bi < 0) gx_sel = -1;
		}
	}
	var _gcfg = starmap_config();
	gx_x = clamp(gx_x, -_gr.w * .5 / gx_zoom, _gcfg.plane_w - _gr.w * .5 / gx_zoom);
	gx_y = clamp(gx_y, -_gr.h * .5 / gx_zoom, _gcfg.plane_h - _gr.h * .5 / gx_zoom);
	return false;
}
