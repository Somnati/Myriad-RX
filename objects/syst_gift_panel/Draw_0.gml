/// THE DAILY GIFT's face - one card, one accent. Draw-only; the Step's
/// hits share this geometry. Every part rides the open ease through
/// __part(i): the strip, then the card, then its rows.

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _br  = abs(dsin(current_time * .3)); // the shared breath
var _can = gift_can_claim();
var _pos = g.gift.pos;
var _n   = g.gift_cfg.days;
var _spot = board[_pos];
var _srar = g.gift_cfg.rars[_spot.rar];
var _rw  = gift_reward(_spot);
var _li  = gift_level();
var _dim = rgb(120, 130, 150);
var _ink = sett_ink;
var _ac  = _srar.col;                     // THE accent: this gift's rarity
var _plate = c_hsv(169, 150, 8);          // the card's ground

// ---- the ground: the room shows through, blurred (ui_blur_tick) ----
// (no ground of its own: obj_menu2_bck paints the plate + gradients UNDER the blur - his "menu blur" ask)

// ---- the title strip - slides down from under the header. The title
// alone; the card says everything else ----
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
	__part_end();
}

// ---- the card ----
if (__part(2) > 0) {
	// a soft glow in the accent behind it, breathing while the gift is
	// on the table
	var _gs = (cw * 1.3) / max(1, sprite_get_width(spr_vis_glow_soft));
	draw_sprite_ext(spr_vis_glow_soft, 0, cx + cw div 2, cy + ch div 2, _gs, _gs * .7, 0, _ac,
		_can ? .10 + .06 * _br : .04);
	// the plate: opaque, a light top edge, a dark bottom edge, and the
	// accent as a hairline rim (the deck's capsule shape)
	draw_capsule(cx, cy, cw, ch, _plate, _plate, .97);
	draw_capsule(cx, cy, cw, ch, _ac, _ac, _can ? .10 + .06 * _br : .06);
	draw_sprite_ext(spr_pixel_1x1, 0, cx + 6, cy, cw - 12, 1, 0, c_white, .10);
	draw_sprite_ext(spr_pixel_1x1, 0, cx + 6, cy + ch - 1, cw - 12, 1, 0, c_black, .5);
	// collect feedback: the card flushes with the accent
	if (flash > 0) draw_capsule(cx, cy, cw, ch, flash_col, flash_col, flash * .35);
	__part_end();
}

// ---- the caption row: which gift, and the level ----
if (__part(3) > 0) {
	draw_set_color(_dim);
	draw_set_alpha(.75);
	draw_text(cx + pad, cy + y_cap, "gift " + string(_pos + 1) + " of " + string(_n)
		+ (_can ? "" : (land ? "  -  tomorrow" : "")));
	draw_set_halign(fa_right);
	draw_set_color(c_gold);
	draw_set_alpha(.7);
	draw_text(cx + cw - pad, cy + y_cap, "level " + string(_li.lv));
	draw_set_halign(fa_left);
	__part_end();
}

// ---- the headline: the amount, doubled, in the accent; what it is
// under it in tiny caps ----
if (__part(4) > 0) {
	var _amt = (_rw.kind == 0) ? crunch_arb(_rw.amount) : string(_rw.amount);
	draw_set_color(_can ? _ac : merge_colour(_ac, _dim, .5));
	draw_set_alpha(.98);
	draw_text_transformed(cx + pad, cy + y_big, "+" + _amt, 2, 2, 0);
	// the tiny line: kind, rarity - the rarity in its own colour, the
	// rest dim
	var _kind = (_rw.kind == 0) ? "profit" : "credits";
	draw_set_color(_ink);
	draw_set_alpha(.55);
	draw_text(cx + pad, cy + y_lab, _kind + "  -  ");
	draw_set_color(merge_colour(_ac, c_white, .2));
	draw_set_alpha(.9);
	draw_text(cx + pad + string_width(_kind + "  -  "), cy + y_lab, _srar.name);
	// ...and what it means: seconds of the current rate, or nothing
	// more to say for credits
	if (_rw.kind == 0) {
		var _secs = g.gift_cfg.base_secs * _srar.mult * _li.mult;
		draw_set_color(_dim);
		draw_set_alpha(.55);
		draw_text(cx + pad, cy + y_sub, crunch_time_long(_secs * 60) + (land ? " of income at the current rate" : " of income"));
	}
	__part_end();
}

// ---- the fortnight: fourteen markers on one line. Collected = ticked
// in the accent, today = ringed and breathing, ahead = dark. The two
// week caps carry a gold pip, the showpieces ----
if (__part(5) > 0) {
	for (var _i = 0; _i < _n; _i++) {
		var _x = __mark_x(_i);
		var _y = cy + y_mark;
		var _done  = (_i < _pos);
		var _today = (_i == _pos);
		if (_done) {
			draw_capsule(_x, _y, mk, mk, merge_colour(_ac, c_black, .6), merge_colour(_ac, c_black, .7), 1);
			if (land) draw_sprite_ext(spr_check, 0, _x + mk div 2, _y + mk div 2, 1, 1, 0, _ac, .95);
			else {
				draw_px_line(_x + 1, _y + 4, _x + 3, _y + 6, _ac, .95);
				draw_px_line(_x + 3, _y + 6, _x + 6, _y + 2, _ac, .95);
			}
		} else if (_today) {
			// the ring: the accent capsule, a black one inset a pixel
			draw_capsule(_x - 1, _y - 1, mk + 2, mk + 2, _ac, _ac, _can ? .55 + .4 * _br : .35);
			draw_capsule(_x, _y, mk, mk, c_black, c_black, .92);
			if (land) {
				draw_set_halign(fa_center);
				draw_set_color(_can ? c_white : _dim);
				draw_set_alpha(.95);
				draw_text(_x + mk div 2 + 1, _y + 3, string(_i + 1));
				draw_set_halign(fa_left);
			}
		} else {
			draw_capsule(_x, _y, mk, mk, c_hsv(169, 120, 14), c_hsv(169, 120, 11), 1);
			draw_capsule(_x, _y, mk, mk, c_white, c_white, .04);
		}
		// the week caps: a gold pip above (each week ends on a showpiece)
		if (_i == g.gift_cfg.floor_a || _i == g.gift_cfg.floor_b)
			draw_sprite_ext(spr_pixel_1x1, 0, _x + mk div 2 - 1, _y - 4, 2, 2, 0, c_gold, _done ? .35 : .8);
		// the just-punched marker flushes with the accent
		if (_i == slot_flash && flash > 0)
			draw_capsule(_x - 1, _y - 1, mk + 2, mk + 2, flash_col, flash_col, flash * .6);
	}
	__part_end();
}

// ---- the foot: a hairline, the action, the level's segments ----
if (__part(6) > 0) {
	draw_sprite_ext(spr_pixel_1x1, 0, cx + pad, cy + y_rule, cw - pad * 2, 1, 0, _ink, .12);
	var _b = __btn_r();
	if (_can) {
		draw_ui_button(_b.x, _b.y, _b.w, _b.h, "collect", _ac, true, true);
	} else {
		// collected: the pill says so, and the countdown to the next
		// calendar day sits beside it
		var _pw = draw_status_pill(_b.x, _b.y + 3, "collected", uist.positive);
		var _left = (1 - frac(date_current_datetime())) * 86400;
		draw_set_color(_dim);
		draw_set_alpha(.7);
		draw_text(_b.x + _pw + 8, _b.y + 5, (land ? "next gift in " : "next ") + crunch_time_long(_left * 60));
	}
	// the level: one segment per gift the level needs, the earned ones
	// gold - the only colour on the card that is not the accent
	var _seg_g = 2;
	var _seg_n = _li.need;
	// the run shrinks its segments to fit as the level's cost grows
	// (3, 5, 7... gifts a level)
	var _avail = cw - pad * 2 - (land ? 118 : 30);
	var _seg_w = clamp(floor((_avail - (_seg_n - 1) * _seg_g) / _seg_n), 2, land ? 7 : 5);
	var _row = _seg_n * _seg_w + (_seg_n - 1) * _seg_g;
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(cx + pad, cy + y_lv, land ? "next level" : "next");
	var _sx = cx + cw - pad - _row;
	for (var _s = 0; _s < _seg_n; _s++) {
		var _lit = (_s < _li.into);
		draw_sprite_ext(spr_pixel_1x1, 0, _sx + _s * (_seg_w + _seg_g), cy + y_lv + 2, _seg_w, 3, 0,
			_lit ? c_gold : c_white, _lit ? .9 : .10);
	}
	if (land) {
		draw_set_halign(fa_right);
		draw_set_color(c_gold);
		draw_set_alpha(.6);
		draw_text(_sx - 8, cy + y_lv, "+" + string(round(_li.lv * g.gift_cfg.lvl_out * 100)) + "% output");
		draw_set_halign(fa_left);
	}
	__part_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
