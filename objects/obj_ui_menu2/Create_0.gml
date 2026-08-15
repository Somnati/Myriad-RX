/// menu v2 trigger: a DRAWN burger (no sprite) that morphs into an X
/// while the menu opens, with a press ripple. spawned by obj_ui_header
/// in the old trigger's corner; owns the `open` flag the whole system
/// keys off (syst_input's blocker line reads it, syst_menu2 mirrors
/// it). the old obj_ui_menu is untouched - swap one line in the
/// header's create to go back.

depth = instance_exists(obj_ui_header) ? obj_ui_header.depth - 1 : -1001;

open = false;
t   = 0;   // burger -> X morph, 0..1
rip = 0;   // press ripple, 1 -> 0
tic = 0;
hot = false;

bx = room_width - 15; // icon center, dropped below the display buttons
by = 22;
