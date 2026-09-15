/// syst_tapfx - THE TAP EFFECTS (his trial of seven, 2026-09-10, and his
/// verdict: "shockwave and glow are the only ones i like"). The other
/// five - the ripple and hold-heat warp pass, the raycast crater, the
/// counter spray, the crit slash - went with their two shaders; git has
/// them (7b1d32f) if a mood changes. THE PICK LIVES IN SETTINGS now
/// (settings > visuals > the tap, his call 2026-09-14 - the money
/// room's [fx] chip is gone); g.tap_fx remembers (settings.ini).
///
///   glow       a little glow at the tap - spr_vis_glow_soft in the
///              profit colour (gold on a crit), ten frames. (RX's own:
///              DE had NO effect at the tap point on a plain tap - only
///              the float and the motes; its crit had the pop below)
///   shockwave  a one-cell ring expanding a cell a frame with a chromatic
///              split - red a cell left, blue a cell right - that closes
///              as it fades; a crit's ring runs wider
///   crit pop   DE's obj_eff_expoblast, on a CRIT only, on top of
///              whichever effect is picked (g.tap_crit_pop, settings >
///              visuals): a white dot that opens into a ring and fades,
///              five frames held two steps each, scale 1..1.5, a little
///              darkened at random, up to ten cells off the tap. The
///              frames are DE's sprite verbatim, embedded (POP_FRAMES)
///              so nothing needs a reopen. DE threw shard sparks with
///              it; those stay out (his call, 2026-09-14: no sparks on
///              the tap).
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
// cells, all cheap, all in the pixel grammar the two keepers set. His
// cuts: checker, echo, dust and sparks (2026-09-10, git has them,
// 3ae7359), and the starburst - "the spark tap effect" (2026-09-14):
//   plus       four dashes flying out on the compass - a cross
//   x          the same four dashes on the diagonals
//   square     an expanding one-cell square outline, the visualiser's
//              own shape
//   implode    a ring that CLOSES on the tap and pops a white dot
//   lightning  a jagged one-cell bolt from the tap, a flash then gone
// THE INDEX IS THE SAVED PICK (settings.ini tap_fx): 0..4 hold their
// numbers; the cuts shift what sits past them, so a saved starburst
// reads as plus now - a settings tap to fix. tapfx_names() hands the
// list to settings.
fx_names = tapfx_names();
if (!variable_global_exists("tap_fx")) g.tap_fx = 2;
fxs = [];   // the second batch's live effects: { kind, x, y, t, crit, ... }
// the pick, always a valid index: settings.ini loads AFTER this Create
// (boot, step 1) and a save from a longer bench holds a higher number
__fx = function() {
	g.tap_fx = clamp(floor(g.tap_fx), 0, array_length(fx_names) - 1);
	return g.tap_fx;
};

glows  = [];   // { x, y, t, crit }
shocks = [];   // { x, y, r, crit }
pops   = [];   // { x, y, t, s, shade } - DE's crit pop

// DE's spr_expoblast, 16x16, origin (8, 8), five frames: "." clear, "#"
// white, a digit = a grey (digit x 26 of 255). Row-joined with "|".
POP_FRAMES = [
	"................|................|................|................|................|......##........|.....####.......|.....####.......|......##........|................|................|................|................|................|................|................",
	"................|................|................|................|......##........|.....####.......|....######......|....###..#......|.....##.........|......##........|................|................|................|................|................|................",
	"................|................|................|......##........|....######......|....######......|...####..##.....|...###....#.....|....##....#.....|....###.........|......###.......|................|................|................|................|................",
	"................|................|......###.......|....#######.....|...#########....|...#########....|..###########...|..######..###...|..#####....##...|...####.....#...|...#####........|....#####.......|......####......|................|................|................",
	"................|......2333......|....337###331...|....###...##3...|..3##.......#3..|..3#........#3..|.27#........774.|.3##........776.|.3#.........#4..|.3#.............|..3#............|..3#............|..13##77#.......|....33774.......|......464.......|................",
];
// decoded once: per frame, a flat list of [dx, dy, grey 0..255]
pop_px = [];
for (var _f = 0; _f < array_length(POP_FRAMES); _f++) {
	var _rows = string_split(POP_FRAMES[_f], "|");
	var _list = [];
	for (var _ry = 0; _ry < 16; _ry++) {
		var _row = _rows[_ry];
		for (var _rx = 0; _rx < 16; _rx++) {
			var _ch = string_char_at(_row, _rx + 1);
			if (_ch == ".") continue;
			var _v = (_ch == "#") ? 255 : real(_ch) * 26;
			array_push(_list, [_rx - 8, _ry - 8, _v]);
		}
	}
	array_push(pop_px, _list);
}

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
		case 5:   // plus: four dashes, longer, on the compass
			array_push(fxs, { kind : "star", x : _x, y : _y, t : 0, crit : _crit, col : _pc, n : 4, a0 : 0 });
			break;
		case 6:   // x: the plus turned onto the diagonals
			array_push(fxs, { kind : "star", x : _x, y : _y, t : 0, crit : _crit, col : _pc, n : 4, a0 : 45 });
			break;
		case 7:   // square
			array_push(fxs, { kind : "square", x : _x, y : _y, t : 0, crit : _crit, col : _pc, r : 1 });
			break;
		case 8:   // implode
			array_push(fxs, { kind : "implode", x : _x, y : _y, t : 0, crit : _crit, col : _pc, r : (_crit ? 16 : 12) });
			break;
		case 9: { // lightning: a bolt of four bends, rolled once
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
	}

	// ---- DE's crit pop, on top of the pick (create_click_effects: the
	// expoblast within ten px of the tap, scale 1..1.5, blend white
	// darkened by up to a fifth) ----
	if (_crit && (variable_global_exists("tap_crit_pop") ? g.tap_crit_pop : true)) {
		var _pd = random(360), _pr = random(10);
		array_push(pops, { x : floor(_x + lengthdir_x(_pr, _pd)), y : floor(_y + lengthdir_y(_pr, _pd)),
		                   t : 0, s : random_range(1, 1.5), shade : 1 - random_range(0, .2) });
	}
};
