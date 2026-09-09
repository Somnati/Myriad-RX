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

// ---- the field ----
// A lattice of blocks drifting slowly down-right with a handful of
// cells breathing in the rarity colours. Positions are pure HASH math
// off tt: stateless, deterministic, wraps forever, and costs nothing to
// leave running under a menu.
fld_pitch = 27;   // cell size in px
fld_n     = 18;   // lit cells at any moment
fld_dx    = .055; // px per 60hz step, down-RIGHT and very slow. This is
fld_dy    = .038; // a backdrop: anything you can actually watch move is
                  // one more thing competing with the menu.

// banding fix (2026-07-09, his report): the backdrop gradient rides
// the house temporal IGN dither - the same shader the starmap fog uses
dith_u_time = shader_get_uniform(sh_fog_dither, "u_time");
