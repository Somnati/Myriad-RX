/// the panel's face. Draw-only. Cards first (scrolled, dealt in), then
/// the strip OVER them so a card sliding up disappears into it (the
/// faq's recipe). The card's own language: boxes, gold for the one in
/// hand, green for the done, dim for what is ahead.
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _rows = __rows();
var _y    = list_y + 4 - scroll;
var _deal = 0;

for (var _i = 0; _i < array_length(_rows); _i++) {
	var _r = _rows[_i];
	var _h = _r.h;
	if (_r.kind == "done" || _r.kind == "cur_hdr" || _r.kind == "ahead") _deal += 1;
	if (_y + _h > list_y && _y < room_height) {
		var _ea = ui_anim_in(oa, 1 + min(_deal, UI_IN_STEPS));
		if (_ea > .001) {
			var _off = (1 - _ea) * UI_IN_DEAL;
			if (_off != 0) matrix_set(matrix_world, matrix_build(0, _off, 0, 0, 0, 0, 1, 1, 1));
			ui_fade_set(_ea);
			switch (_r.kind) {
			case "done": {
				// one green line: the plate, a filled box with its check, the name
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, cw, _h - 1, 0, c_hsv(169, 160, 7), .96);
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, 2, _h - 1, 0, c_sgreen, .7);
				var _bx = cx + 8, _by = _y + 4;
				draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by, 6, 6, 0, c_sgreen, .85);
				draw_sprite_ext(spr_pixel_1x1, 0, _bx + 1, _by + 3, 1, 1, 0, c_black, .9);
				draw_sprite_ext(spr_pixel_1x1, 0, _bx + 2, _by + 4, 1, 1, 0, c_black, .9);
				draw_sprite_ext(spr_pixel_1x1, 0, _bx + 3, _by + 3, 1, 1, 0, c_black, .9);
				draw_sprite_ext(spr_pixel_1x1, 0, _bx + 4, _by + 2, 1, 1, 0, c_black, .9);
				draw_set_color(merge_colour(c_sgreen, dim, .5));
				draw_set_alpha(.85);
				draw_text(cx + 18, _y + 3, _r.o.name);
				break;
			}
			case "cur_hdr": {
				// the one in hand: a taller plate begins here (the steps
				// and the note continue it - same ground, no seam)
				var _ph = _h;
				for (var _k = _i + 1; _k < array_length(_rows) && _rows[_k].kind != "gap" && _rows[_k].kind != "done" && _rows[_k].kind != "ahead"; _k++) _ph += _rows[_k].h;
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, cw, _ph - 1, 0, c_hsv(169, 160, 9), .97);
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, cw, 1, 0, c_white, .07);
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, 2, _ph - 1, 0, c_gold, .9);
				draw_set_color(dim);
				draw_set_alpha(.55);
				draw_text(cx + 8, _y + 3, "now");
				draw_set_color(c_gold);
				draw_set_alpha(.95);
				draw_text(cx + 8 + string_width("now") + 6, _y + 3, _r.o.name);
				break;
			}
			case "step": {
				var _bx = cx + 12, _by = _y + 1;
				draw_px_rect(_bx, _by, 6, 6, _r.done ? c_sgreen : c_gold, _r.done ? 1 : .55);
				if (_r.done) {
					draw_sprite_ext(spr_pixel_1x1, 0, _bx + 1, _by + 1, 4, 4, 0, c_sgreen, .95);
					draw_sprite_ext(spr_pixel_1x1, 0, _bx + 1, _by + 3, 1, 1, 0, c_black, .9);
					draw_sprite_ext(spr_pixel_1x1, 0, _bx + 2, _by + 4, 1, 1, 0, c_black, .9);
					draw_sprite_ext(spr_pixel_1x1, 0, _bx + 3, _by + 3, 1, 1, 0, c_black, .9);
					draw_sprite_ext(spr_pixel_1x1, 0, _bx + 4, _by + 2, 1, 1, 0, c_black, .9);
				}
				draw_set_color(_r.done ? dim : c_white);
				draw_set_alpha(_r.done ? .6 : .92);
				draw_text_ext(cx + 22, _y, _r.txt, 9, cw - 30);
				break;
			}
			case "note": {
				draw_set_color(c_lavender);
				draw_set_alpha(.75);
				draw_text_ext(cx + 12, _y + 1, _r.txt, 9, cw - 30);
				break;
			}
			case "ahead": {
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, cw, _h - 1, 0, c_hsv(169, 160, 5), .9);
				draw_px_rect(cx + 8, _y + 4, 6, 6, dim, .35);
				draw_set_color(dim);
				draw_set_alpha(.45);
				draw_text(cx + 18, _y + 3, _r.o.name);
				break;
			}
			}
			ui_fade_set(1);
			if (_off != 0) matrix_set(matrix_world, matrix_build_identity());
		}
	}
	_y += _h;
}

// ---- the title strip - slides down from under the header, OVER the cards ----
var _sp = ui_anim_in(oa, 1);
if (_sp > .001) {
	var _so = -(1 - _sp) * UI_IN_SLIDE;
	if (_so != 0) matrix_set(matrix_world, matrix_build(0, _so, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_sp);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, 16, 0, c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, hh + 15, room_width, 1, 0, sett_ink, .25);
	draw_set_halign(fa_left);
	draw_set_color(c_gold);
	draw_set_alpha(.95);
	draw_text(6, hh + 5, "objectives");
	draw_set_color(dim);
	draw_set_alpha(.6);
	var _n = array_length(objective_config());
	var _d = min(g.obj.i, _n);
	draw_text(6 + string_width("objectives") + 8, hh + 5, string(_d) + " of " + string(_n) + (land ? " complete" : ""));
	ui_fade_set(1);
	if (_so != 0) matrix_set(matrix_world, matrix_build_identity());
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_color(c_white);
