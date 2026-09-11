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
	var _n = array_length(blk_h);
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
	// than as another shape competing with the menu.
	for (var _i = 0; _i < array_length(mote); _i++) {
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
	draw_set_font(fnt_large);
	draw_set_color(merge_colour(c_gold, c_white, .55));
	draw_set_alpha(NAME_UNDER);
	var _nm = "Myriad";
	draw_text_transformed(lm, 46, _nm, 2, 2, 0);
	var _nw = string_width(_nm) * 2;
	draw_set_color(c_gold);
	draw_text_transformed(lm + _nw + 8, 46, "rx", 2, 2, 0);
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
		room_height, 0, c_black, c_black, c_hsv(169, 190, 18), c_hsv(169, 190, 18), 1);
	shader_reset();
	gpu_set_blendmode(bm_normal);
};
grad_px = create_obj(0, 0, obj_draw_proxy);
grad_px.owner = id;
grad_px.depth = 40;
grad_px.fn    = __draw_grad;

// THE CRT PASS moved out (2026-09-10): it was this screen's own proxy
// at depth 20; now syst_crt (persistent, settings > crt) runs the same
// shader in every room, over the interface or behind it. Behind, its
// seat is depth 5 - the field (100), the halo (90), the glow layer
// (50) and the gradient (40) are on the tube, the wordmark, the menu
// and the card draw after it at 0, exactly as before.
