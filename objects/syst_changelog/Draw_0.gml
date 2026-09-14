/// the column of release cards (scrolled), then the strip OVER them so a
/// card sliding up disappears into it. The overlay's open recipe: cards
/// deal in, the strip slides from under the header.

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// (no ground of its own: obj_menu2_bck paints the plate UNDER the blur)

var _cards = __cards();
var _y = list_y + 4 - scroll;
for (var _i = 0; _i < array_length(_cards); _i++) {
	var _c = _cards[_i];
	var _r = _c.r;
	var _h = _c.h;
	if (_y + _h > list_y && _y < room_height) {
		var _ea = ui_anim_in(oa, 2 + _i);
		if (_ea > .001) {
			var _off = (1 - _ea) * UI_IN_DEAL;
			if (_off != 0) matrix_set(matrix_world, matrix_build(0, _off, 0, 0, 0, 0, 1, 1, 1));
			ui_fade_set(_ea);

			// the plate: statistics' panel doctrine - opaque, light top edge,
			// dark bottom edge, gold pip (the newest release's pip is brighter)
			draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y, col_w, _h, 0, c_hsv(169, 160, 7), .96);
			draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y, col_w, 1, 0, c_white, .07);
			draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y + _h - 1, col_w, 1, 0, c_black, .4);
			draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y, 2, _h, 0, c_gold, (_i == 0) ? .95 : .5);

			// the version, large; the date beside it, dim; the name under
			draw_set_font(fnt_large);
			draw_set_color(c_gold);
			draw_set_alpha(.95);
			draw_text(col_x + 8, _y + 4, _r.ver);
			var _vw = string_width(_r.ver);
			draw_set_font(fnt);
			draw_set_color(rgb(120, 130, 150));
			draw_set_alpha(.8);
			draw_text(col_x + 8 + _vw + 8, _y + 6, _r.date);
			draw_set_color(rgb(195, 205, 235));
			draw_set_alpha(.9);
			draw_text(col_x + 8, _y + 17, _r.name);
			draw_sprite_ext(spr_pixel_1x1, 0, col_x + 8, _y + 27, col_w - 16, 1, 0, c_gold, .25);

			// the notes: a tag chip in the kind's colour, the line beside it
			var _ny = _y + 30;
			for (var _k = 0; _k < array_length(_r.notes); _k++) {
				var _n = _r.notes[_k];
				var _kc = __kind_col(_n.kind);
				draw_sprite_ext(spr_pixel_1x1, 0, col_x + 8, _ny, tag_w, 9, 0, merge_colour(_kc, c_black, .6), .95);
				draw_px_rect(col_x + 8, _ny, tag_w, 9, _kc, .6);
				draw_set_halign(fa_center);
				draw_set_color(merge_colour(_kc, c_white, .4));
				draw_set_alpha(.95);
				draw_text(col_x + 8 + tag_w * .5 + 1, _ny + 1, _n.kind);
				draw_set_halign(fa_left);
				draw_set_color(rgb(195, 205, 235));
				draw_set_alpha(.88);
				draw_text_ext(text_x, _ny + 1, _n.txt, line_h, text_w);
				_ny += _c.lines[_k] + 4;
			}

			ui_fade_set(1);
			if (_off != 0) matrix_set(matrix_world, matrix_build_identity());
		}
	}
	_y += _h + 4;
}

// ---- the title strip - slides down from under the header ----
var _sp = ui_anim_in(oa, 1);
if (_sp > .001) {
	var _so = -(1 - _sp) * UI_IN_SLIDE;
	if (_so != 0) matrix_set(matrix_world, matrix_build(0, _so, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_sp);
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, list_y - bby, 0, c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y - 1, room_width, 1, 0, rgb(170, 190, 230), .25);
	draw_set_color(rgb(195, 205, 235));
	draw_set_alpha(.85);
	draw_text(6, bby + 4, "changelog");
	draw_set_halign(fa_right);
	draw_set_color(rgb(120, 130, 150));
	draw_set_alpha(.7);
	draw_text(room_width - 8, bby + 4, string(array_length(releases)) + " releases  -  newest first");
	draw_set_halign(fa_left);
	ui_fade_set(1);
	if (_so != 0) matrix_set(matrix_world, matrix_build_identity());
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt);
