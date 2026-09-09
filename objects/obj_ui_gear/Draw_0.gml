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
// The origin was moved to the sprite's MIDDLE on import, so this draws
// at the seat directly and the rotation happens about the cog's centre.
// Doing it the other way - top-left origin, half-width subtracted -
// still rotates about the origin, so the icon swung around its own
// corner instead of turning on the spot.
draw_sprite_ext(spr_gear, 0, _s.x, _s.y, 1, 1,
	ang,                                         // turns while hovered
	hot ? c_white : rgb(190, 200, 225),          // the burger's two tones
	(.85 + .15 * spin) * _s.a);
