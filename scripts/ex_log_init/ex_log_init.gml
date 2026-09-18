/// @description ex_log_init() - THE DIARY'S LOG of syst_exped_panel: the scroll's state, the house scrollbar (sb), the lines, the layout, the band's painter, the rectangles - defined on the panel (self = the panel; called from its Create). q221, the deconvolution
function ex_log_init() {
// THE DIARY'S SCROLL (his ask, 2026-09-15: the scrollbar framework, smooth):
// log_scroll = pixels down from the diary's top; the house bar (sb,
// scrl_exped_log, pixel mode) drives it; it follows the newest line
// unless you scrolled up (log_follow)
log_scroll = 0;
log_follow = true;
log_n = -1;                          // the diary's line count last seen (a new line = follow)
log_surf = -1;                       // the diary's band, rendered offset
log_lay = { n : 0, w : 0, hs : [], total : 0 };   // the layout: every line's height, the total
log_hi = false;                                    // THE GIST (2026-09-16): the diary's highlights only (exped_log_gist), the strip's toggle
hl_open = false;                                   // THE HAUL'S DIARY (2026-09-16): behind [read the diary] on the home page
log_gist = { n : -1, id : -1, arr : [] };         // ...the filtered lines, cached by the source's length and the page
sb = create_obj(0, 0, obj_scrollbar);
sb.i = scrl_exped_log;
sb.depth = depth - 1;
sb.ui_layer = ui_layer_popup;
sb.in_menu = true;
sb.col = c_steelblue;
sb.visible = false; sb.enabled = false;
/// the diary this page shows (the trip's or the haul's), or undefined
__log_lines = function() {
	var _src = undefined;
	if (view == "trip") { var _t = __trip(); _src = is_undefined(_t) ? undefined : _t.log; }
	else if (view == "haul") { var _h = __haul_i(); _src = (_h < 0) ? undefined : g.exped.hauls[_h].log; }
	if (!is_array(_src) || !log_hi) return _src;
	// THE GIST (2026-09-16): the highlights only (exped_log_gist), the first line always; cached by the source's length and the page
	if (log_gist.n != array_length(_src) || log_gist.id != view_id) {
		var _arr = [];
		for (var _i = 0; _i < array_length(_src); _i++) if (_i == 0 || exped_log_gist(_src[_i])) array_push(_arr, _src[_i]);
		log_gist = { n : array_length(_src), id : view_id, arr : _arr };
	}
	return log_gist.arr;
};
__log_band_h = function() { var _r = __log_r(); return max(1, _r.h); };
/// the layout: each line's height at the column's width, the total (once
/// a frame - the count or the width changing recomputes)
__log_layout = function(_log, _w) {
	if (is_array(_log) && log_lay.n == array_length(_log) && log_lay.w == _w && (log_lay[$ "id"] ?? -1) == view_id) return log_lay;   // (keyed by the page's trip too: another diary of the same length is another layout)
	var _hs = [], _tot = 0;
	if (is_array(_log)) {
		draw_set_font(fnt);
		for (var _i = 0; _i < array_length(_log); _i++) {
			var _pre = string_copy(_log[_i], 1, 2);
			var _isv = (_pre == "~ "), _ish = (_pre == "# "), _isk = (_pre == "* ");   // (the voice, a place header, the sky - 2026-09-16)
			var _h = string_height_ext((_isv || _ish || _isk || _pre == "+ ") ? string_delete(_log[_i], 1, 2) : _log[_i], 9, _w - (_isv ? 8 : 0)) + 2 + (_ish ? 6 : 0);
			array_push(_hs, _h); _tot += _h;
		}
	}
	log_lay = { n : is_array(_log) ? array_length(_log) : 0, w : _w, hs : _hs, total : _tot, id : view_id };
	return log_lay;
};
__log_content_h = function() { var _r = __log_r(); var _l = __log_lines(); return __log_layout(_l, _r.w - 8).total; };
/// the diary painted into its band, scrolled: truth lines plain, "~ " the
/// crew's voice (dim, indented), "+ " rewards (gold); newest at the bottom
__draw_log_band = function(_log, _r, _col) {
	var _w = max(2, floor(_r.w - 8)), _h = max(2, floor(_r.h));
	if (!surface_exists(log_surf) || surface_get_width(log_surf) != _w || surface_get_height(log_surf) != _h) {
		if (surface_exists(log_surf)) surface_free(log_surf);
		log_surf = surface_create(_w, _h);
	}
	var _lay = __log_layout(_log, _w);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(log_surf);
	draw_clear_alpha(c_black, 0);
	draw_set_font(fnt); draw_set_halign(fa_left); draw_set_valign(fa_top);
	var _yy = -log_scroll;
	var _nl = is_array(_log) ? array_length(_log) : 0;
	for (var _i = 0; _i < _nl; _i++) {
		var _lh = _lay.hs[_i];
		if (_yy + _lh >= 0 && _yy <= _h) {
			var _pre = string_copy(_log[_i], 1, 2);
			var _isv = (_pre == "~ "), _isr = (_pre == "+ "), _ish = (_pre == "# "), _isk = (_pre == "* ");
			var _last = (_i == _nl - 1);
			// a place header (2026-09-16): a rule, then the line in the world's colour; the sky's lines dim
			if (_ish) { draw_sprite_ext(spr_pixel_1x1, 0, 0, _yy + 2, _w, 1, 0, _col, .35); draw_set_color(merge_colour(_col, c_white, .55)); draw_set_alpha(_last ? .95 : .9); draw_text_ext(0, _yy + 6, string_delete(_log[_i], 1, 2), 9, _w); }
			else if (_isk) { draw_set_color(merge_colour(sett_ink, _col, .5)); draw_set_alpha(_last ? .8 : .5); draw_text_ext(0, _yy, string_delete(_log[_i], 1, 2), 9, _w); }
			else if (_isv) { draw_set_color(_last ? merge_colour(sett_ink, c_white, .5) : merge_colour(sett_ink, _col, .35)); draw_set_alpha(_last ? .9 : .55); draw_text_ext(8, _yy, string_delete(_log[_i], 1, 2), 9, _w - 8); }
			else if (_isr) { draw_set_color(_last ? merge_colour(c_gold, c_white, .3) : c_gold); draw_set_alpha(_last ? .95 : .8); draw_text_ext(0, _yy, string_delete(_log[_i], 1, 2), 9, _w); }
			else { draw_set_color(_last ? c_white : sett_ink); draw_set_alpha(_last ? .95 : .7); draw_text_ext(0, _yy, _log[_i], 9, _w); }
		}
		_yy += _lh;
	}
	draw_set_alpha(1);
	surface_reset_target();
	ui_fade_set(_fa);
	draw_surface(log_surf, _r.x, _r.y);
};
/// the diary's rect on the page that shows one (the wheel's target)
__log_r = function() {
	if (view == "trip") {
		var _t = __trip();
		var _fighting = !is_undefined(_t) && (!is_undefined(_t.fight) || !is_undefined(rp));
		var _yend = _fighting ? (__fight_r().y - 6) : (room_height - 8 - (land ? 18 : 2));   // (over the buttons' row on a wide page)
		return { x : log_x, y : log_y + 42, w : log_w, h : _yend - (log_y + 42) };   // (under the quest's island)
	}
	if (view == "haul") { var _cw = land ? 224 : (room_width - 8), _lx = (land ? 14 : 4) + _cw + 12, _dy = list_y + 22; return { x : _lx, y : _dy, w : room_width - _lx - 14, h : (hl_open && land) ? (room_height - 8 - 22 - _dy) : 0 }; }   // (the diary fills the column when open - 2026-09-16)   // (the band's own y - it sat 48px above it since the tally moved the band, 2026-09-16)
	return { x : 0, y : 0, w : 0, h : 0 };
};
/// [read the diary] / [close the diary] on the haul page (2026-09-16): the right column's foot
__hlog_r = function() { var _cw = 224, _lx = 14 + _cw + 12; return { x : _lx, y : room_height - 8 - 16, w : room_width - _lx - 14, h : 16 }; };
// the departure window: the crew chips left, the brief right, [depart] under the brief
}
