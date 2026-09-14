/// the shop's face. Draw-only; the Step's hits share this geometry.
var _v = g.cheat.v;
var _cap = cheat_cap();
var _free = cheat_free();

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---- the title strip - slides down from under the header ----
var _sp = ui_anim_in(oa, 1);
if (_sp > .001) {
	var _so = -(1 - _sp) * UI_IN_SLIDE;
	if (_so != 0) matrix_set(matrix_world, matrix_build(0, _so, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_sp);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, 16, 0, c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, hh + 15, room_width, 1, 0, sett_ink, .25);
	draw_set_color(c_feat_cheat);
	draw_set_alpha(.95);
	draw_text(6, hh + 5, "cheat shop");
	draw_set_halign(fa_right);
	draw_set_color(sett_ink);
	draw_set_alpha(.5);
	draw_text(room_width - 6, hh + 5, "obtain rates");
	draw_set_halign(fa_left);
	__part_end();
}

// ---- the cap band: what there is to spend ----
if (__part(2) > 0) {
	draw_set_color(sett_ink);
	draw_set_alpha(.6);
	// "cap" here is what he calls the cap: how high a row may go (his
	// report, 2026-09-14: the band showed the points total as "cap" and
	// it "did not reflect the real value"). The unspent points are "spare"
	draw_text(x0, band_y, "rows up to " + string(CHEAT_ROW_MAX) + "%");
	draw_set_color((_free > 0) ? c_gold : sett_ink);
	draw_set_alpha((_free > 0) ? .95 : .6);
	draw_text(x0 + (land ? 92 : 74), band_y, "spare " + string(max(0, _free)) + "%");
	draw_ui_button(x1 - def_w, band_y - 2, def_w, 14, "default", c_feat_cheat, true, false);
	__part_end();
}

// ---- the rows ----
for (var _i = 0; _i < N; _i++) {
	if (__part(3 + _i) <= 0) continue;
	var _r  = cfg.rows[_i];
	var _ry = row_y0 + _i * row_h;
	var _hot = (hot_row == _i);
	var _val = _v[_i];
	// the row's ground, lit under the pointer
	if (_hot) draw_sprite_ext(spr_pixel_1x1, 0, x0 - 4, _ry, x1 - x0 + 8, row_h, 0, c_white, .05);
	// the name
	draw_set_halign(fa_left);
	draw_set_color(_r.col);
	draw_set_alpha(_hot ? 1 : .85);
	draw_text(x0, _ry + 2, _r.name);
	// the percent
	draw_set_halign(fa_right);
	draw_set_font((_val != 100) ? fnt_outline : fnt);
	draw_set_color((_val > 100) ? c_gold : ((_val < 100) ? rgb(150, 160, 185) : c_white));
	draw_set_alpha(1);
	draw_text(val_x, _ry + val_dy, string(_val) + "%");
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	// the bar: the fill to the row max, the 100 mark
	var _b = __bar(_i);
	draw_sprite_ext(spr_pixel_1x1, 0, _b.x, _b.y, _b.w, _b.h, 0, c_black, .8);
	var _fw = round(_b.w * clamp(_val / CHEAT_ROW_MAX, 0, 1));
	draw_sprite_ext(spr_pixel_1x1, 0, _b.x, _b.y, _fw, _b.h, 0, _r.col, (drag == _i) ? 1 : .8);
	draw_sprite_ext(spr_pixel_1x1, 0, _b.x, _b.y, _fw, 1, 0, c_white, .25);
	var _mx = _b.x + round(_b.w * (100 / CHEAT_ROW_MAX));
	draw_sprite_ext(spr_pixel_1x1, 0, _mx, _b.y - 1, 1, _b.h + 2, 0, c_white, .5);
	draw_px_rect(_b.x, _b.y, _b.w, _b.h, _r.col, _hot ? .5 : .25);
	// the buttons
	var _by = _ry + 1;
	var _can_dn = (_val > CHEAT_ROW_MIN);
	var _can_up = (_val < CHEAT_ROW_MAX) && (_free >= CHEAT_STEP);
	draw_ui_button(bx_minus, _by, bw_btn, 13, "-", _r.col, _can_dn, false);
	draw_ui_button(bx_plus,  _by, bw_btn, 13, "+", _r.col, _can_up, true);
	__part_end();
}

// ---- the footer: the hovered row's line, or the rule ----
if (__part(3 + N) > 0) {
	draw_set_halign(fa_center);
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	var _txt = (hot_row >= 0) ? cfg.rows[hot_row].help
		: "the normal amount is 100%. lower one thing to raise another.";
	draw_text(room_width * .5, foot_y, _txt);
	draw_set_alpha(.4);
	draw_text(room_width * .5, foot_y + 12, "more to spend and higher rows come from the ability deck (cheat points, cheat ceiling)");
	draw_set_halign(fa_left);
	__part_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
