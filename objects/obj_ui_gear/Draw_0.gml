/// @description the cog

if (in_room(rm_settings)) exit;

var _s = __seat();
if (_s.a <= .01) exit;

// hover halo, the burger's exactly - the two are one control surface
// and should light the same way
if (hot || rip > 0) {
	var _gw = sprite_get_width(spr_vis_glow_soft);
	draw_sprite_ext(spr_vis_glow_soft, 0, _s.x, _s.y, 26 / _gw, 26 / _gw, 0,
		c_white, (.1 + .12 * spin + .15 * rip) * _s.a);
}

// DE's cog is frame 0; frame 1 is its inverse (the cog cut out of a
// disc), which is the wrong read for a flat icon.
// The sprite's origin is its top-left corner, so the seat is centred by
// hand rather than by moving the origin - the imported .yy stays as DE
// wrote it, and nothing else in RX has to know that.
var _w = sprite_get_width(spr_gear);
var _h = sprite_get_height(spr_gear);
draw_sprite_ext(spr_gear, 0, _s.x - _w * .5, _s.y - _h * .5, 1, 1,
	spin * 30,                                   // a nudge on hover
	hot ? c_white : rgb(190, 200, 225),          // the burger's two tones
	(.85 + .15 * spin) * _s.a);
