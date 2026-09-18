/// @description ex_system_draw(e, ea, ink, dim) -> true when the page is drawn (the old exit): THE STAR SYSTEM page - the painter (__draw_system), the title, the dock, the caption, [enter] (syst_exped_panel's Draw, q217; self = the panel; e = g.exped, ea / ink / dim the event's ease and colours)
function ex_system_draw(_e, _ea, _ink, _dim) {
	if (sy_star < 0 || !is_struct(sy_sys)) { __draw_back(); ui_fade_set(1); return true; }
	var _sm = starmap_get(), _hm = galaxy_home();
	__draw_system();
	ui_fade_set(_ea);
	var _pls = sy_sys.planets, _np = array_length(_pls);
	var _romd = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"];
	// the title
	draw_set_halign(fa_center); draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(sy_cx, list_y + 6, "the " + star_name(sy_star) + " system");
	// the caption at the foot of the view: pick a planet, or the picked one's line (above the buttons' row)
	var _capy = room_height - 8 - 16 - 12;
	if (sy_bsel >= 0 && sy_bsel < array_length(sy_belts)) {
		var _blc = sy_belts[sy_bsel];
		draw_set_color(merge_colour(_blc.col, c_white, .3)); draw_set_alpha(.95);
		draw_text(sy_cx, _capy, _blc.name + "  -  asteroid belt  -  " + string(_blc.n) + " rocks" + ((array_length(_blc.lanes) > 1) ? ", two lanes" : ", a lane"));
	} else if (sy_ssel >= 0 && sy_ssel < array_length(sy_stns)) {
		var _stc2 = sy_stns[sy_ssel];
		draw_set_color(c_gold); draw_set_alpha(.95);
		draw_text(sy_cx, _capy, _stc2.name + "  -  " + _stc2.kind + "  -  " + _stc2.shape_name);
	} else if (sy_sel >= 0 && sy_sel < _np) {
		var _gbc = galaxy_world_biome(_pls[sy_sel]);
		draw_set_color(c_gold); draw_set_alpha(.95);
		draw_text(sy_cx, _capy, star_name(sy_star) + " " + _romd[clamp(sy_sel, 0, 7)] + "  -  " + ((_gbc < 0) ? "gas giant  -  no landing" : (exped_biomes()[_gbc].name + " world  -  tier " + string(sy_info[sy_sel]))));
	} else { draw_set_color(_dim); draw_set_alpha(.7); draw_text(sy_cx, _capy, (array_length(sy_stns) > 0) ? "pick a planet or a station" : "pick a planet"); }
	draw_set_halign(fa_left);
	// [galaxy] bottom left (his ask, 2026-09-16): the map, from here
	var _sgl = __galaxy_r();
	if (sy_warp_pl < 0 && sy_warp_st < 0) draw_ui_button(_sgl.x, _sgl.y, _sgl.w, _sgl.h, "galaxy", c_steelblue, true, false);
	// THE DOCK AS A DRAWER (his ask, 2026-09-16): the tab on the right edge, the star's numbers and the worlds when open
	var _dkx = __sy_dock_x(), _dkw = __sy_dock_w();
	var _stb = __sy_tab_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _stb.x, _stb.y, _stb.w, _stb.h, 0, c_black, .85);
	draw_px_rect(_stb.x, _stb.y, _stb.w, _stb.h, c_steelblue, .6);
	draw_set_color(c_steelblue); draw_set_alpha(.9); draw_text(_stb.x + 2, _stb.y + _stb.h * .5 - 4, sy_dw ? ">" : "<");
	// (one [enter] at a time: this one until the drawer's past .3, the drawer's own after)
	if (sy_dwa <= .3 && sy_ssel >= 0 && sy_warp_pl < 0 && sy_warp_st < 0) { var _ser0 = __sy_enter_r(); draw_ui_button(_ser0.x, _ser0.y, _ser0.w, _ser0.h, "enter  >", c_gold, true, true); }   // (a station picked - 2026-09-17)
	if (sy_dwa <= .3 && sy_sel >= 0 && sy_sel < _np && galaxy_world_biome(_pls[sy_sel]) >= 0 && sy_warp_pl < 0 && sy_warp_st < 0) { var _ser = __sy_enter_r(); draw_ui_button(_ser.x, _ser.y, _ser.w, _ser.h, "enter  >", c_gold, true, true); }
	if (sy_dwa > .01) {
	draw_sprite_ext(spr_pixel_1x1, 0, _dkx + 9, list_y + 16, room_width - (_dkx + 9), room_height - 8 - (list_y + 16), 0, c_black, .82 * sy_dwa);
	draw_px_rect(_dkx + 9, list_y + 16, room_width - (_dkx + 9), room_height - 8 - (list_y + 16), c_steelblue, .55 * sy_dwa);
	}
	if (sy_dwa > .3) {
	var _sbx = __sy_box_r();
	draw_px_rect(_sbx.x + 3, _sbx.y + 3, _sbx.w - 6, _sbx.h - 6, c_lavender, .5);
	draw_set_color(c_white); draw_set_alpha(.95); draw_text(_sbx.x + 8, _sbx.y + 6, __sheet_cut(star_name(sy_star) + " system", _sbx.w - 16));
	draw_set_color(c_gold); draw_set_alpha(.9); draw_text(_sbx.x + 8, _sbx.y + 17, "temp " + string(sy_sys.star[$ "temp_k"] ?? 5000) + " k");
	draw_set_color(_ink); draw_set_alpha(.85); draw_text(_sbx.x + 8, _sbx.y + 28, "size " + string_format(sy_sys.star.size, 1, 1));
	draw_text(_sbx.x + 8, _sbx.y + 39, "age " + string_format(sy_sys.star[$ "age"] ?? 5, 1, 2) + " byr  -  class " + _sm.stars[sy_star].props.stellar_class);
	for (var _i = 0; _i < _np; _i++) {
		var _rr = __sy_row_r(_i), _pld = _pls[_i], _gbd = galaxy_world_biome(_pld), _ond = (sy_sel == _i);
		if (_rr.y + _rr.h > room_height - 8 - 20) break;
		var _onbd = false;
		for (var _bj = 0; _bj < array_length(_e.board); _bj++) if (_e.board[_bj].seed == _pld.seed) _onbd = true;
		draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0, c_black, .7);
		draw_px_rect(_rr.x, _rr.y, _rr.w, _rr.h, _ond ? c_gold : c_steelblue, _ond ? .9 : .5);
		__dot(_rr.x + 8, _rr.y + 11, 3, (_gbd < 0) ? _pld.col : exped_biomes()[_gbd].col2, (_gbd < 0) ? .6 : .95);
		draw_set_color((_gbd < 0) ? _dim : c_white); draw_set_alpha(.95);
		draw_text(_rr.x + 16, _rr.y + 2, star_name(sy_star) + " " + _romd[clamp(_i, 0, 7)]);
		draw_set_color(_dim); draw_set_alpha(.75);
		draw_text(_rr.x + 16, _rr.y + 12, __sheet_cut((_gbd < 0) ? "gas  -  no landing" : (exped_biomes()[_gbd].name + "  -  tier " + string(sy_info[_i])), _rr.w - 20));
	}
	// THE STATIONS' ROWS (2026-09-17), after the worlds'
	for (var _j = 0; _j < array_length(sy_stns); _j++) {
		var _rr2 = __sy_row_r(_np + _j), _stj = sy_stns[_j], _onj = (sy_ssel == _j);
		if (_rr2.y + _rr2.h > room_height - 8 - 20) break;
		draw_sprite_ext(spr_pixel_1x1, 0, _rr2.x, _rr2.y, _rr2.w, _rr2.h, 0, c_black, .7);
		draw_px_rect(_rr2.x, _rr2.y, _rr2.w, _rr2.h, _onj ? c_gold : c_steelblue, _onj ? .9 : .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _rr2.x + 6, _rr2.y + 9, 5, 5, 0, _stj.hull, .95);
		draw_set_color(c_white); draw_set_alpha(.95);
		draw_text(_rr2.x + 16, _rr2.y + 2, __sheet_cut(_stj.name, _rr2.w - 20));
		draw_set_color(_dim); draw_set_alpha(.75);
		draw_text(_rr2.x + 16, _rr2.y + 12, __sheet_cut(_stj.kind + "  -  " + _stj.shape_name, _rr2.w - 20));
	}
	// THE BELTS' ROWS (2026-09-17): named, dim, nothing to pick
	for (var _b = 0; _b < array_length(sy_belts); _b++) {
		var _rr3 = __sy_row_r(_np + array_length(sy_stns) + _b), _blr = sy_belts[_b], _onb = (sy_bsel == _b);
		if (_rr3.y + _rr3.h > room_height - 8 - 20) break;
		draw_sprite_ext(spr_pixel_1x1, 0, _rr3.x, _rr3.y, _rr3.w, _rr3.h, 0, c_black, .7);
		draw_px_rect(_rr3.x, _rr3.y, _rr3.w, _rr3.h, _onb ? c_gold : c_steelblue, _onb ? .9 : .35);
		for (var _bd = 0; _bd < 5; _bd++) draw_sprite_ext(spr_pixel_1x1, 0, _rr3.x + 5 + _bd * 2 + ((_bd mod 2) == 0 ? 0 : 1), _rr3.y + 10 + ((_bd mod 3) - 1), 1, 1, 0, _blr.col, .9);
		draw_set_color(_dim); draw_set_alpha(.9);
		draw_text(_rr3.x + 16, _rr3.y + 2, __sheet_cut(_blr.name, _rr3.w - 20));
		draw_set_alpha(.7);
		draw_text(_rr3.x + 16, _rr3.y + 12, __sheet_cut("asteroid belt  -  " + string(_blr.n) + " rocks", _rr3.w - 20));
	}
	var _sor = __sy_open_r();
	var _canopen = ((sy_sel >= 0 && sy_sel < _np && galaxy_world_biome(_pls[sy_sel]) >= 0) || sy_ssel >= 0) && sy_warp_pl < 0 && sy_warp_st < 0;
	var _selon = false; if (_canopen) for (var _bj = 0; _bj < array_length(_e.board); _bj++) if (_e.board[_bj].seed == _pls[sy_sel].seed) _selon = true;
	draw_ui_button(_sor.x, _sor.y, _sor.w, _sor.h, _canopen ? "enter  >" : "pick a world", _canopen ? c_gold : c_gray, _canopen, _canopen);
	}
	// the dive's veil: black by the swell's second half (the page turns behind it)
	if (sy_warp_pl >= 0 || sy_warp_st >= 0) draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, room_width, room_height - list_y, 0, c_black, clamp((sy_warp_t - .45) / .3, 0, 1));
	__draw_back();
	ui_fade_set(1);
	return true;
	return true;
}
