/// the log's face. Draw-only; the Step's hits share this geometry.
/// Cards first (scrolled, dealt in), then the strip OVER them so a card
/// sliding up disappears into it (the faq's recipe).

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _dbg  = g.offlog.debug;
var _rows = __rows();
var _y    = list_y + 4 + __sim_h() - scroll;
var _run  = -1;

for (var _i = 0; _i < array_length(_rows); _i++) {
	var _r = _rows[_i];
	var _h = _r.h;
	if (_r.kind == "hdr") _run = _r.run;
	if (_y + _h > list_y && _y < room_height) {
		// the deal-in: each CARD rides ui_anim_in with its own index
		var _ea = ui_anim_in(oa, 2 + max(_run, 0));
		if (_ea > .001) {
			var _off = (1 - _ea) * UI_IN_DEAL;
			if (_off != 0) matrix_set(matrix_world, matrix_build(0, _off, 0, 0, 0, 0, 1, 1, 1));
			ui_fade_set(_ea);
			switch (_r.kind) {
			case "hdr": {
				var _e = _r.e;
				// the plate: statistics' panel doctrine - opaque, light
				// top edge, the source's colour as a pip
				var _pc = (_e.src == "suspended") ? c_horange : ((string_pos("sim", _e.src) == 1) ? c_lavender : c_sgreen);
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, cw, _h - 1, 0, c_hsv(169, 160, 7), .96);
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, cw, 1, 0, c_white, .07);
				draw_sprite_ext(spr_pixel_1x1, 0, cx, _y, 2, _h - 1, 0, _pc, .85);
				draw_set_halign(fa_left);
				draw_set_color(c_gold);
				draw_set_alpha(.95);
				draw_text(cx + 8, _y + 4, "away " + __tm(_e.secs));
				if (land) {   // (in portrait the pip's colour says it)
					draw_set_color(_pc);
					draw_set_alpha(.75);
					draw_text(cx + 8 + string_width("away " + __tm(_e.secs)) + 8, _y + 4, _e.src);
				}
				draw_set_halign(fa_right);
				draw_set_color(dim);
				draw_set_alpha(.7);
				draw_text(val_x, _y + 4, autom_ago(_e.at));
				break;
			}
			case "sec": {
				draw_sprite_ext(spr_pixel_1x1, 0, cx + 4, _y + 4, 3, 3, 0, _r.col, .9);
				draw_set_halign(fa_left);
				draw_set_color(_r.col);
				draw_set_alpha(.8);
				draw_text(lab_x, _y + 2, _r.txt);
				draw_sprite_ext(spr_pixel_1x1, 0, lab_x + string_width(_r.txt) + 6, _y + 5, max(0, val_x - lab_x - string_width(_r.txt) - 6), 1, 0, _r.col, .12);
				break;
			}
			case "row": {
				draw_set_halign(fa_left);
				draw_set_color(sett_ink);
				draw_set_alpha(.6);
				draw_text(lab_x, _y + 2, _r.l);
				draw_set_halign(fa_right);
				draw_set_color(_r.col);
				draw_set_alpha(.95);
				draw_text(val_x, _y + 2, _r.v);
				break;
			}
			case "sub": {
				draw_set_halign(fa_left);
				draw_set_color(dim);
				draw_set_alpha(.7);
				if (_r.l != "") draw_text(ind_x, _y + 1, _r.l);
				draw_set_halign(fa_right);
				draw_set_color(_r.col);
				draw_set_alpha(.8);
				draw_text(val_x, _y + 1, _r.v);
				break;
			}
			case "note": {
				draw_set_halign(fa_center);
				draw_set_color(_r.col);
				draw_set_alpha(.7);
				draw_text(cx + cw * .5, _y + 2, _r.txt);
				break;
			}
			}
			ui_fade_set(1);
			if (_off != 0) matrix_set(matrix_world, matrix_build_identity());
		}
	}
	_y += _h;
}

// ---- the sim row (debug): drawn in the band, scrolls with it ----
if (_dbg) {
	var _sy = list_y + 3 - scroll;
	if (_sy + 12 > list_y && _sy < room_height) {
		var _ea2 = ui_anim_in(oa, 1);
		ui_fade_set(_ea2);
		draw_set_halign(fa_left);
		draw_set_color(c_lavender);
		draw_set_alpha(.8);
		draw_text(cx + 4, _sy + 3, "sim");
		for (var _i = 0; _i < array_length(sims); _i++) {
			var _sr = __sim_r(_i);
			draw_set_alpha(1);
			draw_sprite_ext(spr_pixel_1x1, 0, _sr.x, _sr.y, _sr.w, _sr.h, 0, c_black, .8);
			draw_px_rect(_sr.x, _sr.y, _sr.w, _sr.h, c_lavender, .6);
			draw_set_halign(fa_center);
			draw_set_color(c_lavender);
			draw_set_alpha(.9);
			draw_text(_sr.x + _sr.w * .5, _sr.y + 3, sims[_i][1]);
		}
		var _lr = __sim_r(array_length(sims) - 1);
		draw_set_halign(fa_left);
		draw_set_color(dim);
		draw_set_alpha(.6);
		draw_text(_lr.x + _lr.w + 8, _sy + 3, land ? "applies for real - the boot path, fed by hand" : "for real");
		ui_fade_set(1);
	}
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
	draw_set_color(c_sgreen);
	draw_set_alpha(.95);
	draw_text(6, hh + 5, "offline log");
	draw_set_color(dim);
	draw_set_alpha(.6);
	var _n = array_length(g.offlog.runs);
	draw_text(6 + string_width("offline log") + 8, hh + 5,
		(_n == 0) ? "" : (string(_n) + (land ? ((_n == 1) ? " absence this session" : " absences this session") : "")));
	// [debug]: the chip (settings' language)
	var _dr = __dbg_r();
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _dr.x, _dr.y, _dr.w, _dr.h, 0, c_black, .8);
	draw_px_rect(_dr.x, _dr.y, _dr.w, _dr.h, _dbg ? c_lavender : rgb(170, 190, 230), _dbg ? .9 : .5);
	draw_set_halign(fa_center);
	draw_set_color(_dbg ? c_lavender : c_white);
	draw_set_alpha(.9);
	draw_text(_dr.x + _dr.w * .5, _dr.y + 3, "debug");
	ui_fade_set(1);
	if (_so != 0) matrix_set(matrix_world, matrix_build_identity());
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_color(c_white);
