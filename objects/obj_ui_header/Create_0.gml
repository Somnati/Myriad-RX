
sprite_index = spr_ui_header;

x = 0;
y = 0;
depth = -1000;


image_speed = 0;
col = c_black; // header draws black (his call, 2026-07-12; was #19334d)

img = 0;

// menu v2 (the morphing trigger + drawer/grid panel). the old system
// still works: swap this back to obj_ui_menu to return to it
create_obj(x,y,obj_ui_menu2);

// ---- the profit counter (top-left, every room with a header) ----
// the SHOWN number glides to the real one, move_to-style, but in LOG
// SPACE so one easing works at any arb magnitude (packed arbs can't
// be lerped directly). -1 = "showing zero". snap on spawn (headers
// are per-room - gliding/popping on every room switch would be noise)
prof_lg = -1;
if (variable_global_exists("profit") && g.profit >= arb(1))
	prof_lg = arb_log10(g.profit);
prof_last = variable_global_exists("profit") ? g.profit : 0;