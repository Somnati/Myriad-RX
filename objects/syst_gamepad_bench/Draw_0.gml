/// the bench view. everything reads g.pad (settled in begin step);
/// the middle column's raw dots read the active device directly -
/// that's the point, raw vs processed side by side.

draw_set_font(fnt);
var _p = g.pad;

// ---- title strip (house chrome) ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0,
	c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0,
	rgb(170, 190, 230), .25);
draw_set_halign(fa_left);
draw_set_color(sett_ink);
draw_set_alpha(.85);
draw_text(6, bby + 4, "gamepad bench");
draw_set_color(c_gold);
draw_set_alpha(.7);
draw_text_transformed(106, bby + 5,
	"plug in a pad - sticks, rebinds, rumble", .85, .85, 0);
draw_set_alpha(1);
draw_ui_back(room_width - 62, bby + 1, 56, 13);

// ---- left: device slots ----
for (var _i = 0; _i < 12; _i++) {
	var _d = _p.devs[_i];
	var _dy = __dev_y(_i);
	var _on = _d.conn;
	draw_sprite_ext(spr_pixel_1x1, 0, dev_x, _dy + 2, 5, 5, 0,
		_on ? c_sgreen : c_dkgray, _on ? .95 : .4);
	draw_set_color(_on ? sett_ink : c_gray);
	draw_set_alpha(_on ? .85 : .3);
	var _nm = _on ? string_copy(_d.name, 1, min(string_length(_d.name), 20))
	              : "slot " + string(_i);
	draw_text_transformed(dev_x + 9, _dy, _nm, .7, .7, 0);
	if (_i == _p.active) {
		draw_set_color(c_gold);
		draw_set_alpha(.9);
		draw_text_transformed(dev_x + 128, _dy, "<", .7, .7, 0);
	}
}
draw_set_alpha(1);

// ---- left: deadzone + threshold sliders (procgen slider style) ----
var _sv = [
	{ y : dz_y,  name : "deadzone",  t : (_p.dz - .05) / .5,       v : _p.dz },
	{ y : thr_y, name : "digi thr",  t : (_p.digi_thr - .2) / .6,  v : _p.digi_thr },
];
for (var _i = 0; _i < 2; _i++) {
	var _s = _sv[_i];
	draw_set_color(sett_ink);
	draw_set_alpha(.75);
	draw_text_transformed(sld_x, _s.y, _s.name, .85, .85, 0);
	draw_sprite_ext(spr_pixel_1x1, 0, sld_x, _s.y + 10, sld_w, 4, 0, c_black, .75);
	draw_sprite_ext(spr_pixel_1x1, 0, sld_x, _s.y + 10, sld_w * clamp(_s.t, 0, 1),
		4, 0, c_sgreen, .9);
	draw_px_rect(sld_x, _s.y + 10, sld_w, 4, sett_ink, .35);
	draw_set_color(merge_colour(c_gold, c_white, .3));
	draw_set_alpha(.65);
	draw_text_transformed(sld_x + sld_w + 6, _s.y + 4,
		string(round(_s.v * 100) / 100), .7, .7, 0);
}
draw_set_alpha(1);

// buttons
draw_ui_button(sld_x, btn_y, 70, 13, "rumble", c_horange, _p.active >= 0, false);
draw_ui_button(sld_x + 76, btn_y, 76, 13, "reset binds", c_hred, true, false);

// log strip
var _ll = array_length(_p.log);
for (var _i = max(0, _ll - 4); _i < _ll; _i++) {
	draw_set_color(sett_ink);
	draw_set_alpha(.25 + .14 * (_i - (_ll - 4)));
	draw_text_transformed(sld_x, log_y + (_i - max(0, _ll - 4)) * 9,
		_p.log[_i], .7, .7, 0);
}
draw_set_alpha(1);

// ---- middle: live sticks (raw dim dot vs processed bright dot) ----
var _hasdev = (_p.active >= 0 && _p.devs[_p.active].conn);
for (var _k = 0; _k < 2; _k++) {
	var _cx = (_k == 0) ? stk_lx : stk_rx;
	draw_set_color(c_black);
	draw_set_alpha(.55);
	draw_circle(_cx, stk_y, stk_r, false);
	draw_set_color(sett_ink);
	draw_set_alpha(.3);
	draw_circle(_cx, stk_y, stk_r, true);
	// the deadzone floor, visible on the dial
	draw_set_alpha(.18);
	draw_circle(_cx, stk_y, stk_r * _p.dz, true);
	if (_hasdev) {
		var _rx = gamepad_axis_value(_p.active, _k == 0 ? gp_axislh : gp_axisrh);
		var _ry = gamepad_axis_value(_p.active, _k == 0 ? gp_axislv : gp_axisrv);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + _rx * stk_r - 1,
			stk_y + _ry * stk_r - 1, 2, 2, 0, c_gray, .6);
	}
	var _act = (_k == 0) ? "move" : "look";
	draw_sprite_ext(spr_pixel_1x1, 0, _cx + pad_x(_act) * stk_r - 1,
		stk_y + pad_y(_act) * stk_r - 1, 3, 3, 0, c_sgreen, .95);
	draw_set_color(sett_ink);
	draw_set_alpha(.5);
	draw_set_halign(fa_center);
	draw_text_transformed(_cx, stk_y + stk_r + 3, _act, .7, .7, 0);
	draw_set_halign(fa_left);
}
draw_set_alpha(1);

// triggers
var _tv = [pad_value("lt"), pad_value("rt")];
for (var _k = 0; _k < 2; _k++) {
	var _tx = grid_x + _k * 66;
	draw_sprite_ext(spr_pixel_1x1, 0, _tx, trg_y, 60, 5, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _tx, trg_y, 60 * _tv[_k], 5, 0, c_horange, .9);
	draw_px_rect(_tx, trg_y, 60, 5, sett_ink, .3);
	draw_set_color(sett_ink);
	draw_set_alpha(.5);
	draw_text_transformed(_tx, trg_y + 7, _k == 0 ? "lt" : "rt", .7, .7, 0);
}
draw_set_alpha(1);

// button grid: the 16 scannables, lit while held on ANY pad, glyphs
// in the active device's dialect
for (var _i = 0; _i < array_length(_p.btns); _i++) {
	var _gx = grid_x + (_i mod 4) * (chip_w + 4);
	var _gy = grid_y + (_i div 4) * (chip_h + 3);
	var _lit = false;
	for (var _di = 0; _di < 12 && !_lit; _di++)
		if (_p.devs[_di].conn && gamepad_button_check(_di, _p.btns[_i]))
			_lit = true;
	var _g = _p.glyph_xbox[_i];
	if (_hasdev) {
		var _kd = _p.devs[_p.active].kind;
		if (_kd == "ps") _g = _p.glyph_ps[_i];
		else if (_kd == "switch") _g = _p.glyph_sw[_i];
	}
	draw_sprite_ext(spr_pixel_1x1, 0, _gx, _gy, chip_w, chip_h, 0,
		_lit ? c_sgreen : c_black, _lit ? .85 : .6);
	draw_px_rect(_gx, _gy, chip_w, chip_h, _lit ? c_sgreen : sett_ink, .35);
	draw_set_color(_lit ? c_black : sett_ink);
	draw_set_alpha(_lit ? .95 : .6);
	draw_set_halign(fa_center);
	draw_text_transformed(_gx + chip_w * .5, _gy + 3, _g, .7, .7, 0);
	draw_set_halign(fa_left);
}
draw_set_alpha(1);

// ---- right: the action map, tap a row to rebind ----
for (var _i = 0; _i < array_length(rows); _i++) {
	var _nm = rows[_i];
	var _a = _p.acts[$ _nm];
	var _ry = __act_y(_i);
	var _arm = (_p.rebind == _nm);
	var _dn = pad_down(_nm);
	draw_sprite_ext(spr_pixel_1x1, 0, act_x, _ry, act_w, 10, 0,
		_arm ? c_gold : c_black, _arm ? .25 : .5);
	// live state dot
	draw_sprite_ext(spr_pixel_1x1, 0, act_x + 2, _ry + 3, 4, 4, 0,
		_dn ? c_sgreen : c_dkgray, _dn ? .95 : .5);
	draw_set_color(sett_ink);
	draw_set_alpha(.8);
	draw_text_transformed(act_x + 10, _ry + 1, _a.label, .7, .7, 0);
	if (_arm) {
		// pulse while listening
		draw_set_color(merge_colour(c_gold, c_white,
			.3 + .3 * dsin(current_time * .4)));
		draw_set_alpha(.95);
		draw_text_transformed(act_x + 74, _ry + 1, "press input...", .7, .7, 0);
	} else {
		draw_set_color(c_gold);
		draw_set_alpha(.7);
		var _gl = pad_glyph(_nm, 0);
		if (array_length(_a.binds) > 1) _gl += " / " + pad_glyph(_nm, 1);
		draw_text_transformed(act_x + 74, _ry + 1, _gl, .7, .7, 0);
	}
}
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
