/// the screen body - backdrop, the active tab's rows, the category
/// rail. the whole screen stacks by DEPTH in the normal pass
/// (statistics_v2 uses the same recipe): rows/rail HERE (controller
/// depth) -> widgets (depth-1) -> title strip via obj_draw_proxy
/// (depth-2, running __draw_strip from the Create) -> the menu drawer
/// (-520) over ALL of it. draw end paints over the open menu; draw
/// begin gets painted over by room BACKGROUND layers - depths only.

draw_set_font(fnt);

// backdrop: BLACK AND SLIGHTLY OPEN (his ask, 2026-09-08) so the
// menu_blur layer under it reads through. It was a near-opaque teal
// because the screen was a room with nothing behind it; as an overlay
// the softened room IS what is behind it, and the rows composite on top
// unchanged.
// it is also the FIRST thing to arrive (index 0 of the open animation):
// the ground lands, then the strip, then the list deals in behind them.
// A panel whose contents arrive before their own background reads as
// debris rather than as a screen opening.
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0,
	c_black, .72 * ui_anim_in(oa, 0));

// ---- the active tab's rows, windowed ----
var _n = array_length(view);
var _cw = room_width - rail_w; // content band width
var _first = max(0, floor(g.settings_page));
for (var _r = _first; _r < min(_n, _first + visible_rows + 1); _r++) {
	var _row = view[_r];
	var _ry = __row_y(_r);
	if (_ry + row_h < list_y) continue;
	if (_ry > room_height) break;
	// the row's own opacity, on the same stagger as its rise. ONE call
	// in front of the row instead of a multiply on each of the eleven
	// alphas below - see ui_fade_set for why that is not laziness
	ui_fade_set(ui_anim_in(oa, _r - floor(g.settings_page)));

	// zebra block (the statistics_v2 look, gradient edge seams)
	var _c  = (_r & 1) ? c_hsv(168, 158, 18) : c_hsv(168, 160, 4);
	var _cc = (_r & 1) ? c_hsv(168, 149, 67) : c_black;
	draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, _cw, row_h, 0, _c, .8);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, rail_w, _ry, _cw, 1, 0,
		_c, _cc, _cc, _c, .52);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, rail_w, _ry + row_h - 1,
		_cw, 1, 0, _cc, _c, _c, _cc, .52);

	// hover wash on the tappable rows
	if (_row.kind == sett_kind_toggle || _row.kind == sett_kind_radio
	||  _row.kind == sett_kind_action || _row.kind == sett_kind_pill)
	if (mouse_y >= list_y && mouse_x >= rail_w)
	if (point_in_rectangle(mouse_x, mouse_y, rail_w, _ry, room_width, _ry + row_h - 1))
		draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, _cw, row_h, 0, c_white, .04);

	// label (radios indent one notch under their group)
	var _tx = content_x + 2 + _row.ind * 8;
	draw_set_halign(fa_left);
	draw_set_color(_row.col);
	draw_set_alpha(.9);
	draw_text(_tx, _ry + 4, _row.name);

	// a whisper of a "?" marks rows with an explainer - only while the
	// strip's round ? button has hints switched on (ui stays clean)
	if (_row.help != "" && g.settings_hints) {
		draw_set_alpha(.3);
		draw_text(_tx + string_width(_row.name) + 5, _ry + 4, "?");
	}

	if (_row.kind == sett_kind_info && _row.val != "") {
		draw_set_halign(fa_right);
		draw_set_color(c_white);
		draw_set_alpha(.95);
		draw_text(val_x, _ry + 4, _row.val);
	}
	if (_row.kind == sett_kind_pill) {
		// current choice, lit, with a little drop arrow
		draw_set_halign(fa_right);
		draw_set_color(c_gold);
		draw_set_alpha(.95);
		draw_text(val_x - 8, _ry + 4, _row.val);
		draw_set_color(sett_ink);
		draw_set_alpha(.7);
		draw_text(val_x, _ry + 4, "v");
	}
	if (_row.kind == sett_kind_action) {
		draw_set_halign(fa_right);
		draw_set_color(_row.col);
		draw_set_alpha(.9);
		draw_text(val_x, _ry + 4, ">");
	}
}
ui_fade_set(1);   // never leave the shader on for the next drawer

// ---- the category rail (menu2's color language: identity pip at the
// left edge, active = solid fill + white, others sink toward black) ----
//
// IT SLIDES IN FROM ITS OWN EDGE, which is the left one - the same rule
// the menu drawer follows on the right. A panel's chrome should enter
// from the side it lives on; anything else reads as arriving from
// nowhere. One world matrix, same as the strip, so the tab loop below
// is untouched - and its hit tests (__tabs, read in the Step) keep
// their final geometry, which the input gate makes safe.
var _rp = ui_anim_in(oa, 1);
var _ro = -(1 - _rp) * (rail_w + UI_IN_SLIDE);
if (_ro != 0)
	matrix_set(matrix_world, matrix_build(_ro, 0, 0, 0, 0, 0, 1, 1, 1));
ui_fade_set(_rp);   // it fades as it slides, like everything else here

draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, rail_w, room_height - list_y, 0,
	c_hsv(169, 186, 7), .97);
draw_sprite_ext(spr_pixel_1x1, 0, rail_w - 1, list_y, 1, room_height - list_y, 0,
	c_black, .5);

var _tb = __tabs();
for (var _i = 0; _i < array_length(_tb); _i++) {
	var _t = _tb[_i];
	var _s = sections[_t.idx];
	var _on = (_i == g.settings_tab);
	var _hov = point_in_rectangle(mouse_x, mouse_y, _t.x1, _t.y1, _t.x2, _t.y2);
	var _tw = _t.x2 - _t.x1;
	var _th = _t.y2 - _t.y1;
	draw_set_alpha(1);
	if (_on)
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x1, _t.y1, _tw, _th, 0,
			merge_colour(_s.col, c_black, .6), .92);
	else
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _t.x1, _t.y1, _tw, _th, 0,
			c_black, merge_colour(_s.col, c_black, _hov ? .5 : .75),
			merge_colour(_s.col, c_black, _hov ? .5 : .75), c_black, .85);
	// color identity pip
	draw_sprite_ext(spr_pixel_1x1, 0, _t.x1, _t.y1, _hov || _on ? 3 : 2, _th, 0,
		merge_colour(_s.col, c_white, .2), 1);
	draw_set_halign(fa_left);
	draw_set_color(_on ? c_white : merge_colour(_s.col, c_white, _hov ? .7 : .45));
	draw_set_alpha(.95);
	draw_text(_t.x1 + 7, _t.y1 + ((_th - 7) div 2), _s.name);
}

ui_fade_set(1);
if (_ro != 0) matrix_set(matrix_world, matrix_build_identity());

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
