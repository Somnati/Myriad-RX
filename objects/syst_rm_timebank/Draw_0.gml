/// the room's face. Draw-only; the Step's hits share this geometry.

var _tb = g.timebank;
var _spending = (_tb.spd > 1 && _tb.bank > 0);

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---- the title strip ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, hh + 15, room_width, 1, 0, sett_ink, .25);
draw_set_color(c_gold);
draw_set_alpha(.95);
draw_text(6, hh + 5, "time bank");

var _bk = __back_rect();
draw_ui_back(_bk.x1, _bk.y1, _bk.x2 - _bk.x1, _bk.y2 - _bk.y1);

// ---- the bank, big and central ----
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
draw_text(cx, bank_y + 20, "+"
	+ string(min(g.tb_rate + _tb.rate_lv * g.tb_rate_step, g.tb_rate_cap, 55))
	+ "m banked per hour away   -   cap " + crunch_time_long(_cap * 60));

// the fill toward the cap
var _bw = 180;
var _bx = cx - _bw * .5;
var _by = bank_y + 33;
draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by, _bw, 5, 0, c_black, .8);
draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by,
	_bw * clamp(_tb.bank / max(1, _cap), 0, 1), 5, 0,
	_spending ? c_gold : c_sblue, .85);
draw_px_rect(_bx, _by, _bw, 5, c_sblue, .35);

// ---- the speed row ----
draw_set_color(sett_ink);
draw_set_alpha(.55);
draw_text(cx, spd_y - 12, "active speed - the bank pays the difference");
draw_set_halign(fa_left);
for (var _k = 0; _k < 6; _k++) {
	var _px = spd_x0 + _k * (spd_w + spd_gap);
	var _on = (_tb.spd == spds[_k]);
	draw_ui_button(_px, spd_y, spd_w, 16, "x" + string(spds[_k]),
		_on ? c_gold : rgb(170, 190, 230), true, _on);
}
if (_spending) {
	draw_set_halign(fa_center);
	draw_set_color(c_gold);
	draw_set_alpha(.6 + .25 * dsin(current_time * .35));
	draw_text(cx, spd_y + 22,
		"spending " + string(_tb.spd - 1) + "s of bank per second");
	draw_set_halign(fa_left);
}

// ---- the two upgrades, cost inside (the house buy-button language) ----
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
			"capacity " + string(g.tb_cap + _tb.cap_lv * g.tb_cap_step) + "m");
		draw_set_color(c_sgreen);
		draw_set_alpha(.7);
		draw_text(upg_x + 110, _ry + 5, "+" + string(g.tb_cap_step) + "m");
	} else {
		draw_text(upg_x + 6, _ry + 5, "rate "
			+ string(min(g.tb_rate + _tb.rate_lv * g.tb_rate_step,
				g.tb_rate_cap, 55)) + "m/hr");
		draw_set_color(c_sgreen);
		draw_set_alpha(_q.maxed ? 0 : .7);
		draw_text(upg_x + 110, _ry + 5, "+" + string(g.tb_rate_step) + "m");
	}
	var _bbx = upg_x + upg_w - 62;
	draw_sprite_ext(spr_pixel_1x1, 0, _bbx, _ry + 1, 60, 14, 0,
		_en ? merge_colour(c_black, c_sgreen, .18) : c_black, .85);
	draw_px_rect(_bbx, _ry + 1, 60, 14, _en ? c_sgreen : c_gray, _en ? .8 : .3);
	draw_set_halign(fa_center);
	draw_set_color(c_gold);
	draw_set_alpha(_en ? .95 : .45);
	draw_text(_bbx + 30, _ry + 4, (_q.txt != "") ? _q.txt : "-");
	draw_set_halign(fa_left);
}

// ---- the explainer ----
draw_set_halign(fa_center);
draw_set_color(rgb(120, 130, 150));
draw_set_alpha(.5);
draw_text(cx, room_height - 32, "while away, production runs AND time banks on top");
draw_text(cx, room_height - 22,
	"at x4, every second plays 4 - the bank pays the other 3");
draw_set_halign(fa_left);

draw_set_alpha(1);
draw_set_color(c_white);
