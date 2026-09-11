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

// the shockwaves (his verdict on the five, 2026-09-10: chroma and mono
// are the keepers, mono the default; smaller and faster than the trial):
//   mono     the ring alone, white, two cells thick, no split
//   chroma   a one-cell ring with the red/blue split closing as it fades
// ...and the second batch (his ask, 2026-09-10: "more to test"), all
// cells, all cheap, all in the pixel grammar the two keepers set:
//   sparks     DE's shard sparks (the tile's, the dial's) thrown from
//              the tap in the profit colour - the spark pool
//   starburst  eight dashes flying out on the compass and diagonals,
//              the fighting-game hit star
//   plus       four dashes, the compass only, longer - a cross
//   square     an expanding one-cell square outline, the visualiser's
//              own shape
//   implode    a ring that CLOSES on the tap and pops a white dot
//   echo       three thin rings, three frames apart
//   dust       five slow puffs drifting out and dying
//   lightning  a jagged one-cell bolt from the tap, a flash then gone
//   checker    a 5x5 checkerboard at the tap whose cells drop out one
//              by one
fx_names = ["none", "glow", "shock mono", "shock chroma", "glow + mono",
            "sparks", "starburst", "plus", "square", "implode", "echo", "dust", "lightning", "checker"];
if (!variable_global_exists("tap_fx")) g.tap_fx = 2;
fxs = [];   // the second batch's live effects: { kind, x, y, t, crit, ... }
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
	if (_f == 1 || _f == 4)
		array_push(glows, { x : _x, y : _y, t : 0, crit : _crit });
	// kinds: 1 mono, 0 chroma
	if (_f == 2 || _f == 4) array_push(shocks, { x : _x, y : _y, r : 1, crit : _crit, kind : 1 });
	if (_f == 3)            array_push(shocks, { x : _x, y : _y, r : 1, crit : _crit, kind : 0 });

	// ---- the second batch ----
	var _pc = _crit ? c_gold : g.profit_color;
	switch (_f) {
		case 5:   // sparks: the pool does the flying
			spark_burst(_x, _y, _crit ? 12 : 6, _pc);
			break;
		case 6:   // starburst: eight dashes
			array_push(fxs, { kind : "star", x : _x, y : _y, t : 0, crit : _crit, col : _pc, n : 8, a0 : 0 });
			break;
		case 7:   // plus: four, longer
			array_push(fxs, { kind : "star", x : _x, y : _y, t : 0, crit : _crit, col : _pc, n : 4, a0 : 0 });
			break;
		case 8:   // square
			array_push(fxs, { kind : "square", x : _x, y : _y, t : 0, crit : _crit, col : _pc, r : 1 });
			break;
		case 9:   // implode
			array_push(fxs, { kind : "implode", x : _x, y : _y, t : 0, crit : _crit, col : _pc, r : (_crit ? 16 : 12) });
			break;
		case 10:  // echo: three rings, three frames apart
			for (var _k = 0; _k < 3; _k++)
				array_push(fxs, { kind : "echo", x : _x, y : _y, t : 0, crit : _crit, col : _pc, r : 1 - _k * 4.8 });
			break;
		case 11: { // dust: five puffs with their own headings
			var _pf = [];
			repeat (5) array_push(_pf, { a : random(360), s : random_range(.5, 1.0), d : 0 });
			array_push(fxs, { kind : "dust", x : _x, y : _y, t : 0, crit : _crit, col : _pc, puffs : _pf });
			break;
		}
		case 12: { // lightning: a bolt of four bends, rolled once
			var _pts = [];
			var _bx = _x, _by = _y;
			var _ba = random(360);
			array_push(_pts, _bx, _by);
			repeat (_crit ? 6 : 4) {
				var _seg = random_range(3, 6);
				var _sa = _ba + random_range(-35, 35);
				_bx += lengthdir_x(_seg, _sa); _by += lengthdir_y(_seg, _sa);
				array_push(_pts, _bx, _by);
			}
			array_push(fxs, { kind : "bolt", x : _x, y : _y, t : 0, crit : _crit, col : _pc, pts : _pts });
			break;
		}
		case 13: { // checker: 5x5, each cell with its own death frame
			var _dt = array_create(25);
			for (var _k = 0; _k < 25; _k++) _dt[_k] = random_range(4, 11);
			array_push(fxs, { kind : "checker", x : _x, y : _y, t : 0, crit : _crit, col : _pc, die : _dt });
			break;
		}
	}
};
