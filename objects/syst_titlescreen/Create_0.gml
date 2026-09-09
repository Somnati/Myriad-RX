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

// a slow clock for the field drift and the title's breath
tt = 0;

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
// the rarity ladder. Baked ONCE here rather than hashed per frame -
// there are only eight, and a table you can read beats four sin()
// calls you have to decode.
//
//   x0/y0  start, as a fraction of the wrap span
//   size   px. Big: this is atmosphere, not content
//   spd    px per 60hz step. The SPREAD is the depth cue - a field
//          moving at one speed is a texture, not a distance
//   tier   which rung of the rarity ladder it wears
//   br/ph  its own breath rate and phase, so the set never pulses
//          together
//   dim    a per-block trim, so the big ones do not shout
blk_h = [
	{ x0 : .07, y0 : .20, size : 86, spd : .050, tier : 5, br : .17, ph :   0, dim : .85 },
	{ x0 : .560, y0 : .74, size : 64, spd : .085, tier : 3, br : .23, ph :  70, dim : 1   },
	{ x0 : .310, y0 : .41, size : 48, spd : .120, tier : 6, br : .29, ph : 140, dim : 1   },
	{ x0 : .820, y0 : .12, size : 72, spd : .065, tier : 2, br : .19, ph : 210, dim : .9  },
	{ x0 : .180, y0 : .88, size : 38, spd : .155, tier : 8, br : .35, ph : 280, dim : 1   },
	{ x0 : .690, y0 : .55, size : 96, spd : .040, tier : 4, br : .14, ph :  35, dim : .7  },
	{ x0 : .430, y0 : .05, size : 44, spd : .140, tier : 7, br : .31, ph : 175, dim : 1   },
	{ x0 : .950, y0 : .63, size : 56, spd : .100, tier : 5, br : .25, ph : 245, dim : .95 },
];

// banding fix (2026-07-09, his report): the backdrop gradient rides
// the house temporal IGN dither - the same shader the starmap fog uses
dith_u_time = shader_get_uniform(sh_fog_dither, "u_time");
