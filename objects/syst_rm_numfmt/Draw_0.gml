draw_set_font(fnt);
draw_set_valign(fa_top);

// ---- the title strip ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, sett_ink, .25);
draw_set_halign(fa_left);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 5, "number formats");
draw_set_halign(fa_right);
draw_set_alpha(.55);
draw_text(room_width - 6, bby + 5, "tap a column to make it the game's");
draw_set_alpha(1);

// ---- the column headers ----
for (var _c = 0; _c < array_length(fmts); _c++) {
	var _cx = label_w + _c * col_w;
	var _on = (g.num_format == _c);
	var _hv = (hov == _c);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, tab_y - 12, col_w - 2, 11, 0,
		_on ? merge_colour(c_gold, c_black, .6) : (_hv ? c_hsv(169, 150, 30) : c_hsv(169, 160, 12)), .95);
	if (_on) draw_sprite_ext(spr_pixel_1x1, 0, _cx, tab_y - 12, 2, 11, 0, c_gold, 1);
	draw_set_halign(fa_center);
	draw_set_color(_on ? c_white : (_hv ? c_white : rgb(170, 190, 230)));
	draw_text(_cx + col_w * .5 - 1, tab_y - 10, fmts[_c].name);
}
draw_set_halign(fa_left);

// ---- the rows ----
for (var _r = 0; _r < array_length(amounts); _r++) {
	var _ry = tab_y + _r * row_h;
	var _v = amounts[_r];
	// a hairline every other row, and the row's decade on the left
	if (_r & 1) draw_sprite_ext(spr_pixel_1x1, 0, 0, _ry - 1, room_width, row_h, 0, c_white, .035);
	draw_set_color(rgb(120, 130, 150));
	draw_set_alpha(.8);
	var _lg = (_v >= arb(1)) ? arb_log10(_v) : 0;
	draw_text(4, _ry, "1e" + string(floor(_lg)));
	draw_set_alpha(1);
	for (var _c = 0; _c < array_length(fmts); _c++) {
		var _cx = label_w + _c * col_w;
		var _on = (g.num_format == _c);
		draw_set_color(_on ? c_white : ((hov == _c) ? merge_colour(c_white, c_gold, .5) : rgb(195, 205, 235)));
		draw_set_alpha(_on ? 1 : .8);
		draw_text(_cx + 3, _ry, __cell(_v, _c));
	}
}
draw_set_alpha(1);

// ---- the footer: what each is ----
var _fy = tab_y + array_length(amounts) * row_h + 4;
if (hov != -1) {
	draw_set_color(rgb(195, 205, 235));
	draw_set_alpha(.75);
	draw_text(4, _fy, fmts[hov].name + ": " + fmts[hov].help);
}
draw_set_alpha(1);
draw_set_color(c_white);
