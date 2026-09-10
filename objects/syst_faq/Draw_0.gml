/// the screen body: backdrop, the active tab's cards (scrolled), then
/// the strip and the rail OVER them so a card sliding up disappears
/// into the strip. The overlay's open recipe: backdrop first, cards
/// deal in, strip and rail slide from their own edges.

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---- the ground ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, room_height, 0,
	c_black, .72 * ui_anim_in(oa, 0));

// ---- the cards ----
var _cards = __cards();
var _y = list_y + 4 - scroll;
var _sec = sections[tab];
for (var _i = 0; _i < array_length(_cards); _i++) {
	var _c = _cards[_i];
	var _e = _c.e;
	var _h = _c.h;
	if (_y + _h > list_y && _y < room_height) {
		// the deal-in: each card rides ui_anim_in with its own index
		var _ea = ui_anim_in(oa, 2 + _i);
		if (_ea > .001) {
			var _off = (1 - _ea) * UI_IN_DEAL;
			if (_off != 0) matrix_set(matrix_world, matrix_build(0, _off, 0, 0, 0, 0, 1, 1, 1));
			ui_fade_set(_ea);

			// the plate: statistics' panel doctrine - opaque, light top
			// edge, dark bottom edge, the section's colour as a pip
			draw_sprite_ext(spr_pixel_1x1, 0, content_x, _y, content_w, _h, 0,
				c_hsv(169, 160, 7), .96);
			draw_sprite_ext(spr_pixel_1x1, 0, content_x, _y, content_w, 1, 0, c_white, .07);
			draw_sprite_ext(spr_pixel_1x1, 0, content_x, _y + _h - 1, content_w, 1, 0, c_black, .4);
			draw_sprite_ext(spr_pixel_1x1, 0, content_x, _y, 2, _h, 0, _sec.col, .8);

			// the title, in the section's colour, and the body wrapped
			draw_set_halign(fa_left);
			draw_set_color(merge_colour(_sec.col, c_white, .3));
			draw_set_alpha(.95);
			draw_text(content_x + 8, _y + 4, _e.title);
			draw_set_color(rgb(195, 205, 235));
			draw_set_alpha(.85);
			draw_text_ext(content_x + 8, _y + 15, _e.body, line_h, text_w);

			// the art box, right, vertically centred in the card
			if (!is_undefined(_e.art)) {
				var _ax = content_x + content_w - art_w - 4;
				var _ay = _y + (_h - art_h) * .5;
				draw_sprite_ext(spr_pixel_1x1, 0, _ax, _ay, art_w, art_h, 0, c_black, .35);
				draw_px_rect(_ax, _ay, art_w, art_h, _sec.col, .18);
				var _art = _e.art;
				draw_set_alpha(1);
				draw_set_color(c_white);
				if (variable_struct_exists(_art, "spr")) {
					var _sc = _art[$ "scale"] ?? 1;
					var _fr = _art[$ "frame"] ?? 0;
					var _cl = _art[$ "col"] ?? c_white;
					// a wide sprite shrinks to the box rather than spilling
					var _sw = sprite_get_width(_art.spr) * _sc;
					if (_sw > art_w - 4) _sc *= (art_w - 4) / _sw;
					draw_sprite_ext(_art.spr, _fr, _ax + art_w * .5, _ay + art_h * .5,
						_sc, _sc, 0, _cl, 1);
				}
				else if (variable_struct_exists(_art, "fn")) {
					_art.fn(_ax, _ay, art_w, art_h);
					draw_set_font(fnt);
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					draw_set_alpha(1);
				}
			}

			ui_fade_set(1);
			if (_off != 0) matrix_set(matrix_world, matrix_build_identity());
		}
	}
	_y += _h + 3;
}

// a thin scroll mark at the band's right edge, only when there is more
var _smax = __scroll_max();
if (_smax > 0) {
	var _bh = room_height - list_y - 4;
	var _th = max(12, _bh * _bh / (_bh + _smax));
	var _ty = list_y + 2 + (_bh - _th) * (scroll / _smax);
	draw_sprite_ext(spr_pixel_1x1, 0, room_width - 3, _ty, 2, _th, 0, _sec.col, .35 * ui_anim_in(oa, 2));
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
	draw_text(6, bby + 4, "faq");
	ui_fade_set(1);
	if (_so != 0) matrix_set(matrix_world, matrix_build_identity());
}

// ---- the category rail - settings' exact chrome, from its own edge ----
var _rp = ui_anim_in(oa, 1);
var _ro = -(1 - _rp) * (rail_w + UI_IN_SLIDE);
if (_ro != 0) matrix_set(matrix_world, matrix_build(_ro, 0, 0, 0, 0, 0, 1, 1, 1));
ui_fade_set(_rp);
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, rail_w, room_height - list_y, 0, c_hsv(169, 186, 7), .97);
draw_sprite_ext(spr_pixel_1x1, 0, rail_w - 1, list_y, 1, room_height - list_y, 0, c_black, .5);
var _tb = __tabs();
for (var _i = 0; _i < array_length(_tb); _i++) {
	var _t = _tb[_i];
	var _s = sections[_t.idx];
	var _on = (_i == tab);
	var _hov = point_in_rectangle(mouse_x, mouse_y, _t.x1, _t.y1, _t.x2, _t.y2);
	var _tw = _t.x2 - _t.x1;
	var _th2 = _t.y2 - _t.y1;
	draw_set_alpha(1);
	if (_on)
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x1, _t.y1, _tw, _th2, 0, merge_colour(_s.col, c_black, .6), .92);
	else
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _t.x1, _t.y1, _tw, _th2, 0,
			c_black, merge_colour(_s.col, c_black, _hov ? .5 : .75),
			merge_colour(_s.col, c_black, _hov ? .5 : .75), c_black, .85);
	draw_sprite_ext(spr_pixel_1x1, 0, _t.x1, _t.y1, _hov || _on ? 3 : 2, _th2, 0,
		merge_colour(_s.col, c_white, .2), 1);
	draw_set_halign(fa_left);
	draw_set_color(_on ? c_white : merge_colour(_s.col, c_white, _hov ? .7 : .45));
	draw_set_alpha(.95);
	draw_text(_t.x1 + 7, _t.y1 + ((_th2 - 7) div 2), _s.name);
}
ui_fade_set(1);
if (_ro != 0) matrix_set(matrix_world, matrix_build_identity());

draw_set_alpha(1);
draw_set_color(c_white);
