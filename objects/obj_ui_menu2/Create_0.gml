/// menu v2 trigger - THE HEADER IS THE MENU BUTTON (DE's path, his call
/// 2026-09-13): a tap anywhere on the bar opens the drawer, over a panel
/// too, and folds it again; the corner where the burger lived draws an
/// X only while there is something to close (the drawer, or a panel).
/// The bar teaches the gesture the way DE's obj_button_mainoptions did -
/// "tap up here to open the menu", fading with the run's magnitude.
/// Spawned by obj_ui_header; owns the `open` flag the whole system keys
/// off (syst_input's blocker line reads it, syst_menu2 mirrors it).
/// (The burger, the morph and the x chip are in git if a mood changes.)

depth = instance_exists(obj_ui_header) ? obj_ui_header.depth - 1 : -1001;

open = false;
t   = 1;   // the corner's shape ease (the morph's X end - kept for the Draw's geometry)
ba  = 0;   // the corner X's presence, 0..1
rip = 0;   // press ripple, 1 -> 0
tic = 0;
hot = false;      // the pointer on the corner X
hot_bar = false;  // the pointer on the bar
ha  = 0;          // the hint's alpha, eased

bx = room_width - 15; // the corner X's centre, dropped below the display buttons
by = 22;
