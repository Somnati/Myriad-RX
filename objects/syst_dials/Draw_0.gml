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
// the fades run the FULL travel now. The old curves saturated early
// (alpha hit 1 at 81% of the slide), which left the last stretch
// moving at full opacity and made the arrival read as a pop.
var _oa = _dp * _dp;                           // bars fade in
var _da = (1 - _dp) * (1 - _dp);               // dots fade out
var _ec = sprite_get_width(spr_dial_endcaps);  // 3
var _bw = lerp(row_w, row_w2, _bp);            // the bar narrows for buy

// ============ the backdrop ============
// DE dims the play area behind its dial drawer; the dim rides the same
// eased position, so it arrives with the bars instead of switching on.
// Drawn FIRST in this event, so it covers the visualiser (depth 50)
// and the tap surface while the bars land on top of it. The header
// sits at -1000 and stays clear, which is what DE does too.
if (_dp > 0)
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0,
		c_black, .62 * _dp);

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
		var _y  = __dot_y(_i);          // the row it becomes
		var _r0 = row_h * .5;                      // DE's des_size_
		var _bg = merge_colour(_c, c_black, .8);   // the dark disc
		draw_set_alpha(_da);
		draw_circle_colour(_dx, _y, _r0, _bg, _bg, false);
		if (_d.level > 0) {
			var _p  = __perc(_i, _d);
			var _fg = merge_colour(_bg, _c, clamp(_p, 0, 1));
			if (rd[_i] > _r0) _fg = _c;            // the payout pop
			draw_circle_colour(_dx, _y, rd[_i], _fg, _fg, false);
		}
		draw_set_alpha(1);
	}
	// the gold edge hairline spans the dot column, so it grew with the
	// dots when the pitch changed
	var _gy0 = __dot_y(_n - 1) - row_h * .5 - 2;
	var _gy1 = __dot_y(0) + row_h * .5 + 2;
	draw_sprite_ext(spr_pixel_1x1, 0, room_width - 1, _gy0, 1,
		_gy1 - _gy0, 0, c_gold, .35 * _da);
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
		draw_set_color(_can ? g.profit_color : merge_colour(_lc, c_black, .35));
		draw_set_alpha((_can ? .95 : .6) * _oa);
		draw_text(_x + _bw * .5, _y + 2, "purchase " + crunch_arb(_cost));
		draw_set_halign(fa_left);
		continue;
	}

	var _p    = __perc(_i, _d);   // 0 through the wind-up
	var _wind = __wind(_i, _d);   // still spinning up

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
	// the level SHRINKS to fit the 15px between "lv" and the bar (DE's
	// sc), so a three-digit level never runs under the bar
	var _lt = string(_d.level);
	var _ls = min(1, 14 / max(1, string_width(_lt)));
	draw_text_transformed(_x + 24, _y + 2 + lerp(3, 0, _ls), _lt, _ls, _ls, 0);
	// the buy stage says how many levels the live mode buys: "+3" UNDER
	// the level, DE's seat (obj_dial draws its mtext a line below "lv")
	if (_bp > .02 && _i < array_length(quote) && !is_undefined(quote[_i]))
	if (quote[_i].n > 0) {
		draw_set_color(quote[_i].ok ? c_sgreen : merge_colour(c_sgreen, c_black, .5));
		draw_set_alpha(_bp * _oa);
		draw_text_transformed(_x + 15, _y + 6, "+" + string(quote[_i].n), .7, .7, 0);
	}

	// ---- the progress bar: DE's 70 wide at the list stage (the rate
	// readout owns the seat past it), narrowing with the bar for buy ----
	var _pw = min(sprite_get_width(spr_progressbar), _bw - 39 - _ec - 1);
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

	// WHAT THIS CYCLE HAS ACCRUED, at the bar's right end. DE colours it
	// off the DIAL, not off money: obj_dial's
	// set_color(merge_colour(c_gray, lc, .7)) - the row's one living
	// element and its take read as the same thing. The port had
	// substituted g.profit_color (his report 2026-09-06).
	// It FADES WITH THE BUY STAGE, DE's ualpha: the bar's interior text
	// is on the layer the buy panel replaces, so the take is gone by the
	// time the buttons have arrived - which is what frees the row for
	// the rate readout to slide into.
	if (_p > 0 && _bp < .98) {
		draw_set_halign(fa_right);
		draw_set_color(merge_colour(c_gray, _lc, .7));
		draw_set_alpha(.85 * _oa * (1 - _bp));
		draw_text_transformed(_px + _pw - 2, _py - .5,
			crunch_arb(do_scale(_d.gpc, _p)), .8, .8, 0);
	}
	draw_set_font(fnt);
	draw_set_halign(fa_left);

	// ---- THE RATE, right-aligned at the row's far edge past the bar
	// (DE's obj_dial): "+gpc" per cycle or "+gps" per second, by the
	// view button's g.display_gps.
	// IT DOES NOT LEAVE AT THE BUY STAGE (his report 2026-09-06 - the
	// port faded it out). DE draws it twice at the SAME anchor,
	// _x + width - endcap, and cross-fades the two as the row narrows;
	// since that anchor rides `width`, the number simply travels left
	// with the shrinking row. Ours is one draw at the same moving
	// anchor, which is the same picture with no seam.
	var _rv = (g.display_gps == 1) ? _d.gps : _d.gpc;
	var _rt = "+" + crunch_arb(_rv);
	// THE SEAT OPENS UP AS THE ROW NARROWS. At the list stage the
	// readout shares the row with the accruing take, so it fits the
	// space PAST the bar; at the buy stage that take has faded and
	// the whole bar interior is free, which is what keeps the number
	// readable at 93px instead of squeezing it to nothing.
	var _from = lerp(_px + _pw + 2, _px, _bp);
	var _seat = (_x + _bw - _ec) - _from;
	var _sc = clamp(_seat / max(1, string_width(_rt)), .5, 1);
	draw_set_halign(fa_right);
	draw_set_color(g.profit_color);
	draw_set_alpha(.95 * _oa);
	draw_text_transformed(_x + _bw - _ec, _y + 2 + lerp(5, 0, _sc), _rt, _sc, _sc, 0);
	draw_set_halign(fa_left);

	// ---- STAGE 2: DE's buy button, right of the narrowed bar ----
	if (_bp > .02) {
		// the price of the LIVE MODE's buy, from the quote cache (a
		// row without a quote yet prices itself once)
		var _q = (_i < array_length(quote)) ? quote[_i] : undefined;
		if (is_undefined(_q)) _q = dial_buy_ext(_i, g.buy_lv, false);
		var _cost = _q.cost;
		var _can  = _q.ok;
		var _bx   = _x + _bw + 2;
		// DE'S COLOUR LAW (obj_button_dialbuy's Step, his report
		// 2026-09-06 - the port had the wrong three):
		//   affordable            c_sblue   (DE's theme_afford)
		//   ...and the buy REACHES the next milestone rung   c_sgreen
		//   cannot afford         c_hred    (DE's theme_cantafford;
		//                                    the port used c_gray)
		// DE's third case, c_gold, is skipped on purpose: it keys off
		// the per-dial level SOFTCAP (its `hard`), a mechanic RX does
		// not have. It returns with the softcap, not before.
		var _nx   = milestone_next(_d.level);
		var _tint = c_sblue;
		if (_can && _nx > 0 && _q.to >= _nx) _tint = c_sgreen;
		if (!_can) _tint = c_hred;
		// DE's chrome sits FAR back toward black - merge_colour(blend,
		// c_black, lerp(.8, 0, glow)), and glow is 0 except for the
		// half-second after a buy. The port lit affordable rows at .5,
		// which is why they never matched.
		var _bc2  = merge_colour(_tint, c_black, .8);
		draw_sprite_ext(spr_button_bevel, 0, _bx, _y - 2, 1, 1, 0, _bc2, _bp * _oa);
		draw_set_halign(fa_center);
		// DE prices in MONEY's colour, greying out what you cannot buy -
		// the chrome carries the state, the text carries the currency
		draw_set_color(_can ? g.profit_color : c_gray);
		draw_set_alpha((_can ? .95 : .6) * _bp * _oa);
		draw_text_transformed(_bx + sprite_get_width(spr_button_bevel) * .5,
			_y + 1, crunch_arb(_cost), .8, .8, 0);
		draw_set_halign(fa_left);
	}
}

// ---- DE's two top-right buttons ----
// the VIEW button (with the list): face + the mode glyph, "view" above
if (_dp > .02) {
	var _vc = (g.display_gps == 1) ? c_steelblue : c_rarity_common;
	var _vf = (g.display_gps == 1) ? 3 : 2;
	draw_sprite_ext(spr_hud_toggle_ps, vb_down ? 1 : 0, vb_cx, vb_y, 1, 1, 0, _vc, _oa);
	draw_sprite_ext(spr_hud_toggle_ps, _vf, vb_cx, vb_y + (vb_down ? 1 : 0), 1, 1, 0, _vc, .8 * _oa);
	draw_set_halign(fa_center);
	draw_set_color(_vc);
	draw_set_alpha(_oa);
	draw_text_transformed(vb_cx + vb_w * .5, vb_y - 4, "view", .6, .5, 0);
}
// the BUY BULK button (with the buy layer): DE's face tinted by the
// mode, the mode glyph on top, "buy bulk" above - obj_ui_buylv's draw
if (_bp > .02 && __mode_gate()) {
	var _mc = __mode_color();
	draw_sprite_ext(spr_buylv, bb_down ? 1 : 0, bb_cx, bb_y, 1, 1, 0, _mc, _bp * _oa);
	draw_sprite_ext(spr_buylv, __mode_frame(), bb_cx, bb_y + (bb_down ? 1 : 0), 1, 1, 0,
		merge_colour(_mc, c_white, .5), _bp * _oa);
	draw_set_halign(fa_center);
	draw_set_color(_mc);
	draw_set_alpha(_bp * _oa);
	draw_text_transformed(bb_cx + bb_w * .5, bb_y - 4, "buy bulk", .6, .5, 0);
}
draw_set_halign(fa_left);

// the fleet's two headline numbers, under the column
draw_set_halign(fa_center);
draw_set_color(g.profit_color);
draw_set_alpha(.85 * _oa);
draw_text(_ax + row_w * .5, row_y1 + row_p, crunch_arb(g.all_gps) + "/sec");
draw_set_color(sett_ink);
draw_set_alpha(.55 * _oa);
draw_text(_ax + row_w * .5, row_y1 + row_p + 10,
	"per tap " + crunch_arb(g.click_gps));

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
