/// rm_titlescreen - the REAL landscape title (2026-07-07, his ask):
/// new game / continue / load / settings / quit. no header, no menu -
/// g.game_started stays false until continue or new game flips it
/// (obj_ui_menu2 gates on the flag, so the burger can't exist here or
/// in the rooms reachable from here). settings/load ride the nav
/// stack: their back buttons return HERE because here is where you
/// came from. boot auto-loads slot 0 behind rm_gameload, so CONTINUE
/// just proceeds with the loaded state; NEW GAME opens rm_saves in
/// new-game mode (slot picker > overwrite confirm > difficulty) and
/// game_reset() rebuilds the run in memory - no game_restart.

save_file = save_slot_path(0);
has_save = file_exists(save_file);

// the button column, centered
btn_w = 130;
btn_h = 18;
btn_x = (room_width - btn_w) div 2;
btn_y0 = 118;
btn_p = 24;
labels = ["new game", "continue", "load", "settings", "quit"];

// a slow shimmer clock for the title
tt = 0;

// hover BOUNCE (take 2, 2026-07-13 his feedback: not a continuous
// wiggle - two discrete springy transitions). hov is a damped SPRING
// seeking 1 while hovered / 0 while not: entering overshoots to
// larger and settles, leaving bounces back down; at rest there is no
// motion at all. the DRAW inflates the button chrome around its
// center by hov; the LABEL stays pinned at the resting rect's anchor
// (draw_ui_button's lx/ly override) - re-centering glyphs on the
// oscillating rect made the text shimmer across pixel boundaries.
// hit rects stay STATIC, so detection can't fight the animation.
hov = array_create(5, 0); // spring position, ~0..1 (overshoots)
hv  = array_create(5, 0); // spring velocity

// banding fix (2026-07-09, his report): the backdrop gradient rides
// the house temporal IGN dither - the same shader the starmap fog uses
dith_u_time = shader_get_uniform(sh_fog_dither, "u_time");
