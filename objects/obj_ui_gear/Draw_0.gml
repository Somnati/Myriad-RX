/// @description the dock
var _seats = __seats();
if (array_length(_seats) == 0) exit;
var _a = __seat().a;

for (var _k = 0; _k < array_length(_seats); _k++) {
	var _s = _seats[_k];
	var _ic = icons[_s.i];
	var _hot = (hot_i == _s.i);
	var _rp = (rip_i == _s.i) ? rip : 0;
	// hover halo, the burger's exactly - the dock and the burger are one
	// control surface and should light the same way
	if (_hot || _rp > 0) {
		var _gw = sprite_get_width(spr_vis_glow_soft);
		draw_sprite_ext(spr_vis_glow_soft, 0, _s.x, _s.y, 26 / _gw, 26 / _gw, 0,
			c_white, (.1 + .12 * _ic.spin + .15 * _rp) * _a);
	}
	__glyph(_s.i, _s.x, _s.y, _a, _ic.spin, _hot);
}
draw_set_alpha(1);
draw_set_color(c_white);
