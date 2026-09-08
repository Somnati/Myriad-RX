/// the slot list. statistics_v2's row language - opaque panel, gradient
/// edge seams, a colour band at the left - so this reads as part of the
/// same game rather than a fourth invented style.
///
/// ONE LINE A ROW, in fixed columns: name, effect, tier, rarity, and
/// the one button the mode decides. Fixed columns rather than text
/// flowing after text, because a list you SCAN wants its numbers under
/// each other - eight rows whose tier column moves with the length of
/// the name is eight rows you have to read individually.

draw_set_font(fnt);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _dim = rgb(120, 130, 150);
var _n   = upgrade_slots();
var _ub  = upgrade_bonus();   // the TRUTH, not the gated reader - this
                              // screen shows what the slots would do
                              // even while UPG_LIVE keeps them idle

// ---- the title strip ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, list_y - bby, 0,
	c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y - 1, room_width, 1, 0, sett_ink, .25);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 5, "upgrades");

// the mode pills. menu2's colour language: the live one is a solid
// fill, the other sinks toward black.
var _mname = ["buy", "sell"];
var _mcol  = [c_sgreen, c_lavender];
for (var _m = 0; _m < 2; _m++) {
	var _r = __mode_rect(_m);
	var _on = (mode == _m);
	var _hov = point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h);
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0,
		_on ? merge_colour(_mcol[_m], c_black, .55) : c_black, _on ? .95 : .5);
	draw_px_rect(_r.x, _r.y, _r.w, _r.h, _mcol[_m], _on ? .9 : (_hov ? .55 : .3));
	draw_set_halign(fa_center);
	draw_set_color(_on ? c_white : merge_colour(_mcol[_m], c_white, _hov ? .6 : .3));
	draw_set_alpha(_on ? .95 : .75);
	draw_text(_r.x + _r.w / 2 + 1, _r.y + 2, _mname[_m]);
}

// the purse, right where the prices are
draw_set_halign(fa_right);
draw_set_color(c_lavender);
draw_set_alpha(.95);
draw_text(room_width - 70, bby + 5,
	((g.credits >= arb(1)) ? crunch_arb(g.credits) : "0") + " credits");
draw_set_halign(fa_left);
draw_set_alpha(1);

var _bk = __back_rect();
draw_ui_back(_bk.x1, _bk.y1, _bk.x2 - _bk.x1, _bk.y2 - _bk.y1);

// ---- the slots ----
var _cx_eff = row_x + 132;   // the columns, shared by every row
var _cx_tir = row_x + 214;
var _cx_rar = row_x + 268;

for (var _i = 0; _i < _n; _i++) {
	var _ry  = __row_y(_i);
	var _s   = g.upg.slot[_i];
	var _has = is_struct(_s);
	var _col = _has ? __rar_col(_s.rar) : _dim;

	// the panel: statistics' recipe, opaque with gradient seams
	var _c = merge_colour(c_hsv(168, 160, 5), c_hsv(169, 186, 5), .2);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, row_h, 0, _c, 1);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, row_x, _ry, row_w, 1, 0,
		_c, c_black, c_black, _c, .52);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, row_x, _ry + row_h - 1,
		row_w, 1, 0, c_black, _c, _c, c_black, .52);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, 2, row_h, 0, _col, _has ? .9 : .3);
	if (sel == _i)
		draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, row_h, 0, c_white, .04);

	var _b = __btn(_i);

	if (!_has) {
		draw_set_color(_dim);
		draw_set_alpha(.5);
		draw_text(row_x + 7, _ry + 4, "empty slot");
		draw_ui_button(_b.x, _b.y, _b.w, _b.h, "roll", c_sblue, true, true);
		continue;
	}

	var _e    = upgrade_entry(_s.id);
	var _cap  = upgrade_cap(_i);
	var _name = (_e == -1) ? _s.id : _e.name;

	draw_set_color((_s.tier > 0) ? c_white : _dim);
	draw_set_alpha(.95);
	draw_text(row_x + 7, _ry + 4, _name);

	draw_set_color(_col);
	draw_set_alpha(_s.tier > 0 ? .95 : .6);
	draw_text(_cx_eff, _ry + 4, (_e == -1) ? "retired" : __eff_str(_s));

	draw_set_color(_dim);
	draw_set_alpha(.8);
	draw_text(_cx_tir, _ry + 4,
		(_s.tier > 0) ? (string(_s.tier) + " / " + string(_cap)) : "offer");

	draw_set_color(_col);
	draw_set_alpha(.55);
	draw_text(_cx_rar, _ry + 4, __rar_name(_s.rar));

	// ---- the one button, whatever the mode says it is ----
	if (mode == 0) {
		var _cost   = upgrade_cost(_i);
		var _afford = (_cost > 0) && (g.credits >= arb(_cost));
		draw_ui_button(_b.x, _b.y, _b.w, _b.h,
			(_cost < 0) ? "maxed" : string(_cost),
			_afford ? c_sgreen : c_hred, _cost > 0, _afford);
	} else {
		var _pay = upgrade_sell_value(_i);
		draw_ui_button(_b.x, _b.y, _b.w, _b.h,
			(_s.tier > 0) ? string(_pay) : "discard",
			c_lavender, true, _s.tier > 0);
	}
}

// ---- the footer: what all of it adds up to ----
// The screen is a list of individual purchases and the thing a player
// actually wants is the total. Without this the only place to see it is
// the statistics screen, a room away.
var _fy = __row_y(_n) + 4;
if (_fy < room_height - 20) {
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(row_x + 7, _fy,
		"tap +" + string_format(_ub.tap_profit, 1, 0) + "%"
		+ "   dials +" + string_format(_ub.dial_profit, 1, 0) + "%"
		+ "   speed +" + string_format(_ub.dial_speed, 1, 0) + "%"
		+ "   crit +" + string_format(_ub.crit_rate, 1, 0) + "%"
		+ "   cost -" + string_format(_ub.dial_cost, 1, 0) + "%");

	// ⚖️ AND SAY SO WHILE IT IS OFF. A screen that quotes bonuses the
	// game is not applying, without saying so, is a screen that lies.
	if (!UPG_LIVE) {
		draw_set_color(c_horange);
		draw_set_alpha(.75);
		draw_text(row_x + 7, _fy + 11,
			"preview - upgrades are not affecting the game yet");
	}
}

draw_set_alpha(1);
draw_set_color(c_white);
