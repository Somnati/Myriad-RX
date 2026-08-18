/// the drawer. Docked it is a column of breathing dots; out it is a
/// stack of Myriad DE's dial bars.
/// DE's bar reads left to right: identity bubble, level, the cycle
/// filling the bar itself, and what a completed cycle pays. The FILL IS
/// THE CYCLE - that is the whole animation, and it is why a dial is
/// legible at a glance without reading a single number.

if (!variable_global_exists("dial")) exit;
draw_set_font(fnt);

var _n  = __rows();
var _ax = face;               // the sliding face (Step publishes it)
var _oa = clamp(dpos * 1.6 - .3, 0, 1);       // rows fade in as it opens
var _da = clamp(1 - dpos * 2, 0, 1);          // dots fade out

// ================= docked: the dot column =================
// each dot breathes with its cycle and swells on payout, so the closed
// drawer still tells you the fleet is alive (DE's collapsed column)
if (_da > 0) {
	var _dx = room_width - dock_w * .5;
	for (var _i = 0; _i < _n; _i++) {
		var _d = g.dial[_i];
		var _c = dial_color(_i);
		var _y = col_y0 + _i * 11 + 5;
		if (_d.level <= 0) {
			draw_circle_colour(_dx, _y, 2, c_black, c_black, false);
			draw_set_alpha(.35 * _da);
			draw_circle_colour(_dx, _y, 2, _c, _c, true);
			draw_set_alpha(1);
			continue;
		}
		// radius rides the cycle (squared, so it eases in) plus the
		// payout flash - DE's des_size = gps_perc * gps_perc
		var _p = clamp(_d.cycle, 0, 1);
		var _r = 2 + _p * _p * 2 + _d.glow * 2;
		draw_set_alpha(_da);
		draw_circle_colour(_dx, _y, _r, _c, _c, false);
		draw_set_alpha(1);
	}
	// the grab handle: a hairline down the dock so the edge reads as
	// something you can pull
	draw_sprite_ext(spr_pixel_1x1, 0, room_width - 1, col_y0 - 4, 1,
		_n * 11 + 8, 0, c_gold, .35 * _da);
}

// ================= out: the bars =================
if (_oa <= 0) { draw_set_alpha(1); draw_set_color(c_white); exit; }

for (var _i = 0; _i < _n; _i++) {
	var _d   = g.dial[_i];
	var _c   = dial_color(_i);
	var _own = (_d.level > 0);
	var _y   = col_y0 + _i * row_p;
	var _x   = _ax;

	// the plate
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, row_w, row_h, 0,
		c_black, (_own ? .8 : .55) * _oa);

	if (_own) {
		// THE CYCLE IS THE FILL. A soft body plus a bright leading edge
		// so the eye catches the sweep even on a slow dial.
		var _fw = (row_w - 2) * clamp(_d.cycle, 0, 1);
		if (_fw > 0) {
			draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y + 1, _fw,
				row_h - 2, 0, _c, (.22 + .18 * _d.glow) * _oa);
			draw_sprite_ext(spr_pixel_1x1, 0, _x + _fw, _y + 1, 1,
				row_h - 2, 0, _c, .75 * _oa);
		}
	}
	draw_px_rect(_x, _y, row_w, row_h, _c, (_own ? .5 : .25) * _oa);

	// the identity bubble + its letter
	var _cx = _x + 8;
	var _cy = _y + row_h * .5;
	draw_set_alpha(_oa);
	draw_circle_colour(_cx, _cy, 4.5 + _d.glow, _c, _c, !_own);
	draw_set_halign(fa_center);
	if (_own) {
		draw_set_color(c_black);
		draw_text(_cx, _cy - 4, dial_config(_i).name);
	}
	draw_set_halign(fa_left);

	if (_own) {
		draw_set_color(sett_ink);
		draw_set_alpha(.9 * _oa);
		draw_text(_x + 16, _y + 2, "lv " + string(_d.level));
		// what one completed cycle pays, right-aligned in the bar
		draw_set_halign(fa_right);
		draw_set_color(c_gold);
		draw_set_alpha(.95 * _oa);
		draw_text(_x + row_w - 4, _y + 2, crunch_arb(_d.gpc));
	} else {
		// dormant: its price, gold the moment it is affordable
		var _cost = dial_cost(_i, 0, 1);
		var _can  = (g.profit >= _cost);
		draw_set_color(_can ? c_gold : sett_ink);
		draw_set_alpha((_can ? .95 : .45) * _oa);
		draw_text(_x + 16, _y + 2, "buy");
		draw_set_halign(fa_right);
		draw_text(_x + row_w - 4, _y + 2, crunch_arb(_cost));
	}
	draw_set_halign(fa_left);
}

// the two numbers the player actually steers by, under the column
draw_set_halign(fa_center);
draw_set_color(c_gold);
draw_set_alpha(.85 * _oa);
draw_text(_ax + row_w * .5, col_y0 + _n * row_p + 4,
	crunch_arb(g.all_gps) + "/sec");
draw_set_color(sett_ink);
draw_set_alpha(.55 * _oa);
draw_text(_ax + row_w * .5, col_y0 + _n * row_p + 14,
	"per tap " + crunch_arb(g.click_gps));

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
