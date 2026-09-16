/// rm_titlescreen - the landscape title. continue / new game / load /
/// quit; SETTINGS rides the gear in the bottom-right corner, the same
/// one the game uses, so it is not also a row here. g.game_started stays
/// false until continue or new game flips it (obj_ui_menu2 gates on the
/// flag, so the burger can't exist here or in the rooms reachable from
/// here). boot auto-loads slot 0 behind rm_gameload, so CONTINUE just
/// proceeds with the loaded state; NEW GAME opens rm_saves in new-game
/// mode (slot picker > overwrite confirm > difficulty) and game_reset()
/// rebuilds the run in memory - no game_restart.
///
/// ⚖️ THE OVERHAUL (2026-09-08, his ask: "a new sleek UI design... give
/// me a cool background"). Two decisions carry it.
///
/// 1. THE BACKGROUND IS THE GAME'S OWN PICTURE, not another starfield.
///    A drifting lattice with cells lighting in the rarity-ladder
///    colours is the visualiser at rest - the one image nothing else
///    looks like, and the thing the whole game is about. The old
///    three-layer parallax starfield was competent and could have
///    fronted any space game; that was what was wrong with it.
///
/// 2. THE LAYOUT IS LEFT-ALIGNED AND ASYMMETRIC. A centred stack of
///    five identical pills reads as a placeholder however well it is
///    drawn. The name anchors a column behind an accent rule, the menu
///    hangs under it as plain text with a bar that slides to whatever
///    you are pointing at, and the save card balances it from the right
///    instead of floating over the buttons. Nothing is boxed - the
///    chrome was doing work the type should be doing.

save_file = save_slot_path(0);
has_save = file_exists(save_file);
// ANY profile with a run (his ask, 2026-09-13: a fresh install skips the
// profile picker - new game goes straight to the difficulty list)
__any_save = function() {
	for (var _p = 0; _p < 4; _p++) if (file_exists(save_slot_path(0, _p))) return true;
	return false;
};
any_save = __any_save();

// WHAT CONTINUE IS CONTINUING (2026-09-07, his ask). Boot already
// loaded slot 0 behind rm_gameload, so this is only a peek for the
// card: who the run belongs to, how far it got, how long ago you left
// it. Read from the FILE rather than the globals - the file is the
// profile's real identity, and it cannot disagree with what will load.
cont = save_slot_info(save_file);

// ---- layout ----
lm     = 30;      // the left margin everything hangs off
rule_x = lm - 11; // the accent rule / hover bar column
// CONTINUE ONLY WHEN THERE IS SOMETHING TO CONTINUE (his ask, 2026-09-13:
// hidden, not greyed) - the list is rebuilt when a save appears or goes
__items = function() { return has_save ? ["continue", "new game", "load", "quit"] : ["new game", "load", "quit"]; };
items  = __items();
row_y0 = 142;
row_p  = 21;      // row pitch
row_h  = 13;      // hit height
row_w  = 128;     // hit width

// a slow clock for the field drift and the title's breath. Starts
// somewhere along its own cycle, so the breaths and the motes are
// mid-thought on the first frame rather than all at phase zero.
tt = random(100000);

// hover EASE per row, 0..1. The old screen ran a damped spring per
// button to bounce its chrome; there is no chrome to bounce now, so
// this is a plain ease driving three things at once - the label
// brightens, it slides right a few pixels, and the accent bar grows
// beside it. ONE number, so they cannot disagree about how hovered a
// row is, and rest is genuinely still rather than nearly still.
hov = array_create(array_length(items), 0);

// ---- the drift ----
// ⚖️ THE LATTICE IS GONE (his verdict on the first attempt: "the
// background sucks"). Drawing the visualiser's grid literally gave the
// screen graph paper - a regular mesh reads as a debug overlay however
// dim it is, because regularity is what the eye locks onto first.
//
// The idea was right and the execution was too literal. This is the
// game's SHAPE without its ruler: a few large soft blocks, out of
// focus, drifting up-right at different speeds and breathing through
// the rarity ladder.
//
// ⚖️ ROLLED PER BOOT, NOT BAKED (his report, 2026-09-10: "the squares
// are not random and are in the same spots each time i boot the game
// up"). The first version was a hand-written table of eight - readable,
// and identical every launch, which is the one thing a title screen
// must not be: the second boot already looked like a wallpaper. Now
// the field is dealt fresh from the ambient stream (setgame's
// randomize() ran in the boot room), and ONE number per block - its
// DEPTH - decides everything else, so the roll cannot produce a big
// fast bright block or a small slow dim one. Far is big, slow, dim and
// well out of focus; near is small, quick, bright and sharper. That
// coherence is what the hand table was really encoding, and deriving
// it means a hundred random fields all read as the same place.
//
//   d      depth, 0 far .. 1 near - the one roll the rest derive from
//   x0/y0  start, as a fraction of the wrap span. Dealt with a minimum
//          spacing, so two blocks never spawn as one lump
//   size   px. Big: this is atmosphere, not content
//   spd    px per 60hz step. The SPREAD is the depth cue - a field
//          moving at one speed is a texture, not a distance
//   tier   which rung of the rarity ladder it wears. The ladder is
//          SHUFFLED and dealt round-robin, so every colour shows once
//          before any repeats - a field of three blues is a bad roll
//          the eye reads as a bug
//   br/ph  its own breath rate and phase, so the set never pulses
//          together
//   dim    the far ones do not shout
blk_h = [];
var _nb = irandom_range(8, 11);
var _rungs = [2, 3, 4, 5, 6, 7, 8];
for (var _s = array_length(_rungs) - 1; _s > 0; _s--) {   // Fisher-Yates
	var _r = irandom(_s);
	var _tmp = _rungs[_s]; _rungs[_s] = _rungs[_r]; _rungs[_r] = _tmp;
}
for (var _i = 0; _i < _nb; _i++) {
	var _d = random(1);
	// a place of its own: up to a dozen tries for a spot at least .24
	// of the span from every block already dealt, then take the last
	var _px = 0, _py = 0;
	for (var _try = 0; _try < 12; _try++) {
		_px = random(1); _py = random(1);
		var _clear = true;
		for (var _j = 0; _j < array_length(blk_h); _j++)
			if (point_distance(_px, _py, blk_h[_j].x0, blk_h[_j].y0) < .24) _clear = false;
		if (_clear) break;
	}
	array_push(blk_h, {
		d    : _d,
		x0   : _px, y0 : _py,
		size : round(lerp(98, 34, _d) * random_range(.85, 1.15)),
		spd  : lerp(.040, .165, _d) * random_range(.9, 1.1),
		tier : _rungs[_i mod array_length(_rungs)],
		br   : lerp(.14, .36, _d) * random_range(.85, 1.15),
		ph   : random(360),
		dim  : lerp(.68, 1, _d),
	});
}
// far to near, so the near ones paint OVER the far ones and the
// overlaps agree with the speeds about which block is in front
array_sort(blk_h, function(_a, _b) { return sign(_a.d - _b.d); });

// ---- the motes ----
// dealt the same way, for the same reason: each one's lane, rise and
// two flicker phases. They used to be hashed off their index, which is
// a fixed field with extra steps.
mote = [];

// ---- THE STARFIELD (his lean, 2026-09-13, then his shape: "the camera
// moving through a starfield with stars moving towards the camera") -
// settings > visuals > title backdrop. Points in a box ahead of the
// camera, projected from the centre; each step they come nearer, spread
// outward and brighten, and one that passes the camera is reborn far.
// Slow: a title, not a jump. A few carry the game's aqua and gold ----
star = [];
for (var _i = 0; _i < 170; _i++) {
	array_push(star, { x : random_range(-1, 1), y : random_range(-1, 1), z : random_range(.05, 1),
		tw : .6 + random(2.2), ph : random(360),
		col : (random(1) < .18) ? merge_colour(c_white, c_aqua, .5) : ((random(1) < .12) ? merge_colour(c_white, c_gold, .45) : c_white) });
}
repeat (22) array_push(mote, {
	hx : random(1), hs : random_range(.10, .32),
	p1 : random(360), p2 : random(360), y0 : random(400),
});

// banding fix (2026-07-09, his report): the backdrop gradient rides
// the house temporal IGN dither - the same shader the starmap fog uses
dith_u_time = shader_get_uniform(sh_fog_dither, "u_time");

// ---- THE GLOW PASS (his question, 2026-09-10: "why not use the
// internal bloom shader instead of sprites") ----
// The field draws through a proxy at depth 100 (the name at 90) and
// this layer sits at 50, so GameMaker's _effect_glow - the visualiser's
// own "glow" layer, same effect, same parameter names - blooms the
// blocks and the wordmark and nothing above it: the gradient (40, see
// __draw_grad), the menu and the save card stay crisp. Built at runtime
// the way ui_blur_tick builds menu_blur, so the room file stays as it
// is. Radius and intensity are the title's own (its blocks are
// atmosphere, far dimmer than the money room's), but the pass honours
// the visualiser-glow setting's OFF: a player who switched that pass
// off for their machine does not get one here.
if (!layer_exists("title_glow")) {
	var _gl = layer_create(50, "title_glow");
	var _gf = fx_create("_effect_glow");
	fx_set_parameter(_gf, "g_GlowRadius", 30);
	fx_set_parameter(_gf, "g_GlowQuality", 10);
	fx_set_parameter(_gf, "g_GlowIntensity", .6);
	fx_set_parameter(_gf, "g_GlowGamma", 1.6);
	fx_set_parameter(_gf, "g_GlowAlpha", 1);
	layer_set_fx(_gl, _gf);
}
layer_set_visible("title_glow", !variable_global_exists("vis_glow") || g.vis_glow > 0);

// THE FIELD'S DRAW SLOT: backdrop, drift, motes - everything the glow
// should touch - at depth 100, under the layer. obj_draw_proxy exists
// for exactly this: one instance, two depths.
// ---- TRACE (his ask, 2026-09-14: "scrap the nebula... procedural
// shapes... abstract... something neat to look at"). A HARMONOGRAPH: a
// pen driven by two damped sinusoids on each axis - x = A1 sin(f1 t + p1)
// e^(-d1 t) + A2 sin(f2 t + p2) e^(-d2 t), y likewise with its own
// frequencies - the Victorian drawing machine whose figures are the
// Lissajous family with the spiral-in of the damping. The pen leaves a
// trail of pixels that fade with age and drift through two tier colours;
// when a figure has damped to nothing the pen re-rolls and starts the
// next one over the ghost of the last. Drawn under the glow pass with
// the field, so the fresh line blooms and the old one smoulders.
// Nothing else in the game draws a curve; that is the point ----
tr_pts = [];      // the trail, oldest first: { x, y }
tr_max = 900;     // its length in points
tr_t   = 0;       // the pen's time within the figure
tr_p   = undefined;
__trace_roll = function() {
	// frequencies near small-integer ratios make closed, readable figures;
	// the offsets keep two figures from ever repeating exactly
	var _r1 = choose(1, 2, 3), _r2 = choose(2, 3, 4, 5);
	tr_p = {
		ax1 : random_range(.55, .8), ax2 : random_range(.15, .35),
		ay1 : random_range(.55, .8), ay2 : random_range(.15, .35),
		fx1 : _r1 + random_range(-.02, .02), fx2 : _r2 * .5 + random_range(-.02, .02),
		fy1 : _r2 + random_range(-.02, .02), fy2 : _r1 * .5 + random_range(-.02, .02),
		px1 : random(360), px2 : random(360), py1 : random(360), py2 : random(360),
		d1  : random_range(.008, .016), d2 : random_range(.004, .012),
		ca  : vis_tier_color(irandom(9)), cb : vis_tier_color(irandom(9)),
		spd : random_range(.9, 1.3),
	};
	tr_t = 0;
};
__trace_roll();
__draw_trace = function() {
	var _p = tr_p;
	var _cx = room_width * .5, _cy = room_height * .5;
	var _rx = room_width * .42, _ry = room_height * .42;
	// the pen advances a few points a frame, so the line is continuous at
	// any speed; the damping is the figure's clock
	repeat (3) {
		tr_t += .8 * _p.spd * delta;
		var _e1 = exp(-_p.d1 * tr_t), _e2 = exp(-_p.d2 * tr_t);
		var _x = _cx + _rx * (_p.ax1 * dsin(_p.fx1 * tr_t + _p.px1) * _e1 + _p.ax2 * dsin(_p.fx2 * tr_t + _p.px2) * _e2);
		var _y = _cy + _ry * (_p.ay1 * dsin(_p.fy1 * tr_t + _p.py1) * _e1 + _p.ay2 * dsin(_p.fy2 * tr_t + _p.py2) * _e2);
		array_push(tr_pts, { x : _x, y : _y });
		if (array_length(tr_pts) > tr_max) array_delete(tr_pts, 0, array_length(tr_pts) - tr_max);
		// the figure has spiralled to a dot: the next one
		if (_e1 < .06 && _e2 < .06) __trace_roll();
	}
	var _n = array_length(tr_pts);
	for (var _i = 0; _i < _n; _i++) {
		var _q = tr_pts[_i];
		var _age = 1 - _i / _n;                 // 1 oldest .. 0 the pen
		var _a = .05 + .45 * (1 - _age) * (1 - _age);
		var _c = merge_colour(_p.cb, _p.ca, 1 - _age);
		var _sz = (_age < .04) ? 2 : 1;
		draw_sprite_ext(spr_pixel_1x1, 0, floor(_q.x), floor(_q.y), _sz, _sz, 0, _c, _a);
	}
};

// ---- THE FORGE (his ask, 2026-09-14: "a thing where you can view a dial
// and it takes you to a room where there is a larger version of a dial
// with lots of fancy particles... i love the way this looks but never
// figured out how to implement it naturally"). That is DE's rm_genforge -
// the gen forge, reachable only from its debug menu with a dial's index
// (g.forge_id) - ported TERM FOR TERM as a backdrop, a random dial's
// colour in place of the viewed dial's. DE's room was 144x296 portrait
// with the cell at its centre; the panel sits centred here (fg.px/py is
// its origin), the bands span its width, the motes roam the whole title.
//   the cell     obj_gf_slot_cell in its "claimed" state: a disc whose
//                size is a spring (set_wiggle .08/.9) chasing 15 x fill,
//                fill trickling toward .3..1 with the dial's CYCLE (a
//                sawtooth here, the cycle simulated), under a spr_glow_sw
//                halo scaled by _circ_perc = size / 11.25 and turned by a
//                random angle every frame; the disc flickers while it is
//                small (glow_alpha = random(lerp(1, -.5, perc)))
//   the motes    obj_gf_eff: one in fourteen frames a mote is born at a
//                random point, homing on the cell at random(2) px a frame,
//                its size a spring decaying (trickle 30) to nothing, a
//                circle + a .2 halo; 5% carry the BIG GLOW - a room-wide
//                horizontal spr_glow_sw streak (20 x .1 of 144 px) in the
//                complementary colour pulsing on a sawtooth (rot)
//   the sparks   obj_eff_shardspark: every mote sheds one 6% of frames -
//                a 2px square easing to .65..1, blown on a wind toward
//                the cell whose direction random-walks (wind_dir_change
//                relaxing to random(-3, 3) over a random(.9) - DE's
//                overshoot included), living 1..3 s, faster with a crowd
// The bands / name / level (obj_gf_titleback), the stat bars and the
// density bar (the cell's normal Draw) are the forge's UI, not its look -
// left out (his call, 2026-09-15: "just the dial in the center and its
// particle behavior"). The motes are born ANYWHERE on the title (his
// call, 2026-09-16: "our game is on a larger screen... DE did it its way
// cause its on a mobile aspect ratio"); their rates ride fg.area - the
// title's area over DE's 144x296, ~3x - so the crowd is as dense as
// DE's, while the big glows (room-wide streaks) keep DE's rate per
// second. THE PIXELS (his ask, the same day: "give it a pixel shader so
// its pixelated"): the whole forge draws into a surface FORGE_PIX times
// smaller than the room and comes back point-sampled - one exact texel
// per block, pixel_snap's law - so discs, halos and sparks are in chunky
// pixels like DE's 144-wide room; 1 = the room's own grid (the fonts'),
// which is DE's texels-per-dial exactly. The whole thing draws ABOVE the
// glow pass (a proxy at 48): DE lit it with its own additive halos, and
// a bloom on top of those is a different picture ----
FORGE_PIX = 1;   // room pixels a block (2 for chunkier than the fonts)
fg = undefined;
__forge_roll = function() {
	var _cx = floor((room_width - 144) * .5), _cy = floor(room_height * .5) - 144;   // DE's 144x296 room, its cell (72,144) on the title's centre
	var _col = dial_color(irandom(12));                    // a random dial, a..m
	fg = {
		px : _cx, py : _cy,
		x : _cx + 72, y : _cy + 144,       // the cell (DE: instance at 72,144)
		c : _col,
		// A COMPLETED DIAL (his call, 2026-09-16): the cycle builds the disc up
		// smoothly and the cycle's end is the burst - DE's claimed cell under
		// prod_dials' GENFORGE block (a sawtooth here, the cycle simulated)
		cycle : random(1), cycle_len : random_range(150, 300),
		fill : 0, alpha : 0, size : 0, chg : 1, rec : .08, dmp : .9,   // (chg 1: DE's set_wiggle starts every spring at speed 1)
		area : (room_width * room_height) / (144 * 296),   // the title over DE's room: the mote rates ride it, the big-glow chance divides by it
		circ : 0, glow : 0, wdc : random_range(-4, 4), xos : 0, yos : 0,
		effs : [], sparks : [], rings : [],
		rt : 0, cr : random(360), ga : 0,   // THE 60 Hz TICK: the halo's angle, the disc's flicker, the jitters and the spawn rolls run on it, not every monitor frame
	};
};
__forge_roll();
/// the complementary colour (DE's colour_set_comp: the hue turned half way)
__forge_comp = function(_c) {
	return make_colour_hsv((c_hue(_c) + 128) mod 256, c_sat(_c), c_val(_c));
};
/// a mote (DE's obj_gf_eff Create): away = move_away (pushed from the cell, else pulled to it)
__forge_mote = function(_x, _y, _away, _spd, _max, _decay, _big) {
	return {
		x : _x, y : _y, away : _away,
		size : 0, chg : 1, rec : .08 + random_range(-.02, .02), dmp : .9 + random_range(.1, -.1),   // chg 1 (DE's set_wiggle): the mote POPS in - past its 0..2 px target to several px, then springs back - the spawn size he saw in DE (2026-09-16)
		max_size : _max, decay : _decay, alpha : 1, spd : _spd, part_chance : 1,
		big_glow : _big, glow_scale : random(1), rot : 0, rot_spd : random(.07), glow_alpha : 0,
		j1 : random_range(.95, 1.05), j2 : random_range(-.05, .05), j3 : random_range(-.05, .05),
	};
};
/// DE's do_wiggle on a struct: a spring toward `des` (recovery + damper)
__forge_wiggle = function(_s, _des) {
	_s.chg += ((_des - _s.size) * _s.rec) * delta;
	_s.chg *= power(_s.dmp, delta);
	_s.chg = clamp(_s.chg, -10, 10);
	_s.size += _s.chg;
	if (_s.size < 0) { _s.size = 0; _s.chg /= 2; }
	if (delta > 4) { _s.size = 0; _s.chg = 0; }
	if (_s.size < 0) { _s.size = 0; _s.chg = 0; }
};
__forge_step = function() {
	var _f = fg;
	// ---- THE 60 Hz TICK (2026-09-16): DE rolled its randoms every frame at
	// 60 fps; here they roll on a 60 Hz tick and hold between, so a 144 Hz
	// monitor gets DE's shimmer, DE's spawn rate and DE's jitter, not 2.4x ----
	_f.rt += delta;
	var _tick = false;
	while (_f.rt >= 1) { _f.rt -= 1; _tick = true; }
	if (_tick) {
		_f.cr = random(360);
		_f.ga = random(lerp(1, -.5, _f.circ));
		for (var _ti = 0; _ti < array_length(_f.effs); _ti++) { var _te = _f.effs[_ti]; _te.j1 = random_range(.95, 1.05); _te.j2 = random_range(-.05, .05); _te.j3 = random_range(-.05, .05); }
	}
	// ---- the dial's cycle, simulated (DE read g.cycle[s]) ----
	_f.cycle += delta / _f.cycle_len;
	if (_f.cycle >= 1) {
		_f.cycle -= 1;
		// THE BURST (prod_dials' GENFORGE block, on the cycle's completion): a
		// kick to the cell's spring (push_wiggle 2), a RING pushing out of it
		// (obj_gf_eff_ring), and create_pull - four to ten motes born anywhere
		// and PULLED in (obj_gf_eff's own Create: spd random(3), decay by size)
		_f.chg += 2;
		array_push(_f.rings, { size : 0, spd : 3.5, decay : random_range(15, 30), alpha : 1 });
		repeat (round(choose(2, 3, 4, 5) * 2 * _f.area)) {
			var _sp0 = random(1);
			array_push(_f.effs, __forge_mote(random(room_width), random(room_height), false, random(3), random(2), lerp(60, 15, _sp0), roll_perc(5 / _f.area)));
		}
	}
	// ---- obj_gf_slot_cell, claimed: the fill and the alpha ride the cycle (a smooth build-up, then back down after the burst) ----
	_f.fill  = trickle(_f.fill, lerp(.3, 1, _f.cycle), 5);
	_f.alpha = lerp(.3, 1, _f.cycle);
	var _max = (30 * .5) * _f.fill;                 // created: (sprite_width / 2) x fill
	__forge_wiggle(_f, _max);
	_f.circ = _f.size / ((30 * .75) * .5);
	_f.xos = 0; _f.yos = 0;
	// the motes pulled in (dens_perc 1 for a claimed cell: roll_perc(7) a frame at 60 - a tick here; x the area, born anywhere)
	if (_tick && roll_perc(7 * _f.area)) {
		var _m = __forge_mote(random(room_width), random(room_height), false, random(2), random(2), 30, roll_perc(5 / _f.area));
		_m.part_chance = 2;
		array_push(_f.effs, _m);
	}
	_f.glow = clamp(_f.glow - .05 * delta, 0, 1);
	_f.alpha = trickle(_f.alpha, 1, 3.5);
	// ---- obj_gf_eff ----
	for (var _i = array_length(_f.effs) - 1; _i >= 0; _i--) {
		var _e = _f.effs[_i];
		__forge_wiggle(_e, _e.max_size);
		_e.max_size = trickle(_e.max_size, 0, _e.decay);
		_e.alpha    = trickle(_e.alpha, 0, _e.decay);
		if (_e.max_size <= 0) { array_delete(_f.effs, _i, 1); continue; }
		if (roll_perc(3 * _e.part_chance * delta)) {
			// a shard spark on the wind toward the cell (DE's Create, its
			// xspd/yspd zeroed by the mote - the wind is the whole motion)
			var _hp = 60 * random_range(1, 1.5);
			if (roll_perc(50)) _hp = 60 * random_range(1.5, 2);
			if (roll_perc(7))  _hp = 60 * random_range(2, 3);
			array_push(_f.sparks, {
				x : _e.x, y : _e.y,
				wind_dir : point_direction(_e.x, _e.y, _f.x, _f.y) - ((_e[$ "away"] ?? false) ? 180 : 0), wind_spd : random_range(.2, .5),   // (a pushed mote's sparks blow away too)
				wdc : _f.wdc, wind_trick : max(.05, random(.9)),   // (DE's random(.9); the floor keeps the relax step finite)
				hp : _hp, scale : 2, scale_min : random_range(.65, 1),
				col : make_colour_hsv(c_hue(_f.c), c_sat(_f.c), 255),
			});
		}
		var _d = point_direction(_e.x, _e.y, _f.x, _f.y) - ((_e[$ "away"] ?? false) ? 180 : 0);   // move_away: pushed from the cell, else pulled to it
		_e.x += lengthdir_x(_e.spd * delta, _d);
		_e.y += lengthdir_y(_e.spd * delta, _d);
		if (!(_e[$ "away"] ?? false) && point_distance(_e.x, _e.y, _f.x, _f.y) < 144 / 4) { array_delete(_f.effs, _i, 1); continue; }
		_e.rot += _e.rot_spd * delta;
		if (_e.rot > 1) _e.rot = -1;
		_e.glow_alpha = _e.rot;
	}
	// ---- obj_gf_eff_ring: out from the cell, fading ----
	for (var _i = array_length(_f.rings) - 1; _i >= 0; _i--) {
		var _r = _f.rings[_i];
		_r.size = max(_r.size + _r.spd * delta, _f.size);
		_r.alpha = trickle(_r.alpha, 0, _r.decay);
		if (_r.alpha <= 0) array_delete(_f.rings, _i, 1);
	}
	// ---- obj_eff_shardspark ----
	var _ns = array_length(_f.sparks);
	for (var _i = _ns - 1; _i >= 0; _i--) {
		var _s = _f.sparks[_i];
		_s.scale = _s.scale + ((_s.scale_min - _s.scale) / (5 / delta));
		_s.wdc = _s.wdc + ((random_range(-3, 3) - _s.wdc) / (_s.wind_trick / delta));
		_s.wind_dir += _s.wdc * delta;
		_s.x += lengthdir_x(_s.wind_spd * delta, _s.wind_dir);
		_s.y += lengthdir_y(_s.wind_spd * delta, _s.wind_dir);
		_s.hp -= (1 * delta) * (lerp(1, 4, _ns / 200));
		if (_s.hp <= 0) array_delete(_f.sparks, _i, 1);
	}
};
__draw_forge = function() {
	__forge_step();
	var _f = fg;
	var _c = _f.c;
	// ---- THE PIXELS: everything below lands in a surface FORGE_PIX times
	// smaller than the room (the world matrix scales the room's coordinates
	// down into it), then comes back up point-sampled - one exact texel per
	// block, never averaged (pixel_snap's law). The surface is volatile like
	// every surface: checked each frame, remade at the room's size ----
	var _cell = max(1, FORGE_PIX);
	var _sw = ceil(room_width / _cell), _sh = ceil(room_height / _cell);
	if (!variable_global_exists("title_forge_surf") || !surface_exists(g.title_forge_surf)
		|| surface_get_width(g.title_forge_surf) != _sw || surface_get_height(g.title_forge_surf) != _sh) {
		if (variable_global_exists("title_forge_surf") && surface_exists(g.title_forge_surf)) surface_free(g.title_forge_surf);
		g.title_forge_surf = surface_create(_sw, _sh);
	}
	surface_set_target(g.title_forge_surf);
	draw_clear_alpha(c_black, 0);
	if (_cell != 1) matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 1 / _cell, 1 / _cell, 1));
	// ---- everything par_ambi_draw drew: additive ----
	// (DE set draw_set_circle_precision(48) every frame - syst_roomtrans'
	// Draw End, global gpu state - so its discs were round; GM's default 24
	// made the cell a fifteen-pixel polygon here. 48 for the forge, put back after)
	draw_set_circle_precision(48);
	gpu_set_blendmode(bm_add);
	// the cell (obj_gf_slot_cell's Draw Begin, claimed: no outline, no black disc)
	var _cr = _f.cr;                                 // (held between 60 Hz ticks - __forge_step)
	var _ca = _f.alpha, _cp = _f.circ;
	var _fx = _f.x + _f.xos, _fy = _f.y + _f.yos;    // (the shake as it nears full)
	draw_sprite_ext(spr_glow_sw, 0, _fx, _fy, _cp, _cp, _cr, _c, lerp(0, .6, _cp * (1 + _f.glow)) * _ca);
	draw_sprite_ext(spr_glow_sw, 0, _fx, _fy, _cp, _cp * ((_ca * _ca) * _ca), 0, _c, lerp(0, .6, _cp * (1 + _f.glow)) * (1 - _ca));
	var _ga = _f.ga;                                 // the flicker while small (held between ticks)
	var _sz = _f.size * (_ca * _ca);
	// (the unclaimed cell's pixel ring, shake and step-fill were the forging of a dial, not a finished one - out, his call 2026-09-16)
	draw_set_alpha(clamp(1 - _ga, 0, 1) * _ca);
	draw_circle_colour(_fx - 1.5, _fy - 1, _sz, _c, make_colour_hsv(c_hue(_c), 255, c_val(_c)), false);
	draw_set_alpha(1);
	// the rings (obj_gf_eff_ring's Draw Begin: a half disc and a full outline)
	for (var _i = 0; _i < array_length(_f.rings); _i++) {
		var _r = _f.rings[_i];
		draw_set_alpha(.5 * _r.alpha);
		draw_circle_colour(_fx, _fy, _r.size, _c, _c, false);
		draw_set_alpha(_r.alpha);
		draw_circle_colour(_fx, _fy, _r.size, _c, _c, true);
	}
	draw_set_alpha(1);
	// the motes (obj_gf_eff's Draw Begin)
	var _comp = __forge_comp(_c);
	for (var _i = 0; _i < array_length(_f.effs); _i++) {
		var _e = _f.effs[_i];
		draw_circle_colour(_e.x, _e.y, _e.size, _c, _c, false);
		draw_sprite_ext(spr_glow_sw, 0, _e.x, _e.y, .2, .2, 0, _c, .3 * _e.alpha);
		if (_e.big_glow)
			draw_sprite_ext(spr_glow_sw, 0, _e.x, _e.y, 20 * (_e[$ "j1"] ?? 1), (.1 * _e.glow_scale) + (_e[$ "j2"] ?? 0), 0,
				_comp, (.7 + (_e[$ "j3"] ?? 0)) * (_e.glow_alpha * _e.alpha));
	}
	// the sparks (obj_eff_shardspark's Draw Begin: a `scale` square on its centre)
	for (var _i = 0; _i < array_length(_f.sparks); _i++) {
		var _s = _f.sparks[_i];
		draw_sprite_ext(spr_pixel_1x1, 0, _s.x - _s.scale * .5, _s.y - _s.scale * .5, _s.scale, _s.scale, 0, _s.col, 1);
	}
	gpu_set_blendmode(bm_normal);
	draw_set_circle_precision(24);
	draw_set_color(c_white);
	if (_cell != 1) matrix_set(matrix_world, matrix_build_identity());
	surface_reset_target();
	// the light in the surface is already colour x alpha (bm_add wrote it),
	// so it lands with (one, one): added as it is, the alpha not counted twice
	gpu_set_blendmode_ext(bm_one, bm_one);
	var _tf = gpu_get_tex_filter();
	gpu_set_tex_filter(false);
	draw_surface_ext(g.title_forge_surf, 0, 0, _cell, _cell, 0, c_white, 1);
	gpu_set_tex_filter(_tf);
	gpu_set_blendmode(bm_normal);
};

__draw_field = function() {
	// ---- the ground ----
	// plain black. The gradient is NOT under the glow pass any more -
	// see __draw_grad below, and why.
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, 1);

	// ---- THE DRIFT ----
	// ⚖️ THE LATTICE IS GONE (his verdict on the first attempt: "the
	// background sucks"). Drawing the visualiser's grid literally gave the
	// screen graph paper - a regular 27px mesh reads as a debug overlay
	// however dim it is, because regularity is the thing the eye locks onto
	// first and there was nothing else for it to look at.
	//
	// The idea was right and the execution was too literal. What is left is
	// the game's SHAPE without its ruler: a few large soft blocks, well out
	// of focus, drifting up-right at different speeds and breathing through
	// the rarity ladder. Each rides a glow so it reads as light rather than
	// as a rectangle, and they overlap - depth comes from occlusion and
	// speed, which is what the parallax starfield was reaching for and what
	// a flat grid can never have.
	var _bg = variable_global_exists("title_bg") ? g.title_bg : "starfield";
	var _stars = (_bg == "starfield"), _trace = (_bg == "trace"), _forge = (_bg == "forge");
	if (_trace) __draw_trace();
	if (_stars) {
		// THE FLIGHT: z shrinks a little every frame (delta-scaled); the
		// screen point is the box point over z from the room's centre, so
		// a star drifts outward as it nears; size and brightness by
		// nearness; past the camera (z < .02) it is reborn at the far wall
		var _cx = room_width * .5, _cy = room_height * .5;
		var _ffx = room_width * .55, _ffy = room_height * .55;   // the box's half-extents, projected
		for (var _i = 0; _i < array_length(star); _i++) {
			var _s = star[_i];
			_s.z -= .0016 * delta;
			if (_s.z < .02) { _s.z = 1; _s.x = random_range(-1, 1); _s.y = random_range(-1, 1); }
			// (.45 of the half-extents at the far wall - .12 bunched every new star
			// in a 64px knot at the centre and left the edges to the streakers)
			var _sx = _cx + _s.x / _s.z * _ffx * .45;
			var _sy = _cy + _s.y / _s.z * _ffy * .45;
			if (_sx < -2 || _sy < -2 || _sx > room_width + 2 || _sy > room_height + 2) { _s.z = 1; _s.x = random_range(-1, 1); _s.y = random_range(-1, 1); continue; }
			var _near = 1 - _s.z;                         // 0 far .. 1 here
			var _sz = (_near > .8) ? 2 : 1;
			var _br = .08 + .9 * _near * _near;
			var _tw = .75 + .25 * dsin(tt * _s.tw + _s.ph);
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx), floor(_sy), _sz, _sz, 0, _s.col, _br * _tw);
		}
	}
	var _n = (_stars || _trace || _forge) ? 0 : array_length(blk_h);
	for (var _i = 0; _i < _n; _i++) {
		var _b = blk_h[_i];

		// travel up-right forever, wrapping on a margin wider than the
		// block so nothing ever pops in at an edge
		var _sp = _b.spd;
		var _m  = _b.size + 60;
		var _bx = ((_b.x0 * (room_width + _m) + tt * _sp * 1.7) mod (room_width + _m)) - _m * .5;
		var _by = ((_b.y0 * (room_height + _m) - tt * _sp) mod (room_height + _m));
		if (_by < 0) _by += room_height + _m;
		_by -= _m * .5;

		// its own slow breath, so the field is always mid-thought rather
		// than pulsing in time with itself
		var _a = .5 + .5 * dsin(tt * _b.br + _b.ph);
		var _c = vis_tier_color(_b.tier);

		// ⚖️ THE CORE ONLY - THE LIGHT IS THE GLOW LAYER'S (his question,
		// 2026-09-10: "why not use the internal bloom shader instead of
		// sprites"). Each block used to carry a spr_vis_glow_soft stamp
		// 2.6x its size, drawn under it; now the block is a plain square
		// and title_glow (_effect_glow, the visualiser's own pass) bleeds
		// it into the dark - so the title's field is lit by the same pass
		// the money room's field is, which is the whole claim this
		// background makes. It also means overlapping blocks ADD light
		// where they cross, which two stamps never did. The core is
		// brighter than the old one because the pass needs something to
		// bloom, and the far ones stay dimmer (dim) - depth by brightness
		// now that the per-block blur is gone.
		draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by, _b.size, _b.size, 0,
			_c, (.10 + .12 * _a) * _b.dim);
	}

	// ---- the motes ----
	// The profit bits, at rest. A handful of slow sparks rising through the
	// blocks - the one moving thing small enough to read as detail rather
	// than as another shape competing with the menu. NOT over the
	// starfield (his call, 2026-09-14: "they look weird when you got some
	// coming at you") - a field of stars flying at the camera has its own
	// motion, and sparks drifting the other way argue with it
	for (var _i = 0; _i < ((_stars || _trace || _forge) ? 0 : array_length(mote)); _i++) {
		var _mt = mote[_i];
		var _mx = _mt.hx * room_width + dsin(tt * .35 + _mt.p1) * 5;
		var _my = room_height + 8 - ((tt * _mt.hs + _mt.y0) mod (room_height + 16));
		draw_sprite_ext(spr_pixel_1x1, 0, _mx, _my, 1, 1, 0,
			c_gold, .10 + .18 * abs(dsin(tt * .9 + _mt.p2)));
	}

};
field_px = create_obj(0, 0, obj_draw_proxy);
field_px.owner = id;
field_px.depth = 100;
field_px.fn    = __draw_field;

// THE FORGE'S SLOT: above the pass, below the buttons' glass capture -
// only while it is the backdrop (the field stays black under it)
forge_px = create_obj(0, 0, obj_draw_proxy);
forge_px.owner = id;
forge_px.depth = 48;
forge_px.fn    = function() { if (variable_global_exists("title_bg") && g.title_bg == "forge") __draw_forge(); };

// ⚖️ THE NAME IS LIT BY THE PASS TOO - BUT ONLY A DIM COPY OF IT (his
// reports, 2026-09-10: first "title still has sprite glow" - the
// wordmark sat over a spr_vis_glow_soft wash, the last stamp - then,
// with the whole wordmark under the layer, "the title glows way too
// much"). A bloom pass has one intensity for everything under it, and
// what is right for a block at 20% is a furnace on white-gold type at
// 100%. So the pass never sees the real wordmark: this draws a FAINT
// twin of it at depth 90, under the layer, and that is all the light
// the halo is made from; the wordmark itself draws at 0, over the
// pass, crisp and full. NAME_UNDER is the halo's whole strength.
NAME_UNDER = .22;
__draw_name = function() {
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(fnt_larger);   // (fnt_large x2 as a font of its own, 2026-09-13)
	draw_set_color(merge_colour(c_gold, c_white, .55));
	draw_set_alpha(NAME_UNDER);
	var _nm = "Myriad";
	draw_text(lm, 46, _nm);
	var _nw = string_width(_nm);
	draw_set_color(c_gold);
	draw_text(lm + _nw + 8, 46, "rx");
	draw_set_alpha(1);
	draw_set_font(fnt);
};
name_px = create_obj(0, 0, obj_draw_proxy);
name_px.owner = id;
name_px.depth = 90;
name_px.fn    = __draw_name;

// ⚖️ THE GRADIENT SITS OVER THE PASS, ADDED (his report, 2026-09-10:
// "banding on the title screen gradient background"). Under the glow
// layer it banded again, and for a reason the dither could not fix:
// the pass adds a BLURRED copy of everything below it, and a blur of a
// temporally dithered gradient is the gradient with its dither
// averaged out - 8-bit steps, in the blurred copy, laid back over the
// clean one. So the gradient draws at 40, above the layer, in bm_add:
// black adds nothing, the teal adds itself, and the composition is the
// old one (blocks over a bottom-lit teal) with the dither untouched
// and nothing for the pass to smear. The field under the pass is pure
// black plus the blocks - which is all a glow pass should ever see.
__draw_grad = function() {
	gpu_set_blendmode(bm_add);
	shader_set(sh_fog_dither);
	shader_set_uniform_f(dith_u_time, (current_time mod 100000) / 1000);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, 0, 0, room_width,
		room_height, 0, c_black, c_black, c_hsv(169, 190, 18), c_hsv(169, 190, 18), TITLE_GRAD_A);
	shader_reset();
	gpu_set_blendmode(bm_normal);
};
/// does this backdrop wear the fog? only the blocks (his call, 2026-09-14:
/// "i dont think the starfield type should have the foggy glow thing")
__fogged = function() {
	return TITLE_GRAD && (!variable_global_exists("title_bg") || g.title_bg == "blocks");
};
// (behind TITLE_GRAD - off, the field is black plus the blocks, his
// "less fog" look; the proxy simply is not made)
grad_px = noone;
if (TITLE_GRAD) {
	grad_px = create_obj(0, 0, obj_draw_proxy);
	grad_px.owner = id;
	grad_px.depth = 40;
	grad_px.fn    = function() { if (__fogged()) __draw_grad(); };
}

// THE BUTTONS' GLASS (his ask, 2026-09-13: "the title screen buttons... the
// back shader the dial drawer has"): the field behind each row PIXELATED
// (pixel_snap 3 room px a block, rims softened 4x) under the row's plate.
// The capture is a proxy at depth 1 - after the field (100), the halo
// (90), the glow pass (50), the fog (40) and the tube behind (5), before
// this object's own Draw at 0 where the rows are painted
// ⚖️ CAPTURED ABOVE THE FOG (his report: "weird graininess with the fog").
// The fog is a temporally dithered gradient - noise by design, one LSB
// sliding every frame so the ramp never bands - and a point-sampled
// pixelation of that is a field of 3px cells each showing a different
// frame of noise: grain. So the shot is taken at 45, after the glow pass
// (50) and BEFORE the fog (40), and the fog's colour is laid on the glass
// analytically in the row draw (a 17px slice of a gradient cannot band)
snap_ok = false;
__snap_cap = function() { snap_ok = pixel_snap(3, 4); };
snap_px = create_obj(0, 0, obj_draw_proxy);
snap_px.owner = id;
snap_px.depth = 45;
snap_px.fn    = __snap_cap;

// THE CRT PASS moved out (2026-09-10): it was this screen's own proxy
// at depth 20; now syst_crt (persistent, settings > crt) runs the same
// shader in every room, over the interface or behind it. Behind, its
// seat is depth 5 - the field (100), the halo (90), the glow layer
// (50) and the gradient (40) are on the tube, the wordmark, the menu
// and the card draw after it at 0, exactly as before.
