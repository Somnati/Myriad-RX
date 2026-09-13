/// the corner X (while there is something to close) and the bar's hint

// invisible until a run starts (matches the Step gate)
if (!variable_global_exists("game_started") || !g.game_started) exit;

// ---- the X, in the burger's corner: two bars crossed, the burger's two
// tones, the hover halo it always had ----
if (ba > .01) {
	var _c = hot ? c_white : rgb(190, 200, 225);
	var _hl = 5; // bar half-length: eleven cells
	if (hot || rip > 0) {
		var _gw = sprite_get_width(spr_vis_glow_soft);
		draw_sprite_ext(spr_vis_glow_soft, 0, bx, by, 26 / _gw, 26 / _gw, 0,
			c_white, (.1 + .12 * (hot ? 1 : 0) + .15 * rip) * ba);
	}
	// ⚖️ PIXEL-PERFECT (his report: the crossing was not centred): the two
	// bars are STAMPS along their lines, eleven cells each, about the
	// centre pixel (bx, by) - no rotated quad, so at 45 degrees they are
	// exact diagonals, symmetric top to bottom. THE FOLD (his ask): they
	// begin flat - one horizontal bar - and open to the X as they arrive
	// (the angle rides ba with the alpha), folding back flat on the way
	// out. Cells are deduplicated along each bar, or a shallow angle
	// would stamp one cell twice and brighten it mid-fade
	var _ang = 45 * (ba * ba * (3 - 2 * ba));
	for (var _b = 0; _b < 2; _b++) {
		var _a2 = (_b == 0) ? _ang : -_ang;
		var _lx = -999, _ly = -999;
		for (var _k = -_hl; _k <= _hl; _k++) {
			var _px = bx + round(_k * dcos(_a2)), _py = by - round(_k * dsin(_a2));
			if (_px == _lx && _py == _ly) continue;
			draw_sprite_ext(spr_pixel_1x1, 0, _px, _py, 1, 1, 0, _c, ba);
			_lx = _px; _ly = _py;
		}
	}
	// press ripple: an expanding dotted ring
	if (rip > 0) {
		var _rr = (1 - rip) * 11 + 3;
		for (var _k = 0; _k < 12; _k++) {
			var _ra = _k * 30;
			draw_sprite_ext(spr_pixel_1x1, 0, bx + dcos(_ra) * _rr, by - dsin(_ra) * _rr,
				1, 1, 0, c_white, rip * .5 * ba);
		}
	}
}

// ---- THE HINT: DE's line on the bar. Landscape: centred on the bar,
// where nothing else lives; portrait: just under it, centred (the bar
// there is the counter's). Gold under the pointer, the way DE's went ----
if (ha > .01) {
	var _bh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
	var _txt = open ? "tap here to close it" : "tap up here to open the menu";
	draw_set_font(fnt);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(hot_bar ? c_gold : merge_colour(c_white, c_gold, .35));
	draw_set_alpha(ha);
	if (room_width > 300) draw_text(floor(room_width * .5), 4, _txt);
	else draw_text(floor(room_width * .5), _bh + 2, _txt);
	draw_set_halign(fa_left);
	draw_set_alpha(1);
	draw_set_color(c_white);
}
