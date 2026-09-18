/// @description ex_station_draw(ea, ink, dim) -> true when the page is drawn (the old exit): THE STATION PAGE - the star's sky behind, the station large, its card (syst_exped_panel's Draw, q217; self = the panel; ea / ink / dim the event's ease and colours)
function ex_station_draw(_ea, _ink, _dim) {
	if (st_sel < 0 || st_sel >= array_length(sy_stns) || !is_struct(sy_sys)) { __draw_back(); ui_fade_set(1); return true; }
	var _stp = sy_stns[st_sel];
	__draw_station();
	ui_fade_set(_ea);
	// the title
	draw_set_halign(fa_center); draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(room_width * .5, list_y + 6, _stp.name);
	draw_set_halign(fa_left);
	// THE CARD, bottom left: what it is, its line, where it hangs
	var _cw = land ? 210 : room_width - 8, _ch = 46, _cx0 = land ? 14 : 4, _cy0 = room_height - 8 - 16 - 6 - _ch;
	draw_sprite_ext(spr_pixel_1x1, 0, _cx0, _cy0, _cw, _ch, 0, c_black, .82);
	draw_px_rect(_cx0, _cy0, _cw, _ch, _stp.hull, .7);
	draw_set_color(_stp.hull); draw_set_alpha(.95); draw_text(_cx0 + 6, _cy0 + 4, _stp.kind + "  -  " + _stp.shape_name);
	draw_set_color(_ink); draw_set_alpha(.85); draw_text_ext(_cx0 + 6, _cy0 + 15, _stp.line, 9, _cw - 12);
	draw_set_color(_dim); draw_set_alpha(.7); draw_text(_cx0 + 6, _cy0 + _ch - 12, "in orbit of " + star_name(sy_star) + "  -  drag to look round");
	__draw_back();
	ui_fade_set(1);
	return true;
	return true;
}
