/// syst_tapfx - THE TAP EFFECTS BENCH (his ask, 2026-09-10: "do each of
/// those and a drop down box on the clicker screen so i can test each
/// one out"). Spawned by obj_clicker in the money room. tap_fire hands
/// every performed tap to fire() (tapfx_fire); the [fx] chip bottom-left
/// opens the house pillbox and g.tap_fx remembers the pick (settings.ini).
///
/// THE SEVEN, and what each is made of:
///   1 glow          DE's little glow at the tap - spr_vis_glow_soft in
///                   the profit colour, ten frames
///   2 ripple        a crest running out through the room under the tap
///                   (sh_tapwarp: the application surface captured and
///                   redrawn with a whole-cell radial push + a lift)
///   3 crater        a raycast dent in the table plane, lit by the dice's
///                   light, relaxing over fourteen frames (sh_tapcrater)
///   4 shockwave     a one-cell ring expanding a cell a frame with a
///                   chromatic split - red a cell left, blue a cell right
///                   - that closes as it fades
///   5 counter spray the tap point stays quiet; the profit counter throws
///                   sparks in the profit colour, more on a crit
///   6 hold heat     holding builds a glow at the finger, profit colour
///                   toward white with the overcharger, and a pixel
///                   shimmer around it (sh_tapwarp's haze)
///   7 crit slash    on a crit only: one diagonal light streak through the
///                   tap, six frames
///
/// THE WARP PASS (2, 6): at this depth (-95) everything under the tap -
/// the visualiser, the dial column, the motes - has drawn; the app
/// surface is copied to a scratch surface and the affected box drawn
/// back through sh_tapwarp. The header, floats and pointer come after
/// and stay put. Surfaces are volatile; the scratch is rebuilt whenever
/// it is missing or the wrong size.

depth = -95;

fx_names = ["none", "glow (DE)", "ripple", "crater", "shockwave", "counter spray", "hold heat", "crit slash"];
if (!variable_global_exists("tap_fx")) g.tap_fx = 1;

glows   = [];   // { x, y, t, crit }
rings   = [];   // ripple: { x, y, r, amp }
craters = [];   // { x, y, d }
shocks  = [];   // { x, y, r, crit }
slashes = [];   // { x, y, ang, t }
heat    = 0;    // hold heat, 0..1
hx = 0; hy = 0; // where the heat sits (the finger, eased)
scratch = -1;
tm = 0;

pillbox_init();

// the [fx] chip, bottom-left above the tps readout
__chip_r = function() {
	draw_set_font(fnt);
	var _w = string_width("fx  " + fx_names[g.tap_fx]) + 8;
	return { x : 3, y : room_height - 22, w : _w, h : 10 };
};
/// obj_clicker asks: is this press the chip's?
__consumes = function(_mx, _my) {
	var _r = __chip_r();
	return point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h);
};

/// @func fire(x, y, crit, n)
fire = function(_x, _y, _crit, _n) {
	switch (g.tap_fx) {
		case 1: array_push(glows, { x : _x, y : _y, t : 0, crit : _crit }); break;
		case 2:
			if (array_length(rings) >= 8) array_delete(rings, 0, 1);
			array_push(rings, { x : _x, y : _y, r : 2, amp : _crit ? 3 : 2 });
			break;
		case 3: array_push(craters, { x : _x, y : _y, d : _crit ? 4 : 2.6 }); break;
		case 4: array_push(shocks, { x : _x, y : _y, r : 1, crit : _crit }); break;
		case 5:
			// the counter, where the motes land (bezier_bits' default seat)
			spark_burst(24, 12, _crit ? 12 : 4, _crit ? c_gold : g.profit_color);
			break;
		case 7:
			if (_crit) array_push(slashes, { x : _x, y : _y, ang : 45 + random_range(-25, 25), t : 0 });
			break;
	}
};
