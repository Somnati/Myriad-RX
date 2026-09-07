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
// THE BACKDROP IS THE DRAWER'S OWN WIDTH (his ask 2026-09-06), not the
// room's. In portrait the column opens to x 2, so the strip IS the
// screen and it behaves exactly as before; in landscape it stops with
// the drawer at the right edge and leaves the room beside it alone.
// It rides `face`, so it widens WITH the pull rather than appearing.
if (_dp > 0) {
	// EVEN MARGINS (his report 2026-09-06 - it stopped dead on the bars'
	// left edge). The gap the bars leave on the RIGHT, measured at full
	// open, is mirrored on the left: at row_x the content ends at
	// row_x + 140 and the room ends at room_width, so that difference is
	// the margin on both sides. Measured off row_x rather than the live
	// face so it is a fixed inset that SLIDES with the drawer instead of
	// changing shape during the pull.
	var _mg  = max(0, room_width - (row_x + row_w));
	var _bx0 = floor(face - _mg);
	// the PIXELATED copy of whatever the strip is covering, then a dim
	// over it. The dim stays light (.45) because the pixelation already
	// separates the drawer from the room; dimming hard on top of it just
	// reads as a black panel again.
	draw_pixel_region(_bx0, 0, room_width - _bx0, room_height, _dp);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx0, 0, room_width - _bx0,
		room_height, 0, c_black, .45 * _dp);
}

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
	// (the gold edge hairline that ran beside the dot column is gone -
	// his report 2026-09-06: it read as a stray yellow line, and the
	// dots mark the drawer's edge perfectly well by themselves)
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
	// DE nudges the "lv N" pair 4px LEFT as the buy layer opens
	// (obj_dial: _x + 15 - (4 * obj_dragautoupgrades.alpha)), making the
	// room the "+N" needs beside it
	var _lvx = _x + 15 - 4 * _bp;
	draw_text(_lvx, _y + 2, "lv");
	draw_set_color(_lc);
	// the level SHRINKS to fit the 15px between "lv" and the bar (DE's
	// sc), so a three-digit level never runs under the bar
	var _lt = string(_d.level);
	var _ls = min(1, 14 / max(1, string_width(_lt)));
	draw_text_transformed(_lvx + 9, _y + 2 + lerp(3, 0, _ls), _lt, _ls, _ls, 0);
	// HOW MANY LEVELS THE LIVE MODE BUYS. His report 2026-09-06: ours
	// was green and in the wrong place. DE seats it AFTER the level text
	// rather than under "lv" - x + 15 - 4a + string_width("lv" + level),
	// six pixels below the level's own line - and colours it
	// merge_colour(c_gray, colour_set_comp(lc), .17): almost entirely
	// grey, carrying just a breath of the dial's OPPOSITE hue. It reads
	// as a quiet annotation on that dial rather than as a second signal.
	// Drawn in the outline font at full size, DE's mtext.
	// The affordable / not distinction is deliberately NOT here: DE puts
	// that on the button's chrome, which is the thing you press.
	if (_bp > .02 && _i < array_length(quote) && !is_undefined(quote[_i]))
	if (quote[_i].n > 0) {
		draw_set_font(fnt_outline);
		draw_set_color(merge_colour(c_gray, color_set_comp(_lc), .17));
		draw_set_alpha(_bp * _oa);
		draw_text(_lvx + string_width("lv" + _lt),
			_y + 2 + lerp(3, 0, _ls) + 6, "+" + string(quote[_i].n));
		draw_set_font(fnt);
	}

	// ---- the progress bar: DE's 70 wide at the list stage (the rate
	// readout owns the seat past it), narrowing with the bar for buy ----
	var _pw = min(sprite_get_width(spr_progressbar), _bw - 39 - _ec - 1);
	var _ph = sprite_get_height(spr_progressbar);
	var _sw = sprite_get_width(spr_progressbar);
	var _px = _x + 39, _py = _y + 3;
	var _xs = _pw / _sw;                           // scale to the live width
	// THE BAR ITSELF LEAVES AT THE BUY STAGE (his report 2026-09-06).
	// DE hangs the track and the fill on ualpha - the same layer as the
	// bar's interior text - so the buy buttons arrive onto an empty row.
	// _ba is that layer's alpha; only the completion glow below escapes
	// it, which is why a paying dial still blinks while you shop.
	var _ba = _oa * (1 - _bp);
	draw_sprite_general(spr_progressbar, 0, 0, 0, _sw, _ph, _px, _py,
		_xs, 1, 0, _bc, _nc, _nc, _bc, _ba);
	if (_p > 0) {
		draw_sprite_part_ext(spr_progressbar, 0, 0, 0, _p * (_sw - 1), _ph,
			_px, _py, _xs, 1, _lc, _ba);
		draw_sprite_ext(spr_progressbar, 1, _px + _p * (_pw - 1.1), _py,
			1, 1, 0, _lc, _ba);
		draw_sprite_ext(spr_progressbar, 2, _px + _p * (_pw - 1) - _sw + 2, _py,
			1, 1, 0, merge_colour(_lc, c_white, lerp(0, .8, _p * _p)),
			lerp(0, .8, _ba * _p) * (_p * _p));
	}
	// DE'S COMPLETION GLOW: spr_progressbar frame 3, in the DIAL's
	// colour, drawn OUTSIDE the fade (obj_dial's bubbleglow, which the
	// port never drew at all). It is the one thing left on the row once
	// the buy layer owns it.
	if (_d.glow > 0)
		draw_sprite_ext(spr_progressbar, 3, _px, _py, _xs, 1, 0, _lc,
			_d.glow * _oa);
	// the WHITE payout flash is DE's other glow, and DE gates it on the
	// buy layer being shut - two flashes at once would just be a blur
	if (_d.glow > 0 && _bp < .02)
		draw_sprite_general(spr_progressbar, 0, 0, 0, _sw, _ph, _px, _py,
			_xs, 1, 0, c_white, c_white, c_white, c_white, _d.glow * _oa);

	// ---- THE COUNTDOWN, centred on the bar (his ask). While the dial
	// is winding up it reads "..." exactly as DE's does - the dial has
	// started, it just has nothing to show yet.
	draw_set_font(fnt_outline);
	draw_set_halign(fa_center);
	// on _ba with the bar it sits on: DE hangs the countdown, the take
	// and the bar itself on one alpha, so they leave together and the
	// row does not end up with a timer floating over nothing
	draw_set_color(merge_colour(c_white, _lc, .5));
	draw_set_alpha(.95 * _ba);
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
		draw_set_alpha(.85 * _ba);
		draw_text_transformed(_px + _pw - 2, _py - .5,
			crunch_arb(do_scale(_d.gpc, _p)), .8, .8, 0);
	}
	draw_set_font(fnt);
	draw_set_halign(fa_left);

	// ---- THE RATE, right-aligned at the row's far edge past the bar
	// (DE's obj_dial): "+gpc" per cycle, "+gps" per second, or this
	// dial's SHARE OF THE FLEET as a percentage, by g.display_gps.
	// IT DOES NOT LEAVE AT THE BUY STAGE (his report 2026-09-06 - the
	// port faded it out). DE draws it twice at the SAME anchor,
	// _x + width - endcap, and cross-fades the two as the row narrows;
	// since that anchor rides `width`, the number simply travels left
	// with the shrinking row. Ours is one draw at the same moving
	// anchor, which is the same picture with no seam.
	var _rt = "";
	var _rc = c_gold;
	if (g.display_gps == 2) {
		// MODE 2, DE's "per centage" (obj_dial: v_track = do_div(gps,
		// all_gps) + 2, the +2 being x100): what share of the fleet's
		// output this dial is carrying. Computed in LOG SPACE, not
		// through do_div - a share is by definition <= 1 and the arb
		// library does not do sub-1 values; dividing into one would
		// pack malformed and hang a normalize loop.
		// DE hides it until the fleet clears 10/s, when the split
		// starts meaning something.
		if (g.all_gps >= arb(10) && _d.gps >= arb(1)) {
			var _lg = arb_log10(_d.gps) - arb_log10(g.all_gps) + 2;
			var _pc = power(10, _lg);          // a plain percent, 0..100
			if (_lg >= 0) _rt = "+" + crunch_arb(log_to_arb(_lg)) + "%";
			else          _rt = "-E" + string(round(abs(_lg))); // DE's tail
			// DE grades the share by rarity - the thresholds are its
			// packed-arb ones (0.8 / 1.20 / 1.5 / 1.65 / 1.75 / 1.9 /
			// 1.95) read back as the percentages they stand for
			_rc = c_rarity_common;
			if (_pc >= 8)  _rc = c_rarity_uncommon;
			if (_pc > 20)  _rc = c_rarity_rare;
			if (_pc > 50)  _rc = c_rarity_epic;
			if (_pc > 65)  _rc = c_rarity_legendary;
			if (_pc > 75)  _rc = c_rarity_elite;
			if (_pc > 90)  _rc = c_rarity_divine;
			if (_pc > 95)  _rc = c_rarity_ultimate;
		}
	}
	else {
		var _rv = (g.display_gps == 1) ? _d.gps : _d.gpc;
		_rt = "+" + crunch_arb(_rv);
	}
	if (_rt != "") {
		// THE SEAT OPENS UP AS THE ROW NARROWS. At the list stage the
		// readout shares the row with the accruing take, so it fits the
		// space PAST the bar; at the buy stage that take has faded and
		// the whole bar interior is free, which is what keeps the number
		// readable at 93px instead of squeezing it to nothing.
		var _from = lerp(_px + _pw + 2, _px, _bp);
		var _seat = (_x + _bw - _ec) - _from;
		var _sc = clamp(_seat / max(1, string_width(_rt)), .5, 1);
		draw_set_halign(fa_right);
		// GOLD, his call 2026-09-06 - a deliberate step AWAY from DE, which
		// draws the rate in g.profit_color. The percentage view overrides it
		// with DE's rarity grade, which is the whole point of that mode.
		draw_set_color(_rc);
		draw_set_alpha(.95 * _oa);
		draw_text_transformed(_x + _bw - _ec, _y + 2 + lerp(5, 0, _sc), _rt, _sc, _sc, 0);
		draw_set_halign(fa_left);
	}

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
	// THE MODE AS TEXT (his ask 2026-09-06): the button said "view" and
	// wore a glyph frame; it now reads the abbreviation itself. Text
	// rather than a sprite frame is also what let the third mode land
	// without drawing a new one - spr_hud_toggle_ps only has frames for
	// two, and glyph 2/3 are no longer used.
	var _vc = c_rarity_common;
	if (g.display_gps == 1) _vc = c_steelblue;
	if (g.display_gps == 2) _vc = c_gold;
	var _vt = "p/c";
	if (g.display_gps == 1) _vt = "p/s";
	if (g.display_gps == 2) _vt = "%";
	draw_sprite_ext(spr_hud_toggle_ps, vb_down ? 1 : 0, vb_cx, vb_y, 1, 1, 0, _vc, _oa);
	draw_set_halign(fa_center);
	draw_set_color(_vc);
	draw_set_alpha(.9 * _oa);
	// shrunk to fit the 18px face with a pixel of air each side
	var _vs = min(1, 16 / max(1, string_width(_vt)));
	draw_text_transformed(vb_cx + vb_w * .5,
		vb_y + (vb_h - 7 * _vs) * .5 + (vb_down ? 1 : 0), _vt, _vs, _vs, 0);
	draw_set_halign(fa_left);
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
