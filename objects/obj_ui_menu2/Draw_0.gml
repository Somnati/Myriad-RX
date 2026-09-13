/// the corner X (while there is something to close) and the bar's hint

// invisible until a run starts (matches the Step gate)
if (!variable_global_exists("game_started") || !g.game_started) exit;

// ---- the X, in the burger's corner: two bars crossed, the burger's two
// tones, the hover halo it always had ----
if (ba > .01) {
	var _c = hot ? c_white : rgb(190, 200, 225);
	var _hl = 6; // bar half-length
	if (hot || rip > 0) {
		var _gw = sprite_get_width(spr_vis_glow_soft);
		draw_sprite_ext(spr_vis_glow_soft, 0, bx, by, 26 / _gw, 26 / _gw, 0,
			c_white, (.1 + .12 * (hot ? 1 : 0) + .15 * rip) * ba);
	}
	draw_px_line(bx - dcos(45) * _hl, by + dsin(45) * _hl, bx + dcos(45) * _hl, by - dsin(45) * _hl, _c, ba);
	draw_px_line(bx - dcos(-45) * _hl, by + dsin(-45) * _hl, bx + dcos(-45) * _hl, by - dsin(-45) * _hl, _c, ba);
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
