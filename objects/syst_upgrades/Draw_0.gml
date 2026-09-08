/// the slot list. statistics_v2's row language - opaque panel, gradient
/// edge seams, a colour band at the left - so this reads as part of the
/// same game rather than a fourth invented style.

draw_set_font(fnt);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _dim = rgb(120, 130, 150);
var _n   = upgrade_slots();
var _ub  = upgrade_bonus();

// ---- the title strip ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, list_y - bby, 0,
	c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y - 1, room_width, 1, 0, sett_ink, .25);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 8, "upgrades");
// the purse, right where the prices are
draw_set_halign(fa_right);
draw_set_color(c_lavender);
draw_set_alpha(.95);
draw_text(room_width - 70, bby + 8,
	((g.credits >= arb(1)) ? crunch_arb(g.credits) : "0") + " credits");
draw_set_halign(fa_left);
draw_set_alpha(1);

var _bk = __back_rect();
draw_ui_back(_bk.x1, _bk.y1, _bk.x2 - _bk.x1, _bk.y2 - _bk.y1);

// ---- the slots ----
for (var _i = 0; _i < _n; _i++) {
	var _ry = __row_y(_i);
	var _s  = g.upg.slot[_i];
	var _has = is_struct(_s);
	var _col = _has ? __rar_col(_s.rar) : _dim;

	// the panel: statistics' recipe, opaque with gradient seams
	var _c = merge_colour(c_hsv(168, 160, 5), c_hsv(169, 186, 5), .2);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, row_h, 0, _c, 1);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, row_x, _ry, row_w, 1, 0,
		_c, c_black, c_black, _c, .52);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, row_x, _ry + row_h - 1,
		row_w, 1, 0, c_black, _c, _c, c_black, .52);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, 2, row_h, 0, _col, _has ? .9 : .35);
	if (sel == _i)
		draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, row_h, 0, c_white, .04);

	if (!_has) {
		draw_set_color(_dim);
		draw_set_alpha(.55);
		draw_text(row_x + 8, _ry + 6,  "empty slot");
		draw_set_alpha(.4);
		draw_text(row_x + 8, _ry + 18, "roll an offer into it");
		var _r0 = __btn(0, 1);
		draw_ui_button(_r0.x, _ry + 16, _r0.w, _r0.h, "roll", c_sblue, true, true);
		continue;
	}

	var _e   = upgrade_entry(_s.id);
	var _cap = upgrade_cap(_i);
	var _cost = upgrade_cost(_i);
	var _name = (_e == -1) ? _s.id : _e.name;

	// line 1: the rarity, then the name
	draw_set_color(_col);
	draw_set_alpha(.9);
	draw_text(row_x + 8, _ry + 5, __rar_name(_s.rar));
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(row_x + 8 + string_width(__rar_name(_s.rar)) + 6, _ry + 5, _name);

	// line 2: what it is doing, or what it would do
	draw_set_alpha(.75);
	if (_s.tier > 0) {
		draw_set_color((_e == -1) ? _dim : _e.col);
		var _tot = _s.val * _s.tier;
		var _sfx = (_s.id == "crit_multi") ? "x" : "%";
		draw_text(row_x + 8, _ry + 18,
			"+" + string_format(_tot, 1, 2) + _sfx
			+ "   tier " + string(_s.tier) + "/" + string(_cap));
	} else {
		draw_set_color(_dim);
		draw_text(row_x + 8, _ry + 18,
			(_e == -1) ? "retired - sell to free the slot"
			           : _e.help + "   +" + string_format(_s.val, 1, 2)
			             + ((_s.id == "crit_multi") ? "x" : "%") + " a tier");
	}

	// the buttons. Cost INSIDE the buy button, the drawer's grammar -
	// the price and the action are one thing, so you never read a number
	// and then hunt for the control that spends it.
	var _r0 = __btn(0, 2);
	var _r1 = __btn(1, 2);
	var _afford = (_cost > 0) && (g.credits >= arb(_cost));
	var _lbl = (_cost < 0) ? "maxed" : string(_cost);
	draw_ui_button(_r0.x, _ry + 16, _r0.w, _r0.h, _lbl,
		_afford ? c_sgreen : c_hred, _cost > 0, _afford);

	var _pay = upgrade_sell_value(_i);
	draw_ui_button(_r1.x, _ry + 16, _r1.w, _r1.h,
		(_s.tier > 0) ? "sell " + string(_pay) : "discard",
		c_lavender, true, false);
}

// ---- the footer: what all of it adds up to ----
// The screen is a list of individual purchases, and the thing a player
// actually wants to know is the total. Without this the only way to see
// it is the statistics screen, which is a room away.
var _fy = __row_y(_n) + 2;
if (_fy < room_height - 12) {
	draw_set_color(_dim);
	draw_set_alpha(.6);
	var _t = "tap +" + string_format(_ub.tap_profit, 1, 0) + "%"
		+ "   dials +" + string_format(_ub.dial_profit, 1, 0) + "%"
		+ "   speed +" + string_format(_ub.dial_speed, 1, 0) + "%"
		+ "   crit +" + string_format(_ub.crit_rate, 1, 0) + "%";
	draw_text(row_x, _fy, _t);
}

draw_set_alpha(1);
draw_set_color(c_white);
