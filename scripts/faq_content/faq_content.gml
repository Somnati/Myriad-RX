/// @description faq_content() - THE in-game FAQ, declared as calls
/// (settings_content's doctrine: this is the one file to edit). Runs in
/// syst_faq's scope on every rebuild. His ask (2026-09-10): "build it
/// like how statistics are with the tabs... include visual sprites
/// from throughout the game so it's not just walls of text".
///
/// ==================== HOW TO ADD AN ENTRY ===========================
///   faq_section("name", colour);      - a tab in the rail
///   faq_entry("title", "body", art);  - one card under the active tab
/// art is optional and one of:
///   { spr : spr_x, [frame], [scale], [col] }   a sprite, centred in the
///                                              card's art box
///   { fn : function(_x, _y, _w, _h) { ... } }  a painter, given the box
///     (painters read globals and call the game's own draw helpers - a
///      tile drawn by tile_shape_draw IS the tile the player will see)
/// The body wraps to the card's width by itself. Keep a card to one
/// idea; a second idea is a second card.
/// ====================================================================
function faq_content() {

	// ============================ basics ============================
	faq_section("basics", c_horange);

	faq_entry("tapping",
		"the money room's surface is the tap. every tap pays profit and "
		+ "throws a mote at the counter. hold to keep tapping at the hold "
		+ "rate. a tap can crit - the readout bottom-left says how fast "
		+ "you are going.",
		{ spr : spr_part_profit, scale : 3, col : c_sgreen });

	faq_entry("overcharge",
		"keep tapping and the charger beside the per-tap figure fills: "
		+ "every level is another x1 on what a tap pays - x2, x3, up to "
		+ "x5. stop, and after a moment it drains back down. the ring is "
		+ "the charge toward the next level; the colour is the level. "
		+ "the overcharge ability in the deck switches it on.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			var _c = vis_tier_color(2);
			draw_circle_colour(_cx, _cy, 4, c_black, c_black, false);
			draw_circle_colour(_cx, _cy, 3, merge_colour(_c, c_black, .5), merge_colour(_c, c_black, .5), false);
			draw_arc(_cx, _cy, 9, 2, 1, merge_colour(_c, c_black, .75), .55);
			draw_arc(_cx, _cy, 9, 2, .65, _c, .95);
			draw_set_font(fnt_outline);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(_c);
			draw_text(_cx, _cy + 1, "x3");
			draw_set_valign(fa_top);
			draw_set_font(fnt);
		} });

	faq_entry("profit",
		"the one currency. dials make it, taps make it, dial levels cost "
		+ "it. the counter top-left holds back whatever is still flying "
		+ "in on motes, so it climbs as they land.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			draw_sprite_ext(spr_coin,        1, _cx - 16, _cy, 2, 2, -12, c_white, 1);
			draw_sprite_ext(spr_coin_silver, 1, _cx,      _cy - 2, 2, 2,  6, c_white, 1);
			draw_sprite_ext(spr_coin_gold,   1, _cx + 16, _cy, 2, 2, -4, c_white, 1);
		} });

	faq_entry("credits",
		"a second currency. a small chance per tap drops some from a pool "
		+ "that refills over time; the panel at the left edge slides out "
		+ "to catch them. credits roll and buy the upgrades.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			draw_sprite_ext(spr_particon, 0, _cx - 6, _cy - 2, 2, 2, 0, c_lavender, 1);
			draw_set_font(fnt_large);
			draw_set_halign(fa_left);
			draw_set_color(c_lavender);
			draw_text(_cx + 6, _cy - 6, "12");
			draw_set_font(fnt);
		} });

	faq_entry("the menu",
		"the burger top-right opens the menu. while a panel like this one "
		+ "is up, the burger is the X that closes it. escape does the "
		+ "same on pc.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			for (var _k = -1; _k <= 1; _k++)
				draw_sprite_ext(spr_pixel_1x1, 0, _cx - 10, _cy + _k * 6 - 1, 20, 2, 0, c_white, .9);
		} });

	// ============================ dials =============================
	faq_section("dials", c_gold);

	faq_entry("the drawer",
		"swipe LEFT from the money room's right edge to pull the dial "
		+ "drawer out; swipe right to push it back. each row is a dial: "
		+ "it runs a cycle and pays at the end. tap a row to start a "
		+ "cycle by hand.",
		{ spr : spr_dial, scale : 1, col : c_gold });

	faq_entry("buying levels",
		"swipe again for the buy column. the x1 / x10 / x100 / max button "
		+ "sets how many levels a press buys; the price inside a button "
		+ "is for the whole bundle, and it lights when you can afford it.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			draw_sprite_ext(spr_buylv, 0, _cx - 24, _cy - 12, 2, 2, 0, c_rarity_uncommon, 1);
			draw_sprite_ext(spr_buylv, 3, _cx - 24, _cy - 12, 2, 2, 0, c_white, 1);
		} });

	faq_entry("p/c and p/s",
		"the little toggle in the drawer flips every dial's readout "
		+ "between profit per cycle and profit per second. per second is "
		+ "the honest one for comparing dials.",
		{ spr : spr_hud_toggle_ps, scale : 2, col : c_white });

	// ============================ tiles =============================
	faq_section("tiles", c_aqua);

	faq_entry("the table",
		"the fabricator makes a tile every few seconds. drag two tiles of "
		+ "the same tier together to merge them into the next tier - each "
		+ "tier is worth a lot more than the one below. every tier wears "
		+ "its own colour, and gains a detail and a pixel as it climbs, so "
		+ "a higher tile reads as more at a glance.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			tile_shape_draw(1, _cx - 32, _cy - 7, 30, 13, tile_color(1), 1);
			tile_shape_draw(2, _cx + 2,  _cy - 7, 30, 13, tile_color(2), 1);
			tile_shape_draw(3, _cx - 32, _cy + 9, 30, 13, tile_color(3), 1);
			tile_shape_draw(4, _cx + 2,  _cy + 9, 30, 13, tile_color(4), 1);
		} });

	faq_entry("shards",
		"the board pays shards every second - the table's own currency, "
		+ "and the only thing tile upgrades cost. swipe left from the "
		+ "right edge for the upgrade drawer. the dial profit boost is "
		+ "the wire from the table to your dials: nothing until you buy "
		+ "it, and it grows with the board.",
		{ fn : function(_x, _y, _w, _h) {
			draw_set_font(fnt_large);
			draw_set_halign(fa_center);
			draw_set_color(c_aqua);
			draw_text(_x + _w * .5, _y + _h * .5 - 6, "136m");
			draw_set_font(fnt);
		} });

	faq_entry("table rebirth",
		"once the table has earned enough, reset it for FLUX. flux is "
		+ "kept forever and every point is +1% to what every tile pays. "
		+ "the board's red RESET wipes everything, flux included - it is "
		+ "for starting over, not for prestige.",
		{ fn : function(_x, _y, _w, _h) {
			draw_set_font(fnt_large);
			draw_set_halign(fa_center);
			draw_set_color(c_hred);
			draw_text(_x + _w * .5, _y + _h * .5 - 6, "+1 flux");
			draw_set_font(fnt);
		} });

	// ============================ upgrades ==========================
	faq_section("upgrades", c_lavender);

	faq_entry("rolling",
		"credits roll an upgrade into an empty slot. what you get is a "
		+ "kind and a rarity; rarer rolls are worth more, cost more to "
		+ "level and reach a higher tier. everything an upgrade does is "
		+ "derived from what you hold, so selling one takes back exactly "
		+ "what it gave.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			var _cs = [c_rarity_uncommon, c_rarity_rare, c_rarity_epic, c_rarity_legendary];
			for (var _k = 0; _k < 4; _k++) {
				draw_sprite_ext(spr_pixel_1x1, 0, _cx - 26 + _k * 14, _cy - 8, 10, 16, 0,
					merge_colour(c_black, _cs[_k], .3), 1);
				draw_px_rect(_cx - 26 + _k * 14, _cy - 8, 10, 16, _cs[_k], .9);
			}
		} });

	faq_entry("difficulty",
		"picked at new game. it scales how fast upgrade prices climb - "
		+ "easy gentler, critical steeper. custom is stored and does "
		+ "nothing yet.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			var _cs = [c_sblue, rgb(195, 205, 235), c_horange, c_hred, c_hpurple];
			for (var _k = 0; _k < 5; _k++)
				draw_sprite_ext(spr_pixel_1x1, 0, _cx - 25 + _k * 11, _cy - 3, 8, 6, 0, _cs[_k], .9);
		} });

	// ============================ rebirth ===========================
	faq_section("rebirth", c_hred);

	faq_entry("units",
		"the banner along the bottom of the money room fills as your "
		+ "profit climbs. past the gate it offers UNITS: rebirth resets "
		+ "the run and keeps the units, and every unit boosts profit "
		+ "from then on. hold the button to collect.",
		{ spr : spr_rebirth_btn, scale : 1, col : c_hred });

	faq_entry("what survives",
		"units, credits and your upgrades, the time bank, the daily gift, "
		+ "settings and statistics. the pile of profit, dial levels and "
		+ "the tile table start over.",
		{ fn : function(_x, _y, _w, _h) {
			draw_set_font(fnt_large);
			draw_set_halign(fa_center);
			draw_set_color(c_hred);
			draw_text(_x + _w * .5, _y + _h * .5 - 6, "x2.4");
			draw_set_font(fnt);
		} });

	// ============================ away ==============================
	faq_section("away", c_sblue);

	faq_entry("the pile",
		"while you are gone the dials keep running. everything they earn "
		+ "waits in the pile - the button at the money room's left edge - "
		+ "until you tap it. the welcome-back banners say how long you "
		+ "were away and what it earned.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			var _pc = g.profit_color;
			draw_sprite_ext(spr_popbutton_offlinegold, 4, _cx - 15, _cy - 16, 2, 2, 0, merge_colour(_pc, c_black, .55), 1);
			draw_sprite_ext(spr_popbutton_offlinegold, 5, _cx - 15, _cy - 16, 2, 2, 0, _pc, 1);
			draw_sprite_ext(spr_popbutton_offlinegold, 0, _cx - 15, _cy - 16, 2, 2, 0, c_white, 1);
		} });

	faq_entry("the time bank",
		"an absence ALSO banks time - a few minutes for every hour away, "
		+ "up to the bank's capacity. spend it as speed (x2 to x50: the "
		+ "game runs that many times faster until the bank is empty) or "
		+ "burn a lump at once. the bank's own upgrades are paid in "
		+ "banked time.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			draw_ui_button(_cx - 26, _cy - 8, 24, 16, "x4", c_gold, true, true);
			draw_ui_button(_cx + 2,  _cy - 8, 24, 16, "x10", rgb(170, 190, 230), true, false);
		} });

	faq_entry("the daily gift",
		"one gift a real day, from a rolling two-week board. missing a "
		+ "day never resets the board - it waits. every collect levels "
		+ "the gift up, and every level pays more. it is on the menu.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			var _rc = c_rarity_rare;
			draw_sprite_ext(spr_pixel_1x1, 0, _cx - 24, _cy - 12, 48, 24, 0, merge_colour(c_black, _rc, .26), 1);
			draw_px_rect(_cx - 24, _cy - 12, 48, 24, _rc, .7);
			draw_set_halign(fa_left);
			draw_set_color(sett_ink);
			draw_text(_cx - 20, _cy - 8, "day 7");
			draw_set_color(_rc);
			draw_text(_cx - 20, _cy + 2, "rare");
		} });

	faq_entry("saves",
		"the game autosaves every minute when something changed, and "
		+ "keeps a ladder of backups behind it. settings > data holds the "
		+ "save controls; the saves screen imports, exports and manages "
		+ "profiles.",
		{ fn : function(_x, _y, _w, _h) {
			var _cx = _x + _w * .5, _cy = _y + _h * .5;
			for (var _k = 0; _k < 3; _k++)
				draw_ui_back(_cx - 22 + _k * 4, _cy - 9 + _k * 3, 36, 12);
		} });
}
