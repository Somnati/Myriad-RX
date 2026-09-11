/// syst_tapfx - THE TAP EFFECTS (his trial of seven, 2026-09-10, and his
/// verdict: "shockwave and glow are the only ones i like"). The other
/// five - the ripple and hold-heat warp pass, the raycast crater, the
/// counter spray, the crit slash - went with their two shaders; git has
/// them (7b1d32f) if a mood changes. The [fx] chip bottom-left of the
/// money room picks none / glow / shockwave / both through the house
/// pillbox; g.tap_fx remembers (settings.ini).
///
///   glow       DE's little glow at the tap - spr_vis_glow_soft in the
///              profit colour (gold on a crit), ten frames
///   shockwave  a one-cell ring expanding a cell a frame with a chromatic
///              split - red a cell left, blue a cell right - that closes
///              as it fades; a crit's ring runs wider
///
/// PERSISTENT, like the overcharger: obj_clicker is persistent and runs
/// its Create once, at boot, in the load room - a room-local instance
/// made there died with that room. It lives everywhere and does nothing
/// outside rm_clicker (__live).

depth = -95;
persistent = true;
__live = function() { return in_room(rm_clicker); };

// the shockwaves, five ways (his ask for variations, 2026-09-10):
//   chroma   the original - a one-cell ring with the red/blue split
//   mono     the ring alone, white, two cells thick, no split
//   double   two rings, the second a beat behind, both split
//   wave     the ring wobbles - its radius varies round the circle by
//            a three-lobe sine that turns as it grows
//   diamond  the ring is a diamond (city-block distance), the
//            visualiser's own geometry
fx_names = ["none", "glow", "shock chroma", "shock mono", "shock double", "shock wave", "shock diamond", "glow + chroma"];
if (!variable_global_exists("tap_fx")) g.tap_fx = 1;
// the pick, always a valid index: settings.ini loads AFTER this Create
// (boot, step 1) and a save from the seven-strong bench holds 4..7
__fx = function() {
	g.tap_fx = clamp(floor(g.tap_fx), 0, array_length(fx_names) - 1);
	return g.tap_fx;
};

glows  = [];   // { x, y, t, crit }
shocks = [];   // { x, y, r, crit }

pillbox_init();

// the [fx] chip, bottom-left above the tps readout
__chip_r = function() {
	draw_set_font(fnt);
	var _w = string_width("fx  " + fx_names[__fx()]) + 8;
	return { x : 3, y : room_height - 22, w : _w, h : 10 };
};
/// obj_clicker asks: is this press the chip's?
__consumes = function(_mx, _my) {
	var _r = __chip_r();
	return point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h);
};

/// @func fire(x, y, crit, n)
fire = function(_x, _y, _crit, _n) {
	var _f = __fx();
	if (_f == 1 || _f == 7)
		array_push(glows, { x : _x, y : _y, t : 0, crit : _crit });
	// kinds: 0 chroma, 1 mono, 2 double, 3 wave, 4 diamond
	if (_f >= 2 && _f <= 6) {
		var _k = _f - 2;
		array_push(shocks, { x : _x, y : _y, r : 1, crit : _crit, kind : _k, ph : random(360) });
		if (_k == 2) array_push(shocks, { x : _x, y : _y, r : -4, crit : _crit, kind : 2, ph : 0 });
	}
	if (_f == 7)
		array_push(shocks, { x : _x, y : _y, r : 1, crit : _crit, kind : 0, ph : 0 });
};
