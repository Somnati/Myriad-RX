/// the panel's face. Draw-only; the Step's hits share this geometry.
/// Every part rides the open ease through __part(i) - the backdrop
/// lands first, the strip slides in from under the header, then the
/// bank, the speeds, the burns, the upgrades and the explainer deal
/// down in order and fade in as they seat (the settings screen's
/// recipe; ui_anim_in / ui_fade_set).

var _tb = g.timebank;
var _spending = (_tb.spd > 1 && _tb.bank > 0);

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---- the ground: the room shows through, blurred (ui_blur_tick) ----
// (no ground of its own: obj_menu2_bck paints the plate + gradients UNDER the blur - his "menu blur" ask)

// ---- the title strip - slides down from under the header ----
var _sp = ui_anim_in(oa, 1);
if (_sp > .001) {
	var _so = -(1 - _sp) * UI_IN_SLIDE;
	if (_so != 0) matrix_set(matrix_world, matrix_build(0, _so, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_sp);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, 16, 0, c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, hh + 15, room_width, 1, 0, sett_ink, .25);
	draw_set_color(c_feat_timebank);
	draw_set_alpha(.95);
	draw_text(6, hh + 5, "time bank");
	// (no back button - the burger is the X, his call)
	__part_end();
}

// ---- the bank, big and central ----
if (__part(2) > 0) {
	draw_set_halign(fa_center);
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(cx, bank_y - 16, "banked time");
	draw_set_font(fnt_large_outline);
	draw_set_color(_spending ? c_gold : c_white);
	draw_set_alpha(.95);
	draw_text(cx, bank_y, (_tb.bank >= 1) ? crunch_time_long(_tb.bank * 60) : "empty");
	draw_set_font(fnt);

	var _cap = timebank_cap();
	draw_set_color(rgb(120, 130, 150));
	draw_set_alpha(.6);
	draw_text(cx, bank_y + 18, "+"
		+ string(min(g.tb_rate + _tb.rate_lv * g.tb_rate_step, g.tb_rate_cap, 55))
		+ "m banked per hour away   -   cap " + crunch_time_long(_cap * 60));

	// the fill toward the cap
	var _bw = 180;
	var _bx = cx - _bw * .5;
	var _by = bank_y + 30;
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by, _bw, 5, 0, c_black, .8);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by,
		_bw * clamp(_tb.bank / max(1, _cap), 0, 1), 5, 0,
		_spending ? c_gold : c_sblue, .85);
	draw_px_rect(_bx, _by, _bw, 5, c_sblue, .35);
	draw_set_halign(fa_left);
	__part_end();
}

// ---- the speed row ----
if (__part(3) > 0) {
	draw_set_halign(fa_center);
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	// EVERY SPEED IS WORTH THE SAME TOTAL - x10 does not spend the bank
	// better than x2, it spends it faster (a banked second is one extra
	// simulated second whatever multiplier burns it; see timebank_twin's
	// invariant 2). Saying so stops the row reading as a power choice.
	draw_text(cx, spd_y - 12, "active speed - faster spends sooner, not further");
	draw_set_halign(fa_left);
	for (var _k = 0; _k < NSPD; _k++) {
		var _px = spd_x0 + _k * (spd_w + spd_gap);
		var _on = (_tb.spd == spds[_k]);
		// x1 is "off" on the face, because that is what it is - the row
		// reads as a switch with four settings rather than five speeds
		draw_ui_button(_px, spd_y, spd_w, 16,
			(spds[_k] == 1) ? "off" : ("x" + string(spds[_k])),
			_on ? c_gold : rgb(170, 190, 230), true, _on);
	}
	if (_spending) {
		draw_set_halign(fa_center);
		draw_set_color(c_gold);
		draw_set_alpha(.6 + .25 * dsin(current_time * .35));
		draw_text(cx, spd_y + 19, "spending " + string(_tb.spd - 1)
			+ "s of bank per second   -   "
			+ crunch_time_long((_tb.bank / (_tb.spd - 1)) * 60) + " left at this speed");
		draw_set_halign(fa_left);
	}
	__part_end();
}

// ---- THE BURN ROW: spend a lump at once (his ask) ----
if (__part(4) > 0) {
	draw_set_halign(fa_center);
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(cx, burn_y - 12, "or spend it all at once - runs as if you had been away");
	draw_set_halign(fa_left);
	for (var _k = 0; _k < NBURN; _k++) {
		var _bx2 = burn_x0 + _k * (burn_w + burn_gap);
		var _aff = (_tb.bank >= burns[_k]);
		draw_ui_button(_bx2, burn_y, burn_w, 16, burn_lbl[_k],
			_aff ? c_sgreen : c_gray, _aff, _aff);
	}
	if (burn_hp > 0 && burn_msg != "") {
		draw_set_halign(fa_center);
		draw_set_color(g.profit_color);
		draw_set_alpha(.8 * min(1, burn_hp / 60));
		draw_text(cx, burn_y + 19, burn_msg);
		draw_set_halign(fa_left);
	}
	__part_end();
}

// ---- the two upgrades, cost inside (the house buy-button language) ----
if (__part(5) > 0) {
	for (var _r = 0; _r < 2; _r++) {
		var _ry = upg_y + _r * upg_h;
		var _q  = (_r == 0) ? q_cap : q_rate;
		var _en = _q.ok && !_q.maxed;
		draw_sprite_ext(spr_pixel_1x1, 0, upg_x, _ry, upg_w, upg_h - 6, 0, c_black, .45);
		draw_px_rect(upg_x, _ry, upg_w, upg_h - 6, c_gold, .25);
		draw_set_color(c_white);
		draw_set_alpha(.9);
		if (_r == 0) {
			draw_text(upg_x + 6, _ry + 5,
				"capacity " + crunch_time_long(timebank_cap() * 60));
			draw_set_color(c_sgreen);
			draw_set_alpha(.7);
			// what the NEXT level would give, so the price has something
			// to be weighed against
			draw_text(upg_x + 108, _ry + 5, "+" + string(g.tb_cap_step) + "m");
			// WHICH ONE IS BINDING: how long an absence this capacity can
			// hold at the rate you have - the number that says whether
			// the next capacity level would actually keep anything.
			draw_set_color(_tb.last_full ? c_horange : rgb(120, 130, 150));
			draw_set_alpha(.65);
			draw_text(upg_x + 148, _ry + 5, "holds "
				+ string_format(timebank_cap() / 60 / max(1, timebank_rate() * 60), 1, 1)
				+ "h away" + (_tb.last_full ? "  (last one overflowed)" : ""));
		} else {
			draw_text(upg_x + 6, _ry + 5, "rate "
				+ string(min(g.tb_rate + _tb.rate_lv * g.tb_rate_step,
					g.tb_rate_cap, 55)) + "m/hr");
			draw_set_color(c_sgreen);
			draw_set_alpha(_q.maxed ? 0 : .7);
			draw_text(upg_x + 108, _ry + 5, "+" + string(g.tb_rate_step) + "m");
			draw_set_color(rgb(120, 130, 150));
			draw_set_alpha(.65);
			draw_text(upg_x + 148, _ry + 5,
				_q.maxed ? "at the ceiling" : "fills the bank faster");
		}
		var _bbx = upg_x + upg_w - 62;
		draw_sprite_ext(spr_pixel_1x1, 0, _bbx, _ry + 1, 60, 14, 0,
			_en ? merge_colour(c_black, c_sgreen, .18) : c_black, .85);
		draw_px_rect(_bbx, _ry + 1, 60, 14, _en ? c_sgreen : c_gray, _en ? .8 : .3);
		draw_set_halign(fa_center);
		// PAID IN BANKED TIME, so the price wears the bank's colour rather
		// than profit's gold - it is the one thing on this screen you spend
		draw_set_color(_q.maxed ? c_gray : c_sblue);
		draw_set_alpha(_en ? .95 : .45);
		draw_text(_bbx + 30, _ry + 4, (_q.txt != "") ? _q.txt : "-");
		draw_set_halign(fa_left);
	}
	__part_end();
}

// ---- the explainer ----
if (__part(6) > 0) {
	draw_set_halign(fa_center);
	draw_set_color(rgb(120, 130, 150));
	draw_set_alpha(.5);
	draw_text(cx, room_height - 32, "while away, production runs AND time banks on top");
	draw_text(cx, room_height - 22,
		"the upgrades are paid in banked time - spend it, or invest it");
	draw_set_halign(fa_left);
	__part_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
