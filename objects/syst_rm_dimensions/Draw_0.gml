/// the cascade bench: strip (dark matter + its live rate), the controls row
/// (buy qty, the candidate resin multiplier, reset), tickspeed row,
/// then the eight tiers - count in scientific dress, the per-10
/// milestone, the rate flowing IN from the tier above, and the buy
/// column. locked tiers sleep as dormant rows until their feeder has
/// been bought once. menu (-520) covers everything (house rule).

draw_set_font(fnt);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0,
	c_hsv(169, 186, 5), 1);

var _d = g.dims;
var _ltk = _d.tick_bought * log10(1.15); // tickspeed factor, log10

// per-second rates in log10 (mirrors dims_tick's setup)
var _a = array_create(8);
for (var _i = 0; _i < 8; _i++)
	_a[_i] = (_d.bought[_i] div 10) * log10(2) + _ltk;

// ---- the rows: tickspeed first, then the tiers ----
for (var _r = 0; _r < 9; _r++) {
	var _ry = __row_y(_r);

	if (_r == 0) {
		// tickspeed: the global compounding knob
		draw_set_alpha(1);
		draw_sprite_ext(spr_pixel_1x1, 0, 3, _ry, room_width - 6, row_h - 2, 0,
			c_hsv(168, 140, 17), 1);
		draw_sprite_ext(spr_pixel_1x1, 0, 3, _ry, 2, row_h - 2, 0, c_gold, .9);
		draw_set_halign(fa_left);
		draw_set_color(c_gold);
		draw_set_alpha(.95);
		draw_text(10, _ry + 6, "tickspeed");
		draw_set_color(merge_colour(c_gold, c_white, .4));
		// 3 decimals while it's human-sized, scientific once it's not
		draw_text(80, _ry + 6, "x" + ((_ltk < 6)
			? string(round(power(10, _ltk) * 1000) / 1000) : __fmt(_ltk)));
		draw_set_color(sett_ink);
		draw_set_alpha(.55);
		draw_text_transformed(150, _ry + 7,
			"(x1.15 to every tier, each buy)", .85, .85, 0);
		draw_ui_button(buy_x, _ry + 2, buy_w, row_h - 5,
			__fmt(dims_cost("tick")), c_gold,
			!_d.inf && _d.dark >= dims_cost("tick"), true);
		continue;
	}

	var _i = _r - 1;
	var _col = tier_col[_i];
	var _locked = (_i > 0 && _d.bought[_i - 1] <= 0);

	if (_locked) {
		draw_row_collapsed(3, _ry, room_width - 6, row_h - 2,
			tier_name[_i] + " dimension",
			"buy a " + tier_name[_i - 1] + " first", _col);
		continue;
	}

	// panel + identity band
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, 3, _ry, room_width - 6, row_h - 2, 0,
		c_hsv(168, 140, 15), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 3, _ry, 2, row_h - 2, 0, _col, .9);

	// name + the per-10 milestone
	draw_set_halign(fa_left);
	draw_set_color(_col);
	draw_set_alpha(.95);
	draw_text(10, _ry + 6, tier_name[_i]);
	draw_set_color(merge_colour(_col, c_white, .5));
	draw_set_alpha(.8);
	draw_text_transformed(36, _ry + 7,
		"x" + __fmt((_d.bought[_i] div 10) * log10(2))
		+ "  (" + string(_d.bought[_i] mod 10) + "/10)", .85, .85, 0);

	// the count, the row's big number - and RIGHT BESIDE it, how much
	// of this dimension you're gaining per second from the tier above
	// (his ask: AD's readout, count and its growth in one glance)
	var _cnt = __fmt(_d.count[_i]);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(130, _ry + 6, _cnt);
	var _tx9 = 130 + string_width(_cnt) + 6; // the readouts flow rightward
	// counts are LOG10: multiply = add logs, divide = subtract them;
	// "exists" = above the lz zero sentinel
	if (_i < 7 && _d.count[_i + 1] > _d.lz * .5) {
		var _gn9 = _d.count[_i + 1] + _a[_i + 1]; // inflow/s, log10
		var _gt9 = "(+" + __fmt(_gn9) + "/s)";
		draw_set_color(merge_colour(tier_col[_i + 1], c_white, .3));
		draw_set_alpha(.8);
		draw_text_transformed(_tx9, _ry + 7, _gt9, .85, .85, 0);
		_tx9 += string_width(_gt9) * .85 + 5;
		// AD's percentage readout (his ask): the inflow as a live
		// fraction of the count you're looking at - how fast THIS row
		// is compounding, regardless of magnitude
		if (_d.count[_i] > _d.lz * .5) {
			var _pt9 = "(+" + __fmt(_gn9 - _d.count[_i] + 2) + "%/s)";
			draw_set_color(c_sgreen);
			draw_set_alpha(.7);
			draw_text_transformed(_tx9, _ry + 7, _pt9, .85, .85, 0);
			_tx9 += string_width(_pt9) * .85 + 5;
		}
	}
	// the 1st's own output: dark matter (flows after the growth readouts now)
	if (_i == 0 && _d.count[0] > _d.lz * .5) {
		draw_set_color(c_gold);
		draw_set_alpha(.75);
		draw_text_transformed(_tx9, _ry + 7,
			"-> dark matter +" + __fmt(_d.count[0] + _a[0]) + "/s", .85, .85, 0);
	}

	draw_ui_button(buy_x, _ry + 2, buy_w, row_h - 5,
		__fmt(dims_cost(_i)), _col, !_d.inf && _d.dark >= dims_cost(_i), true);
}

// footnote
draw_set_halign(fa_left);
draw_set_color(sett_ink);
draw_set_alpha(.45);
draw_text(6, room_height - 12, "debug bench - offline is EXACT here "
	+ "(closed form, wall clock): leave for an hour and check the math.");

// ---- strip ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, rgb(170, 190, 230), .25);
draw_set_color(sett_ink);
draw_set_alpha(.85);
draw_text(6, bby + 4, "dimensions");
draw_set_color(c_gold);
draw_set_alpha(.95);
draw_text(80, bby + 4, __fmt(_d.dark) + " dark matter");
// the run clock: it's a RACE to e308 now - live while running, plus
// the best time once one exists
var _rt = _d.inf ? _d.run
	: (date_current_datetime() * 86400 - _d.start);
draw_set_color(sett_ink);
draw_set_alpha(.6);
draw_text_transformed(230, bby + 5, "run " + __hms(_rt)
	+ ((_d.best >= 0) ? "   best " + __hms(_d.best) : ""), .85, .85, 0);
draw_ui_button(room_width - 62, bby + 1, 56, 13, "back",
	rgb(170, 190, 230), true, false);

// ---- the controls row ----
// buy-quantity dropdown (the house pillbox's chrome)
var _lbl = "buy x1";
if (buy_q == 10)    _lbl = "buy x10";
if (buy_q == 100)   _lbl = "buy x100";
if (buy_q == "max") _lbl = "buy max";
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, 6, bby + 20, 90, 14, 0, c_black, .8);
draw_px_rect(6, bby + 20, 90, 14, c_gold, .45);
draw_set_halign(fa_left);
draw_set_color(c_gold);
draw_set_alpha(.95);
draw_text(11, bby + 24, _lbl);
draw_set_color(sett_ink);
draw_set_alpha(.7);
draw_text(88, bby + 24, "v");

// the candidate multiplier: what the cascade WOULD feed resin - the
// wiring decision is his, later
draw_set_color(c_sgreen);
draw_set_alpha(.8);
draw_text_transformed(102, bby + 24, "candidate resin mult  x"
	+ string(round(__cand() * 1000) / 1000) + "  (1 + log10(dark matter)/10) - "
	+ "NOT wired", .85, .85, 0);

draw_ui_button(room_width - 66, bby + 20, 60, 14, "reset", c_hred, true, false);

// ---- the infinity banner: the wall IS the win (his call). the
// cascade froze at 1.8e308; the crunch button's geometry lives in
// Create so Step's hit test can never drift ----
if (_d.inf) {
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, inf_bx, inf_by, inf_bw, inf_bh, 0,
		c_black, .95);
	draw_px_rect(inf_bx, inf_by, inf_bw, inf_bh, c_gold, .9);
	draw_set_halign(fa_center);
	draw_set_color(c_gold);
	draw_set_alpha(.95);
	draw_text(inf_bx + inf_bw * .5, inf_by + 10, "reached infinity");
	draw_set_color(merge_colour(c_gold, c_white, .4));
	draw_set_alpha(.85);
	draw_text_transformed(inf_bx + inf_bw * .5, inf_by + 26,
		"1.80e308 dark matter in " + __hms(_d.run)
		+ ((_d.best >= 0 && _d.best < _d.run)
			? "  (best " + __hms(_d.best) + ")" : ""), .85, .85, 0);
	draw_ui_button(crunch_x, crunch_y, crunch_w, crunch_h,
		"big crunch", c_gold, true, true);
	draw_set_halign(fa_left);
}

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);

// the room's welcome-back line, fading (Step's catch-up tick fills it)
if (rep_t > 0 && report != undefined) {
	draw_set_halign(fa_center);
	draw_set_color(c_gold);
	draw_set_alpha(clamp(rep_t / 60, 0, 1) * .9);
	draw_text(room_width div 2, bby + 22,
		"while you were away (" + crunch_time_long(report.away * 60)
		+ "): " + report.t);
	draw_set_halign(fa_left);
	draw_set_alpha(1);
}
