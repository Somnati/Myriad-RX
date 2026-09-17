
sprite_index = spr_ui_header;
// ⚖️ THE BAR IS 27, THE SPRITE IS 29 (his diagnosis, 2026-09-10: "the
// header has a shadow attached to its sprite and it's not supposed to
// be factored into it when objects depend off the header's height").
// spr_ui_header's last two rows are its drop shadow - alpha 101 then
// 57, measured - so sprite_height puts anything seated "under the
// header" two px below the bar, on a band of shadow. Anything that
// wants to sit FLUSH under the bar seats at bar_h; anything that wants
// the shadow to fall on it keeps sprite_height.
bar_h = sprite_get_height(spr_ui_header) - 2;

x = 0;
y = 0;
depth = -1000;


image_speed = 0;
col = c_black; // header draws black (his call, 2026-07-12; was #19334d)

img = 0;

// menu v2 (the morphing trigger + drawer/grid panel). the old system
// still works: swap this back to obj_ui_menu to return to it
// TITLE MODE (his report, 2026-09-13: settings on the title could not be
// closed - the X lives on the header, and the title has none). Before a
// run starts the header is made only while a panel is up (title_header),
// pulls down from above and draws the BAR ALONE: no counter, no
// wordline - the X in its corner is the whole point of it
title_mode = in_room(rm_titlescreen);   // (game_started stays true after a run - the room is the test)
create_obj(x,y,obj_ui_menu2);

// the settings gear, left of the burger (his ask, 2026-09-08). It is a
// DOOR rather than a menu line: settings is the one destination you
// reach mid-anything, and making it the only thing you can get to
// without opening a list is what that is worth. Its own line came out
// of menu2_content the same day.
if (!instance_exists(obj_ui_gear)) create_obj(x,y,obj_ui_gear);   // (the title places its own)

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
// THE SHOWN PILE'S OWN WATERMARK - the reserve the header draws is
// measured against this rather than g.autom.lock_peak, so a payout
// still in the air cannot raise the shown floor before it lands (his
// report, 2026-09-10: the counter "snaps to 0 or eats backwards" - see
// profit_spendable). Never above the real one; follows it down at a
// rebirth or a new game. Seeded from the REAL watermark, not the shown
// pile: a header is born per room, and a pile seen net of motes still
// in the air would seat the floor low and leave the counter overstating
// the spendable by the reserve's share of that flight for good.
shown_peak = variable_global_exists("autom") ? g.autom.lock_peak : prof_shown;
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

// ---- THE BURST CHIPS (his spec, 2026-09-16): "top right minimal 8x8
// icons with the progress bar 1 pixel below it 1 pixel height" ----
// Two glyphs, one per burst kind, baked from rows of text into pixel
// lists once here so the Draw stamps them without string work. A
// finger under two ripple marks for the tap; a knob with its needle
// up-right for the dial.
__bake_glyph = function(_rows) {
	var _o = [];
	for (var _r = 0; _r < 8; _r++)
		for (var _c = 0; _c < 8; _c++)
			if (string_char_at(_rows[_r], _c + 1) == "#") array_push(_o, [_c, _r]);
	return _o;
};
burst_px = {
	tap  : __bake_glyph([ "..#..#..", ".#.##.#.", "...##...", "...##...",
	                      "...##...", "..####..", "..####..", "..####.." ]),
	dial : __bake_glyph([ "..####..", ".#....#.", "#....#.#", "#...#..#",
	                      "#..##..#", "#......#", ".#....#.", "..####.." ]),
};
burst_col = { tap : c_gold, dial : c_sgreen };   // the roster's colours
