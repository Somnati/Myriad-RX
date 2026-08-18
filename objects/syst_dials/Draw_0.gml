/// the column. One row per dial: identity bubble, level, the cycle bar
/// filling toward its payout, and what that payout is worth. An unowned
/// dial shows its price instead and lights up when you can afford it.

if (!variable_global_exists("dial")) exit;
draw_set_font(fnt);

var _n = __rows();
for (var _i = 0; _i < _n; _i++) {
	var _d  = g.dial[_i];
	var _y  = row_y0 + _i * row_h;
	var _col = dial_color(_i);
	var _own = (_d.level > 0);

	// the row plate
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _y, row_w, row_h - 2, 0,
		c_black, _own ? .55 : .35);

	// the cycle bar: the fill IS the progress toward the next payout,
	// and it flashes on the frame the cycle lands (prod_dials' paid)
	if (_own) {
		var _bw = (row_w - 26) * clamp(_d.cycle, 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, row_x + 23, _y + 1, _bw,
			row_h - 4, 0, _col, .30 + .25 * _d.glow);
	}
	draw_px_rect(row_x, _y, row_w, row_h - 2, _col, _own ? .45 : .22);

	// the identity bubble + letter
	var _cx = row_x + 10;
	var _cy = _y + (row_h - 2) * .5;
	draw_circle_colour(_cx, _cy, 5.5 + _d.glow * 1.5, _col, _col, false);
	draw_set_halign(fa_center);
	draw_set_color(c_black);
	draw_set_alpha(.9);
	draw_text(_cx, _cy - 4, dial_config(_i).name);

	draw_set_halign(fa_left);
	draw_set_alpha(.95);
	if (_own) {
		// level left of the bar, per-cycle payout right-aligned in it
		draw_set_color(sett_ink);
		draw_text(row_x + 24, _y + 1, "lv " + string(_d.level));
		draw_set_halign(fa_right);
		draw_set_color(c_gold);
		draw_text(row_x + row_w - 4, _y + 1, crunch_arb(_d.gpc));
	} else {
		// dormant: the price, gold once it is within reach
		var _cost = dial_cost(_i, 0, 1);
		var _can  = (g.profit >= _cost);
		draw_set_color(_can ? c_gold : sett_ink);
		draw_set_alpha(_can ? .95 : .5);
		draw_text(row_x + 24, _y + 1, "buy " + crunch_arb(_cost));
	}
	draw_set_halign(fa_left);
}

// the fleet's rate, right under the column - DE keeps this readout
// permanently on screen and it is the number the player actually
// steers by
draw_set_halign(fa_center);
draw_set_color(c_gold);
draw_set_alpha(.85);
draw_text(room_width * .5, row_y0 + _n * row_h + 3,
	crunch_arb(g.all_gps) + "/sec");
draw_set_color(sett_ink);
draw_set_alpha(.6);
draw_text(room_width * .5, row_y0 + _n * row_h + 13,
	"per tap " + crunch_arb(g.click_gps));

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
