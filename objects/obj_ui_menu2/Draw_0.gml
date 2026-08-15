/// the morphing burger: three bars; top and bottom slide to center
/// and rotate to the X, the middle fades out. plus the press ripple

// invisible until a run starts (matches the Step gate)
if (!variable_global_exists("game_started") || !g.game_started) exit;

var _c = (hot || open) ? c_white : rgb(190, 200, 225);
var _hl = 6; // bar half-length

// hover halo
if (hot || open || t > 0) {
	var _gw = sprite_get_width(spr_vis_glow_soft);
	draw_sprite_ext(spr_vis_glow_soft, 0, bx, by, 26 / _gw, 26 / _gw, 0,
		c_white, .1 + .12 * t);
}

// top bar: slides from -4 to center, rotates to +45
var _cy = by - 4 * (1 - t);
var _a = 45 * t;
draw_px_line(bx - dcos(_a) * _hl, _cy + dsin(_a) * _hl,
	bx + dcos(_a) * _hl, _cy - dsin(_a) * _hl, _c, 1);

// bottom bar: +4 to center, rotates to -45
_cy = by + 4 * (1 - t);
_a = -45 * t;
draw_px_line(bx - dcos(_a) * _hl, _cy + dsin(_a) * _hl,
	bx + dcos(_a) * _hl, _cy - dsin(_a) * _hl, _c, 1);

// middle bar fades away
if (t < 1)
	draw_px_line(bx - _hl, by, bx + _hl, by, _c, 1 - t);

// press ripple: an expanding dotted ring
if (rip > 0) {
	var _rr = (1 - rip) * 11 + 3;
	for (var _k = 0; _k < 12; _k++) {
		var _ra = _k * 30;
		draw_sprite_ext(spr_pixel_1x1, 0, bx + dcos(_ra) * _rr, by - dsin(_ra) * _rr,
			1, 1, 0, c_white, rip * .5);
	}
}
