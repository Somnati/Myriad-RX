/// THE DIAL BAR, composed exactly as Myriad DE composes it in
/// obj_dial's Draw - same sprites, same seats, same colour model, so
/// this reads as Myriad rather than as an approximation of it:
///
///   [endcap][ letter  lv N |=== progress ===|      per/sec ][endcap]
///     3px     spr_dial_name     spr_progressbar
///             at +7             70x5 at +39,+3
///
/// COLOURS (DE's obj_dial Step): the identity colour `lc` is used raw
/// only for the letter and the moving fill. The bar BODY is that hue
/// dropped to hsv(130,65) and gradient-blended into black, and the
/// progress TRACK is darker still at hsv(200,30) - which is why DE's
/// column reads as dark furniture with one bright living element per
/// row, instead of thirteen shouting colour bars.

if (!variable_global_exists("dial")) exit;
draw_set_font(fnt);

var _n  = __rows();
var _ax = face;                               // the sliding face
var _oa = clamp(dpos * 1.6 - .3, 0, 1);       // bars fade in as it opens
var _da = clamp(1 - dpos * 2, 0, 1);          // dots fade out
var _ec = sprite_get_width(spr_dial_endcaps); // 3

// ================= docked: DE's collapsed dot column =================
if (_da > 0) {
	var _dx = room_width - dock_w * .5;
	for (var _i = 0; _i < _n; _i++) {
		var _d = g.dial[_i];
		var _c = dial_color(_i);
		var _y = row_y1 - _i * 11 + 5;
		if (_d.level <= 0) {
			draw_set_alpha(.35 * _da);
			draw_circle_colour(_dx, _y, 2, _c, _c, true);
			draw_set_alpha(1);
			continue;
		}
		// DE's des_size: the radius rides progress SQUARED, so the dot
		// swells late in the cycle and pops on payout
		var _p = clamp(_d.cycle, 0, 1);
		draw_set_alpha(_da);
		draw_circle_colour(_dx, _y, 2 + _p * _p * 2 + _d.glow * 2, _c, _c, false);
		draw_set_alpha(1);
	}
	draw_sprite_ext(spr_pixel_1x1, 0, room_width - 1, row_y1 - _n * 11 + 2, 1,
		_n * 11 + 8, 0, c_gold, .35 * _da);
}

if (_oa <= 0) { draw_set_alpha(1); draw_set_color(c_white); exit; }

// ========================= out: the bars =========================
for (var _i = 0; _i < _n; _i++) {
	var _d  = g.dial[_i];
	var _x  = _ax;
	var _y  = row_y1 - _i * row_p;      // dial a lowest, stacking upward
	var _lc = dial_color(_i);           // identity
	var _hu = colour_get_hue(_lc);
	var _nc = make_colour_hsv(_hu, 130, 65);   // body
	var _bc = make_colour_hsv(_hu, 200, 30);   // progress track
	var _p  = clamp(_d.cycle, 0, 1);

	// ---- dormant: DE draws the bar's "unpurchased" frame and centres
	// the price on it ----
	if (_d.level <= 0) {
		var _cost = dial_cost(_i, 0, 1);
		var _can  = (g.profit >= _cost);
		draw_sprite_ext(spr_dial, 2, _x, _y, 1, 1, 0,
			merge_colour(c_black, _lc, .12), .9 * _oa);
		draw_set_halign(fa_center);
		draw_set_color(_can ? c_gold : merge_colour(_lc, c_black, .35));
		draw_set_alpha((_can ? .95 : .6) * _oa);
		draw_text(_x + row_w * .5, _y + 2, "purchase " + crunch_arb(_cost));
		draw_set_halign(fa_left);
		continue;
	}

	// ---- the bar body: endcap, gradient, endcap ----
	draw_sprite_ext(spr_dial_endcaps, 0, _x, _y, 1, 1, 0, _nc, _oa);
	draw_sprite_ext(spr_dial_endcaps, 1, _x + row_w - _ec, _y, 1, 1, 0,
		c_black, _oa);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
		_x + _ec, _y, row_w - _ec * 2, row_h, 0, _nc, c_black, c_black, _nc, _oa);

	// ---- the letter glyph (spr_dial_name carries a..z) ----
	draw_sprite_ext(spr_dial_name, _i, _x + 7, _y + row_h * .5 - 1, 1, 1, 0,
		_lc, _oa);

	// ---- level ----
	draw_set_halign(fa_left);
	draw_set_color(merge_colour(_lc, c_black, .2));
	draw_set_alpha(_oa);
	draw_text(_x + 15, _y + 2, "lv");
	draw_set_color(_lc);
	draw_text(_x + 24, _y + 2, string(_d.level));

	// ---- the progress bar: track, fill, leading cap, comet ----
	var _pw = sprite_get_width(spr_progressbar);   // 70
	var _px = _x + 39, _py = _y + 3;
	draw_sprite_general(spr_progressbar, 0, 0, 0, _pw,
		sprite_get_height(spr_progressbar), _px, _py, 1, 1, 0,
		_bc, _nc, _nc, _bc, _oa);
	if (_p > 0) {
		draw_sprite_part_ext(spr_progressbar, 0, 0, 0, _p * (_pw - 1),
			sprite_get_height(spr_progressbar), _px, _py, 1, 1, _lc, _oa);
		draw_sprite_ext(spr_progressbar, 1, _px + _p * (_pw - 1.1), _py,
			1, 1, 0, _lc, _oa);
		// the comet: brightens toward white as the cycle completes
		draw_sprite_ext(spr_progressbar, 2, _px + _p * (_pw - 1) - _pw + 2,
			_py, 1, 1, 0, merge_colour(_lc, c_white, lerp(0, .8, _p * _p)),
			lerp(0, .8, _oa * _p) * (_p * _p));
	}
	// the payout flash
	if (_d.glow > 0)
		draw_sprite_ext(spr_progressbar, 0, _px, _py, 1, 1, 0, c_white,
			_d.glow * _oa);

	// ---- what is ACCRUING in this cycle, right-aligned in the bar
	// (DE shows the cycle's partial take, which is what makes a slow
	// dial feel like it is earning rather than waiting) ----
	draw_set_font(fnt_outline);
	if (_p > 0) {
		draw_set_halign(fa_right);
		draw_set_color(merge_colour(c_gray, _lc, .7));
		draw_set_alpha(.9 * _oa);
		draw_text_transformed(_px + _pw - 2, _py - .5,
			crunch_arb(do_scale(_d.gpc, _p)), .8, .8, 0);
	}
	draw_set_font(fnt);

	// ---- the rate, past the bar's right end ----
	draw_set_halign(fa_right);
	draw_set_color(c_gold);
	draw_set_alpha(.95 * _oa);
	draw_text(_x + row_w - _ec - 1, _y + 2, crunch_arb(_d.gps));
	draw_set_halign(fa_left);
}

// the fleet's two headline numbers, tucked under the column
draw_set_halign(fa_center);
draw_set_color(c_gold);
draw_set_alpha(.85 * _oa);
draw_text(_ax + row_w * .5, row_y1 + row_p, crunch_arb(g.all_gps) + "/sec");
draw_set_color(sett_ink);
draw_set_alpha(.55 * _oa);
draw_text(_ax + row_w * .5, row_y1 + row_p + 10,
	"per tap " + crunch_arb(g.click_gps));

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
