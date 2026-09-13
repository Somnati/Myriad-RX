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

// ---- THE X CHIP: a panel's way out, beside the burger (2026-09-13) ----
// a small plate with a drawn x, in the burger's tones; it eases in with
// the panel and lights under the pointer like the burger does
if (xa > .01) {
	var _xr = __x_r();
	var _xc = hot_x ? c_white : rgb(190, 200, 225);
	var _xo = (1 - xa) * 6;   // it slides in from the burger's side
	var _x0 = _xr.x + _xo;
	draw_sprite_ext(spr_pixel_1x1, 0, _x0, _xr.y, _xr.w, _xr.h, 0, c_black, .75 * xa);
	draw_px_rect(_x0, _xr.y, _xr.w, _xr.h, _xc, (hot_x ? .7 : .35) * xa);
	var _cx = _x0 + _xr.w * .5, _cy = _xr.y + _xr.h * .5;
	draw_px_line(_cx - 3, _cy - 3, _cx + 3, _cy + 3, _xc, xa);
	draw_px_line(_cx - 3, _cy + 3, _cx + 3, _cy - 3, _xc, xa);
	if (xrip > 0) draw_px_rect(_x0 - 2, _xr.y - 2, _xr.w + 4, _xr.h + 4, c_white, xrip * .5 * xa);
}
