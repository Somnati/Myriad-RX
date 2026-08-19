/// THE DIAL BAR, composed as Myriad DE composes it in obj_dial's Draw:
///
///   [cap][ letter  lv N |== progress + countdown ==| rate ][cap]
///    3px  spr_dial_name    spr_progressbar 70x5 at +39,+3
///
/// COLOURS (DE's obj_dial Step): the identity colour is raw ONLY on the
/// letter and the moving fill. The body is that hue at hsv(130,65)
/// gradient-blended into black; the track is darker still at
/// hsv(200,30). Dark furniture, one living element per row.

if (!variable_global_exists("dial")) exit;
draw_set_font(fnt);

var _n  = __rows();
var _ax = face;
var _dp = clamp(sp, 0, 1);
var _bp = clamp(sp - 1, 0, 1);                 // the buy stage
var _oa = clamp(_dp * 1.6 - .3, 0, 1);         // bars fade in
var _da = clamp(1 - _dp * 2, 0, 1);            // dots fade out
var _ec = sprite_get_width(spr_dial_endcaps);  // 3
var _bw = lerp(row_w, row_w2, _bp);            // the bar narrows for buy

// ============ docked: DE's collapsed dot column ============
// TWO FILLED CIRCLES, no outline (DE's Draw_72): a dark disc at FULL
// size underneath, and the growing disc on top whose RADIUS IS THE
// PROGRESS - the same number the bar shows, so the dot is a readable
// dial in its own right.
if (_da > 0) {
	var _dx = room_width - dock_w * .5;
	for (var _i = 0; _i < _n; _i++) {
		var _d  = g.dial[_i];
		var _c  = dial_color(_i);
		var _y  = row_y1 - _i * 11 + 5;
		var _r0 = row_h * .5;                      // DE's des_size_
		var _bg = merge_colour(_c, c_black, .8);   // the dark disc
		draw_set_alpha(_da);
		draw_circle_colour(_dx, _y, _r0, _bg, _bg, false);
		if (_d.level > 0) {
			var _p  = __perc(_d);
			var _fg = merge_colour(_bg, _c, clamp(_p, 0, 1));
			if (rd[_i] > _r0) _fg = _c;            // the payout pop
			draw_circle_colour(_dx, _y, rd[_i], _fg, _fg, false);
		}
		draw_set_alpha(1);
	}
	draw_sprite_ext(spr_pixel_1x1, 0, room_width - 1, row_y1 - _n * 11 + 2, 1,
		_n * 11 + 8, 0, c_gold, .35 * _da);
}

if (_oa <= 0) { draw_set_alpha(1); draw_set_color(c_white); exit; }

// ===================== out: the bars =====================
for (var _i = 0; _i < _n; _i++) {
	var _d  = g.dial[_i];
	var _x  = _ax;
	var _y  = row_y1 - _i * row_p;
	var _lc = dial_color(_i);
	var _hu = colour_get_hue(_lc);
	var _nc = make_colour_hsv(_hu, 130, 65);
	var _bc = make_colour_hsv(_hu, 200, 30);

	// ---- dormant: DE's unpurchased plate, price centred ----
	if (_d.level <= 0) {
		var _cost = dial_cost(_i, 0, 1);
		var _can  = (g.profit >= _cost);
		draw_sprite_ext(spr_dial, 2, _x, _y, 1, 1, 0,
			merge_colour(c_black, _lc, .12), .9 * _oa);
		draw_set_halign(fa_center);
		draw_set_color(_can ? c_gold : merge_colour(_lc, c_black, .35));
		draw_set_alpha((_can ? .95 : .6) * _oa);
		draw_text(_x + _bw * .5, _y + 2, "purchase " + crunch_arb(_cost));
		draw_set_halign(fa_left);
		continue;
	}

	var _p = __perc(_d);               // 0 through the wind-up
	var _wind = (_d.cycle < AUTOEFF);  // still spinning up

	// ---- body ----
	draw_sprite_ext(spr_dial_endcaps, 0, _x, _y, 1, 1, 0, _nc, _oa);
	draw_sprite_ext(spr_dial_endcaps, 1, _x + _bw - _ec, _y, 1, 1, 0, c_black, _oa);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
		_x + _ec, _y, _bw - _ec * 2, row_h, 0, _nc, c_black, c_black, _nc, _oa);

	// ---- letter glyph + level ----
	draw_sprite_ext(spr_dial_name, _i, _x + 7, _y + row_h * .5 - 1, 1, 1, 0, _lc, _oa);
	draw_set_halign(fa_left);
	draw_set_color(merge_colour(_lc, c_black, .2));
	draw_set_alpha(_oa);
	draw_text(_x + 15, _y + 2, "lv");
	draw_set_color(_lc);
	draw_text(_x + 24, _y + 2, string(_d.level));

	// ---- the progress bar ----
	var _pw = _bw - 39 - _ec - 1;                  // fills to the endcap
	var _ph = sprite_get_height(spr_progressbar);
	var _sw = sprite_get_width(spr_progressbar);
	var _px = _x + 39, _py = _y + 3;
	var _xs = _pw / _sw;                           // scale to the live width
	draw_sprite_general(spr_progressbar, 0, 0, 0, _sw, _ph, _px, _py,
		_xs, 1, 0, _bc, _nc, _nc, _bc, _oa);
	if (_p > 0) {
		draw_sprite_part_ext(spr_progressbar, 0, 0, 0, _p * (_sw - 1), _ph,
			_px, _py, _xs, 1, _lc, _oa);
		draw_sprite_ext(spr_progressbar, 1, _px + _p * (_pw - 1.1), _py,
			1, 1, 0, _lc, _oa);
		draw_sprite_ext(spr_progressbar, 2, _px + _p * (_pw - 1) - _sw + 2, _py,
			1, 1, 0, merge_colour(_lc, c_white, lerp(0, .8, _p * _p)),
			lerp(0, .8, _oa * _p) * (_p * _p));
	}
	if (_d.glow > 0)
		draw_sprite_general(spr_progressbar, 0, 0, 0, _sw, _ph, _px, _py,
			_xs, 1, 0, c_white, c_white, c_white, c_white, _d.glow * _oa);

	// ---- THE COUNTDOWN, centred on the bar (his ask). While the dial
	// is winding up it reads "..." exactly as DE's does - the dial has
	// started, it just has nothing to show yet.
	draw_set_font(fnt_outline);
	draw_set_halign(fa_center);
	draw_set_color(merge_colour(c_white, _lc, .5));
	draw_set_alpha(.95 * _oa);
	var _txt = "...";
	if (!_wind) _txt = crunch_time((1 - _d.cycle) * _d.cycle_t * 60);
	draw_text_transformed(_px + _pw * .5, _py - .5, _txt, .8, .8, 0);

	// what this cycle has accrued so far, at the bar's right end
	if (_p > 0) {
		draw_set_halign(fa_right);
		draw_set_color(merge_colour(c_gray, _lc, .7));
		draw_set_alpha(.85 * _oa);
		draw_text_transformed(_px + _pw - 2, _py - .5,
			crunch_arb(do_scale(_d.gpc, _p)), .8, .8, 0);
	}
	draw_set_font(fnt);
	draw_set_halign(fa_left);

	// ---- STAGE 2: DE's buy button, right of the narrowed bar ----
	if (_bp > .02) {
		var _cost = dial_cost(_i, _d.level, _d.level + 1);
		var _can  = (g.profit >= _cost);
		var _bx   = _x + _bw + 2;
		var _bc2  = merge_colour(_can ? c_gold : c_gray, c_black,
			_can ? .5 : .8);
		draw_sprite_ext(spr_button_bevel, 0, _bx, _y - 2, 1, 1, 0, _bc2, _bp * _oa);
		draw_set_halign(fa_center);
		draw_set_color(_can ? c_gold : c_gray);
		draw_set_alpha((_can ? .95 : .6) * _bp * _oa);
		draw_text_transformed(_bx + sprite_get_width(spr_button_bevel) * .5,
			_y + 1, crunch_arb(_cost), .8, .8, 0);
		draw_set_halign(fa_left);
	}
}

// the fleet's two headline numbers, under the column
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
