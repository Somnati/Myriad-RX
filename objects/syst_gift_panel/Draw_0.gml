/// THE DAILY GIFT, the overhaul (his ask, 2026-09-12: "more polished,
/// cleaner and easier on the eyes"). Three things on one centre line -
/// the fortnight board, the today card, the footer line - every plate
/// a bevelled capsule (draw_capsule, the deck's shape) in its rarity
/// colour, no borders on borders. The strip carries the title alone.
/// Every part rides the open ease through __part(i). Both orientations
/// (see the Create's layout).

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _br  = abs(dsin(current_time * .3)); // the shared breath
var _can = gift_can_claim();
var _pos = g.gift.pos;
var _spot = board[_pos];
var _srar = g.gift_cfg.rars[_spot.rar];
var _rw  = gift_reward(_spot);
var _li  = gift_level();
var _dim = rgb(120, 130, 150);
var _ink = sett_ink;

// ---- the ground: the room shows through, blurred (ui_blur_tick) ----
// (no ground of its own: obj_menu2_bck paints the plate + gradients UNDER the blur - his "menu blur" ask)

// ---- the title strip - slides down from under the header ----
var _sp = ui_anim_in(oa, 1);
if (_sp > .001) {
	var _so = -(1 - _sp) * UI_IN_SLIDE;
	if (_so != 0) matrix_set(matrix_world, matrix_build(0, _so, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_sp);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, _ink, .25);
	draw_set_color(c_pink);
	draw_set_alpha(.95);
	draw_text(6, bby + 5, "daily gift");
	// the day's state, right, in the strip: ready, or the countdown
	draw_set_halign(fa_right);
	if (_can) {
		draw_set_color(c_seagreen);
		draw_set_alpha(.7 + .25 * _br);
		draw_text(room_width - 8, bby + 5, land ? "today's gift is ready" : "ready");
	} else {
		var _left = (1 - frac(date_current_datetime())) * 86400;
		draw_set_color(_dim);
		draw_set_alpha(.7);
		draw_text(room_width - 8, bby + 5, (land ? "next in " : "") + crunch_time_long(_left * 60));
	}
	draw_set_halign(fa_left);
	// (no back button - the burger is the X)
	__part_end();
}

// ---- the fortnight board: 7 x 2 day capsules ----
// collected days go ashen with a tick, today's is lit and breathes,
// the days ahead wait muted in their colour - the eye finds today
// without a legend
if (__part(2) > 0) {
	for (var _i = 0; _i < g.gift_cfg.days; _i++) {
		var _x = cal_x + (_i mod 7) * (card_w + gap_x);
		var _y = cal_y + (_i div 7) * (card_h + gap_y);
		var _sl = board[_i];
		var _rc = g.gift_cfg.rars[_sl.rar].col;
		var _done  = (_i < _pos);
		var _today = (_i == _pos);

		// the capsule: the rarity colour at the left fading to black
		var _t1 = _done ? .9 : (_today ? .5 - .1 * _br : .74);
		draw_capsule(_x, _y, card_w, card_h,
			merge_colour(_rc, c_black, _t1), merge_colour(_rc, c_black, .95), 1);
		if (_today) {
			// today's rim, breathing
			draw_capsule(_x, _y, card_w, card_h, c_white, c_white, .05 + .05 * _br);
			draw_sprite_ext(spr_pixel_1x1, 0, _x + 3, _y, card_w - 6, 1, 0, _rc, .5 + .4 * _br);
			draw_sprite_ext(spr_pixel_1x1, 0, _x + 3, _y + card_h - 1, card_w - 6, 1, 0, _rc, .5 + .4 * _br);
		}

		// the day number; landscape adds a rarity mark - one pip per
		// rung - and the reward-kind dot; portrait has room for the
		// number alone
		draw_set_halign(land ? fa_left : fa_center);
		draw_set_color(_done ? c_gray : (_today ? c_white : _ink));
		draw_set_alpha(_done ? .35 : (_today ? .95 : .8));
		if (land) draw_text(_x + 6, _y + 4, "day " + string(_i + 1));
		else      draw_text(_x + card_w / 2 + 1, _y + 3, string(_i + 1));
		if (land) {
			for (var _p = 0; _p <= _sl.rar; _p++)
				draw_sprite_ext(spr_pixel_1x1, 0, _x + 6 + _p * 4, _y + card_h - 7, 3, 3, 0,
					_rc, _done ? .3 : (_today ? .95 : .7));
			draw_sprite_ext(spr_pixel_1x1, 0, _x + card_w - 9, _y + 5, 3, 3, 0,
				(_sl.kind == 0) ? g.profit_color : c_lavender, _done ? .25 : .85);
		}

		// collected: a drawn tick
		if (_done) {
			var _tx = land ? (_x + card_w - 16) : (_x + card_w / 2 - 3);
			var _ty = land ? (_y + card_h - 11) : (_y + card_h - 6);
			draw_px_line(_tx,     _ty + 2, _tx + 2, _ty + 4, c_sgreen, .7);
			draw_px_line(_tx + 2, _ty + 4, _tx + 6, _ty,     c_sgreen, .7);
		}

		// the just-punched card flushes with the reward colour
		if (_i == slot_flash && flash > 0)
			draw_capsule(_x, _y, card_w, card_h, flash_col, flash_col, flash * .45);
	}
	draw_set_halign(fa_left);
	__part_end();
}

// ---- the today card: the next slot, blown up, with the action in it ----
if (__part(3) > 0) {
	// a soft glow in the rarity colour behind the card, breathing while
	// the gift is still on the table
	var _gs = (spot_w * 1.5) / max(1, sprite_get_width(spr_vis_glow_soft));
	draw_sprite_ext(spr_vis_glow_soft, 0, spot_x + spot_w div 2,
		spot_y + spot_h div 2, _gs, _gs * .6, 0, _srar.col,
		_can ? .2 + .1 * _br : .08);

	draw_capsule(spot_x, spot_y, spot_w, spot_h,
		merge_colour(_srar.col, c_black, _can ? .62 - .06 * _br : .82),
		merge_colour(_srar.col, c_black, .93), 1);
	// the rim, top and bottom, lit while it is ready
	draw_sprite_ext(spr_pixel_1x1, 0, spot_x + 3, spot_y, spot_w - 6, 1, 0, _srar.col, _can ? .6 + .3 * _br : .25);
	draw_sprite_ext(spr_pixel_1x1, 0, spot_x + 3, spot_y + spot_h - 1, spot_w - 6, 1, 0, _srar.col, _can ? .6 + .3 * _br : .25);

	var _mid = spot_x + spot_w div 2 + 1;
	// the day, doubled (integer scale - sprite font law)
	draw_set_halign(fa_center);
	draw_set_color(_can ? c_white : c_gray);
	draw_set_alpha(.95);
	draw_text_transformed(_mid, spot_y + 8, "day " + string(_pos + 1), 2, 2, 0);

	// the rarity, in its colour, under a hairline
	draw_sprite_ext(spr_pixel_1x1, 0, spot_x + 16, spot_y + 27, spot_w - 32, 1, 0, _srar.col, .3);
	draw_set_color(merge_colour(_srar.col, c_white, .25));
	draw_set_alpha(_can ? .95 : .6);
	draw_text(_mid, spot_y + 32, _srar.name);

	// the reward it pays (gift_reward - the same derivation the claim
	// pays out, what you see is what you get)
	draw_set_color(_rw.col);
	draw_set_alpha(_can ? 1 : .5);
	draw_text(_mid, spot_y + 46, _rw.label);

	// the action, inside the card: collect - or, done, the pill that
	// says so
	if (_can) {
		draw_ui_button(btn_x, btn_y, btn_w, btn_h, "collect", _srar.col, true, true);
	} else {
		var _cw = string_width("collected") + 9;
		draw_status_pill(spot_x + (spot_w - _cw) div 2, btn_y + 2, "collected", uist.positive);
	}

	// collect feedback: the card flushes with the reward colour
	if (flash > 0)
		draw_capsule(spot_x, spot_y, spot_w, spot_h, flash_col, flash_col, flash * .5);
	draw_set_halign(fa_left);
	__part_end();
}

// ---- the footer line: the level, its bar, the output it buys ----
if (__part(4) > 0) {
	draw_set_halign(fa_right);
	draw_set_color(_ink);
	draw_set_alpha(.8);
	draw_text(bar_x - 6, foot_y, (land ? "gift level " : "lv ") + string(_li.lv));
	draw_sprite_ext(spr_pixel_1x1, 0, bar_x, foot_y + 1, bar_w, 5, 0, c_black, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, bar_x, foot_y + 1,
		bar_w * clamp(_li.into / _li.need, 0, 1), 5, 0, c_gold, .9);
	draw_px_rect(bar_x, foot_y + 1, bar_w, 5, c_gold, .3);
	draw_set_halign(fa_left);
	draw_set_color(c_gold);
	draw_set_alpha(.8);
	draw_text(bar_x + bar_w + 6, foot_y, "+" + string(round(_li.lv * g.gift_cfg.lvl_out * 100)) + "%");
	// what the bar counts, under it, dim
	draw_set_halign(fa_center);
	draw_set_color(_dim);
	draw_set_alpha(.5);
	var _togo = _li.need - _li.into;
	draw_text(room_width div 2, foot_y + 11, land
		? (string(_togo) + ((_togo == 1) ? " gift" : " gifts") + " to the next level")
		: (string(_togo) + " to next level"));
	draw_set_halign(fa_left);
	__part_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
