/// @description the dock
var _seats = __seats();
if (array_length(_seats) == 0) exit;
for (var _k = 0; _k < array_length(_seats); _k++) {
	var _s = _seats[_k];
	var _a = _s.t;   // its own rise
	var _ic = icons[_s.i];
	var _hot = (hot_i == _s.i);
	var _rp = (rip_i == _s.i) ? rip : 0;
	// hover halo, the burger's exactly - the dock and the burger are one
	// control surface and should light the same way
	if (_hot || _rp > 0) {
		var _gw = sprite_get_width(spr_vis_glow_soft);
		draw_sprite_ext(spr_vis_glow_soft, 0, _s.x + .5, _s.y + .5, 26 / _gw, 26 / _gw, 0,   // (the disc's centre: the middle of pixel (x, y))
			c_white, (.1 + .12 * _ic.spin + .15 * _rp) * _a);
	}
	__glyph(_s.i, _s.x, _s.y, _a, _ic.spin, _hot);
	// ITS NAME, above (his ask, 2026-09-13: "for some players it might be
	// vague"): rides the hover ease, lifting a few px as it fades in
	if (_ic.spin > .01) {
		var _nm = _ic.name;
		draw_set_font(fnt_outline);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(_ic.spin * _a);
		var _nw = string_width(_nm);
		var _nx = clamp(round(_s.x - .5 - _nw * .5), 2, room_width - _nw - 2);
		draw_text(_nx, floor(_s.y) - 22 + round((1 - _ic.spin) * 3), _nm);
		draw_set_font(fnt);
		draw_set_alpha(1);
	}
}
draw_set_alpha(1);
draw_set_color(c_white);
