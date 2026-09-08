
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

// the settings gear, left of the burger (his ask, 2026-09-08). It is a
// DOOR rather than a menu line: settings is the one destination you
// reach mid-anything, and making it the only thing you can get to
// without opening a list is what that is worth. Its own line came out
// of menu2_content the same day.
create_obj(x,y,obj_ui_gear);

// ---- the profit counter (top-left, every room with a header) ----
// the SHOWN number glides to the real one, move_to-style, but in LOG
// SPACE so one easing works at any arb magnitude (packed arbs can't
// be lerped directly). -1 = "showing zero". snap on spawn (headers
// are per-room - gliding/popping on every room switch would be noise)
prof_lg = -1;
// prof_shown = profit MINUS whatever is still riding profit motes (see
// Step). Everything that displays the pile reads this, not g.profit.
prof_shown   = variable_global_exists("profit") ? g.profit : 0;
flight       = 0;
ratchet_real = prof_shown;   // DE's decade-boundary ratchet
ratchet_tgt  = prof_shown;
if (prof_shown >= arb(1)) prof_lg = arb_log10(prof_shown);
prof_last = prof_shown;

// ---- THE GAIN FLOAT, and there is only ever ONE of it ----
// Profit arrives as bezier motes and the counter rises as each one
// lands, so a float per rise is a float per MOTE - a payout burst threw
// a dozen and a tap streak threw one a frame. Myriad DE's answer, from
// create_click_effects: while a float is still alive, ADD to it and
// refresh its life instead of spawning a second one. So a burst reads
// as one number counting up, and a tap streak grows a single running
// total you can actually watch - which is the only way the tapper's
// contribution is visible at all.
gain_f   = noone;   // the live float, or noone
gain_val = 0;       // what it is currently showing