/// the gift's one screen: fortnight board, today spotlight, collect
/// button, level footer, strip. Cards are the statistics panel
/// doctrine (opaque plate, light top / dark bottom 1px edges); rarity
/// colours come off the board rolls. Every part rides the open ease
/// through __part(i).

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _br = abs(dsin(current_time * .3)); // the shared breath
var _can = gift_can_claim();
var _pos = g.gift.pos;
var _spot = board[_pos];
var _srar = g.gift_cfg.rars[_spot.rar];
var _rw = gift_reward(_spot);
var _li = gift_level();

// ---- the ground: the room shows through, blurred (ui_blur_tick) ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, room_height, 0,
	c_black, .72 * ui_anim_in(oa, 0));

// ---- the title strip - slides down from under the header ----
var _sp = ui_anim_in(oa, 1);
if (_sp > .001) {
	var _so = -(1 - _sp) * UI_IN_SLIDE;
	if (_so != 0) matrix_set(matrix_world, matrix_build(0, _so, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_sp);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, sett_ink, .25);
	draw_set_color(c_pink);
	draw_set_alpha(.95);
	draw_text(6, bby + 5, "daily gift");
	// (no back button - the burger is the X)
	__part_end();
}

// ---- the fortnight board: 7 x 2 day cards ----
if (__part(2) > 0) {
	for (var _i = 0; _i < g.gift_cfg.days; _i++) {
		var _x = cal_x + (_i mod 7) * (card_w + gap_x);
		var _y = cal_y + (_i div 7) * (card_h + gap_y);
		var _sl = board[_i];
		var _rc = g.gift_cfg.rars[_sl.rar].col;
		var _done = (_i < _pos);
		var _today = (_i == _pos);

		// plate: collected cards go ashen, today's warms and breathes,
		// the future waits muted
		var _tint = _done ? .07 : (_today ? .26 + .08 * _br : .14);
		draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, card_w, card_h, 0,
			merge_colour(c_black, _rc, _tint), 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, card_w, 1, 0, c_white, .08);
		draw_sprite_ext(spr_pixel_1x1, 0, _x, _y + card_h - 1, card_w, 1, 0,
			c_black, .35);
		draw_px_rect(_x, _y, card_w, card_h, _rc,
			_done ? .12 : (_today ? .55 + .3 * _br : .3));

		// day number + the rarity's name; a tiny currency chip top-right
		// says what kind of drop waits there
		draw_set_halign(fa_left);
		draw_set_color(_done ? c_gray : sett_ink);
		draw_set_alpha(_done ? .4 : .85);
		draw_text(_x + 4, _y + 4, "day " + string(_i + 1));
		draw_set_color(_rc);
		draw_set_alpha(_done ? .3 : (_today ? 1 : .7));
		draw_text(_x + 4, _y + 14, g.gift_cfg.rars[_sl.rar].name);
		draw_sprite_ext(spr_pixel_1x1, 0, _x + card_w - 8, _y + 4, 4, 4, 0,
			(_sl.kind == 0) ? g.profit_color : c_lavender, _done ? .25 : .9);

		// collected: a drawn tick (the tech demo used its achievement
		// icon, which RX does not carry)
		if (_done) {
			draw_px_line(_x + card_w - 17, _y + 14, _x + card_w - 14, _y + 17, c_sgreen, .8);
			draw_px_line(_x + card_w - 14, _y + 17, _x + card_w - 9,  _y + 11, c_sgreen, .8);
		}

		// the just-punched card flushes with the reward colour
		if (_i == slot_flash && flash > 0)
			draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, card_w, card_h, 0,
				flash_col, flash * .45);
	}
	__part_end();
}

// ---- the today spotlight: the next slot blown up ----
if (__part(3) > 0) {
	// soft glow in the rarity colour behind the card (breathes while
	// the gift is still on the table)
	var _gs = 220 / max(1, sprite_get_width(spr_vis_glow_soft));
	draw_sprite_ext(spr_vis_glow_soft, 0, spot_x + spot_w div 2,
		spot_y + spot_h div 2, _gs, _gs * .6, 0, _srar.col,
		_can ? .22 + .1 * _br : .1);

	draw_sprite_ext(spr_pixel_1x1, 0, spot_x, spot_y, spot_w, spot_h, 0,
		merge_colour(c_black, _srar.col, _can ? .24 + .06 * _br : .12), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, spot_x, spot_y, spot_w, 1, 0, c_white, .1);
	draw_sprite_ext(spr_pixel_1x1, 0, spot_x, spot_y + spot_h - 1, spot_w, 1, 0,
		c_black, .4);
	draw_px_rect(spot_x, spot_y, spot_w, spot_h, _srar.col,
		_can ? .7 + .25 * _br : .35);

	// day title, doubled (integer scale - sprite font law)
	draw_set_halign(fa_center);
	draw_set_color(_can ? c_white : c_gray);
	draw_set_alpha(.95);
	draw_text_transformed(spot_x + spot_w div 2 + 1, spot_y + 8,
		"day " + string(_pos + 1), 2, 2, 0);

	// the rarity pill, centred
	var _rn = _srar.name;
	var _pw = string_width(_rn) + 10;
	var _px = spot_x + (spot_w - _pw) div 2;
	draw_sprite_ext(spr_pixel_1x1, 0, _px, spot_y + 30, _pw, 11, 0,
		merge_colour(c_black, _srar.col, .25), .9);
	draw_px_rect(_px, spot_y + 30, _pw, 11, _srar.col, .6);
	draw_set_color(merge_colour(_srar.col, c_white, .35));
	draw_set_alpha(.95);
	draw_text(spot_x + spot_w div 2 + 1, spot_y + 32, _rn);

	// the reward it pays (gift_reward - the same derivation the claim
	// pays out, what you see is what you get)
	draw_set_color(_rw.col);
	draw_set_alpha(_can ? 1 : .5);
	draw_text(spot_x + spot_w div 2 + 1, spot_y + 50, _rw.label);

	// already collected: rest state, the pill says so
	if (!_can) {
		var _cw = string_width("collected") + 9;
		draw_status_pill(spot_x + (spot_w - _cw) div 2, spot_y + 65,
			"collected", uist.positive);
	}

	// collect feedback: the plate flushes with the reward colour
	if (flash > 0)
		draw_sprite_ext(spr_pixel_1x1, 0, spot_x, spot_y, spot_w, spot_h, 0,
			flash_col, flash * .5);
	draw_set_halign(fa_left);
	__part_end();
}

// ---- the collect button (below the day) ----
if (__part(4) > 0) {
	draw_ui_button(btn_x, btn_y, btn_w, btn_h,
		_can ? "collect" : "collected", _can ? _srar.col : c_gray, _can, true);
	__part_end();
}

// ---- footer: gift level + progress + output, then the countdown ----
if (__part(5) > 0) {
	draw_set_halign(fa_left);
	draw_set_color(sett_ink);
	draw_set_alpha(.85);
	draw_text(cal_x, foot_y, "gift level " + string(_li.lv));

	// progress to the next level (claims into / claims needed)
	var _bx = cal_x + 86;
	var _bw = room_width - _bx - cal_x - 96;
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, foot_y + 1, _bw, 5, 0, c_black, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, foot_y + 1,
		_bw * clamp(_li.into / _li.need, 0, 1), 5, 0, c_gold, .9);
	draw_px_rect(_bx, foot_y + 1, _bw, 5, c_gold, .3);
	draw_set_halign(fa_right);
	draw_set_color(c_gold);
	draw_set_alpha(.8);
	draw_text(room_width - cal_x, foot_y,
		"output +" + string(round(_li.lv * g.gift_cfg.lvl_out * 100)) + "%");

	// the countdown: gifts turn with the real calendar (local midnight)
	draw_set_halign(fa_center);
	if (_can) {
		draw_set_color(c_seagreen);
		draw_set_alpha(.8 + .2 * _br);
		draw_text(room_width div 2, foot_y + 13, "today's gift is ready");
	} else {
		var _left = (1 - frac(date_current_datetime())) * 86400;
		draw_set_color(sett_ink);
		draw_set_alpha(.6);
		draw_text(room_width div 2, foot_y + 13,
			"next gift in " + crunch_time_long(_left * 60));
	}
	draw_set_halign(fa_left);
	__part_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
