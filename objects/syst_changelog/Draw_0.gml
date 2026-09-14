/// the column (scrolled): era bands, release cards folded or open, then
/// the strip OVER them so a row sliding up disappears into it. The
/// overlay's open recipe: rows deal in, the strip slides from under the
/// header.

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// (no ground of its own: obj_menu2_bck paints the plate UNDER the blur)

var _rows = __rows();
var _y = list_y + 4 - scroll;
var _dim = rgb(120, 130, 150);
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _rw = _rows[_i];
	var _h = _rw.h;
	if (_y + _h > list_y && _y < room_height) {
		var _ea = ui_anim_in(oa, 2 + _i);
		if (_ea > .001) {
			var _off = (1 - _ea) * UI_IN_DEAL;
			if (_off != 0) matrix_set(matrix_world, matrix_build(0, _off, 0, 0, 0, 0, 1, 1, 1));
			ui_fade_set(_ea);
			var _ch = __chip_r(_y);
			var _hov = point_in_rectangle(mouse_x, mouse_y, col_x, _y, col_x + col_w, _y + ((_rw.kind == "era") ? era_h : head_h));

			if (_rw.kind == "era") {
				// THE ERA'S BAND: its name in gold with a rule to the chip, the
				// note dim under the name when open
				draw_set_color(merge_colour(c_gold, c_white, .3));
				draw_set_alpha(_hov ? 1 : .85);
				draw_text(col_x + 2, _y + 3, _rw.e.era);
				var _nw = string_width(_rw.e.era);
				draw_sprite_ext(spr_pixel_1x1, 0, col_x + 2 + _nw + 6, _y + 7, max(0, _ch.x - 6 - (col_x + 2 + _nw + 6)), 1, 0, c_gold, .3);
				if (!_rw.open) {
					draw_set_color(_dim);
					draw_set_alpha(.7);
					draw_set_halign(fa_right);
					draw_text(_ch.x - 6, _y + 3, string(array_length(_rw.e.releases)) + " release" + ((array_length(_rw.e.releases) == 1) ? "" : "s"));
					draw_set_halign(fa_left);
				}
			} else {
				var _r = _rw.r;
				// the plate: statistics' panel doctrine - opaque, light top edge,
				// dark bottom edge, gold pip (brighter while open)
				draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y, col_w, _h, 0, c_hsv(169, 160, 7), .96);
				draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y, col_w, 1, 0, c_white, .07);
				draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y + _h - 1, col_w, 1, 0, c_black, .4);
				draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y, 2, _h, 0, c_gold, _rw.open ? .95 : .45);
				if (_hov) draw_sprite_ext(spr_pixel_1x1, 0, col_x, _y, col_w, head_h, 0, c_white, .04);

				// the version, large; the date beside it, dim; the name under
				draw_set_font(fnt_large);
				draw_set_color(c_gold);
				draw_set_alpha(_rw.open ? .95 : .75);
				draw_text(col_x + 8, _y + 4, _r.ver);
				var _vw = string_width(_r.ver);
				draw_set_font(fnt);
				draw_set_color(_dim);
				draw_set_alpha(.8);
				draw_text(col_x + 8 + _vw + 8, _y + 6, _r.date);
				draw_set_color(rgb(195, 205, 235));
				draw_set_alpha(_rw.open ? .9 : .7);
				draw_text(col_x + 8, _y + 17, _r.name);

				if (_rw.open) {
					draw_sprite_ext(spr_pixel_1x1, 0, col_x + 8, _y + 27, col_w - 16, 1, 0, c_gold, .25);
					// the notes: a tag chip in the kind's colour, the line beside it
					var _ny = _y + head_h + 2;
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
						_ny += _rw.lines[_k] + 4;
					}
				}
			}

			// THE +/- CHIP (the house folder glyph, statistics' language): a
			// square with a plus while folded, a dash while open
			var _cc = (_rw.kind == "era") ? c_gold : merge_colour(c_gold, c_white, .2);
			draw_sprite_ext(spr_pixel_1x1, 0, _ch.x, _ch.y, _ch.w, _ch.h, 0, c_black, .8);
			draw_px_rect(_ch.x, _ch.y, _ch.w, _ch.h, _cc, _hov ? .95 : .55);
			draw_sprite_ext(spr_pixel_1x1, 0, _ch.x + 2, _ch.y + 4, _ch.w - 4, 1, 0, _cc, .95);
			if (!_rw.open) draw_sprite_ext(spr_pixel_1x1, 0, _ch.x + 4, _ch.y + 2, 1, _ch.h - 4, 0, _cc, .95);

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
	// THE TALLY (his ask, 2026-09-14: "total bugs fixed starting on
	// release"): it counts ITSELF off the log - every "fixed" line in every
	// release is a bug squashed since release, so the number can never
	// disagree with the notes under it
	var _nrel = 0, _nfix = 0;
	for (var _i = 0; _i < array_length(eras); _i++) {
		var _rs = eras[_i].releases;
		_nrel += array_length(_rs);
		for (var _j = 0; _j < array_length(_rs); _j++)
			for (var _k = 0; _k < array_length(_rs[_j].notes); _k++)
				if (_rs[_j].notes[_k].kind == "fixed") _nfix += 1;
	}
	draw_set_halign(fa_right);
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(room_width - 8, bby + 4, string(_nrel) + " release" + ((_nrel == 1) ? "" : "s") + "  -  " + string(_nfix) + " bug" + ((_nfix == 1) ? "" : "s") + " squashed since release");
	draw_set_halign(fa_left);
	ui_fade_set(1);
	if (_so != 0) matrix_set(matrix_world, matrix_build_identity());
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt);
