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

// WHAT CONTINUE IS CONTINUING (2026-09-07, his ask). Boot already
// loaded slot 0 behind rm_gameload, so this is only a peek for the
// card: who the run belongs to, how far it got, how long ago you left
// it. Read from the FILE rather than the globals - the file is the
// profile's real identity, and it cannot disagree with what will load.
cont = save_slot_info(save_file);

// ---- layout ----
lm     = 30;      // the left margin everything hangs off
rule_x = lm - 11; // the accent rule / hover bar column
items  = ["continue", "new game", "load", "quit"];
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
repeat (22) array_push(mote, {
	hx : random(1), hs : random_range(.10, .32),
	p1 : random(360), p2 : random(360), y0 : random(400),
});

// banding fix (2026-07-09, his report): the backdrop gradient rides
// the house temporal IGN dither - the same shader the starmap fog uses
dith_u_time = shader_get_uniform(sh_fog_dither, "u_time");
